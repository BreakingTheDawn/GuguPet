// 流式响应处理工具类
// 统一处理Dio流式响应和SSE解析
// 供所有LLM适配器复用

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 流式响应处理器
/// 统一处理Dio的ResponseType.stream响应
class StreamResponseHandler {
  /// 从Dio响应中获取正确的字节流
  /// 
  /// Dio使用ResponseType.stream时，response.data是ResponseBody类型
  /// 需要从ResponseBody.stream获取实际的字节流
  /// 
  /// [response] - Dio响应对象
  /// 返回字节流 `Stream<List<int>>`
  static Stream<List<int>> getStreamFromResponse(Response response) {
    final data = response.data;
    
    // 检查是否是ResponseBody类型（Dio流式响应）
    if (data is ResponseBody) {
      return data.stream;
    }
    
    // 兼容直接返回Stream的情况（某些配置下）
    if (data is Stream<List<int>>) {
      return data;
    }
    
    // 如果是List<int>，包装成单元素流
    if (data is List<int>) {
      return Stream.value(data);
    }
    
    // 其他情况抛出异常
    throw StreamHandlerException(
      '不支持的响应类型: ${data.runtimeType}，'
      '期望 ResponseBody 或 Stream<List<int>>'
    );
  }

  /// 解析SSE (Server-Sent Events) 格式的流数据
  /// 
  /// SSE格式示例:
  /// ```
  /// data: {"choices":[{"delta":{"content":"你好"}}]}
  /// data: {"choices":[{"delta":{"content":"，"}}]}
  /// data: [DONE]
  /// ```
  /// 
  /// [stream] - 字节流
  /// [onChunk] - 每个内容块的回调
  /// [onComplete] - 流结束时的回调（可选）
  /// [contentPath] - 内容在JSON中的路径，默认为 ['choices', 0, 'delta', 'content']
  static Future<String> parseSSEStream({
    required Stream<List<int>> stream,
    required Function(String chunk) onChunk,
    Function()? onComplete,
    List<dynamic> contentPath = const ['choices', 0, 'delta', 'content'],
  }) async {
    final StringBuffer fullContent = StringBuffer();
    final buffer = <int>[];

    await for (final chunk in stream) {
      buffer.addAll(chunk);
      
      // 尝试解码并处理完整的行
      _processBuffer(buffer, fullContent, onChunk, contentPath);
    }
    
    // 处理缓冲区剩余数据
    if (buffer.isNotEmpty) {
      final text = utf8.decode(buffer);
      _processText(text, fullContent, onChunk, contentPath);
    }

    onComplete?.call();
    return fullContent.toString();
  }

  /// 处理缓冲区中的数据
  static void _processBuffer(
    List<int> buffer,
    StringBuffer fullContent,
    Function(String chunk) onChunk,
    List<dynamic> contentPath,
  ) {
    // 查找完整的行（以\n结尾）
    while (true) {
      final newlineIndex = buffer.indexOf(10); // 10 = \n 的ASCII码
      if (newlineIndex == -1) break;
      
      // 提取一行数据
      final lineBytes = buffer.sublist(0, newlineIndex);
      buffer.removeRange(0, newlineIndex + 1);
      
      final line = utf8.decode(lineBytes);
      _processLine(line, fullContent, onChunk, contentPath);
    }
  }

  /// 处理单行SSE数据
  static void _processLine(
    String line,
    StringBuffer fullContent,
    Function(String chunk) onChunk,
    List<dynamic> contentPath,
  ) {
    // 调试：打印每一行原始数据
    debugPrint('🔍 [SSE] 收到行: ${line.length > 100 ? line.substring(0, 100) + "..." : line}');
    
    if (!line.startsWith('data: ')) {
      debugPrint('⚠️ [SSE] 行不以"data: "开头，跳过');
      return;
    }
    
    final data = line.substring(6);
    
    // 检查是否是结束标记
    if (data == '[DONE]') {
      debugPrint('✅ [SSE] 收到结束标记 [DONE]');
      return;
    }
    
    try {
      final jsonData = jsonDecode(data) as Map<String, dynamic>;
      debugPrint('🔍 [SSE] JSON解析成功: $jsonData');
      
      final content = _extractContent(jsonData, contentPath);
      debugPrint('🔍 [SSE] 提取的内容: "$content"');
      
      if (content != null && content.isNotEmpty) {
        fullContent.write(content);
        onChunk(content);
        debugPrint('✅ [SSE] 内容已添加: "$content"');
      } else {
        debugPrint('⚠️ [SSE] 内容为空或null');
      }
    } catch (e) {
      debugPrint('❌ [SSE] 解析失败: $e');
      debugPrint('❌ [SSE] 原始数据: $data');
    }
  }

  /// 处理文本数据（用于缓冲区剩余数据）
  static void _processText(
    String text,
    StringBuffer fullContent,
    Function(String chunk) onChunk,
    List<dynamic> contentPath,
  ) {
    for (final line in text.split('\n')) {
      _processLine(line, fullContent, onChunk, contentPath);
    }
  }

  /// 从JSON数据中提取内容
  /// 
  /// [data] - JSON数据
  /// [path] - 内容路径，例如 ['choices', 0, 'delta', 'content']
  static String? _extractContent(Map<String, dynamic> data, List<dynamic> path) {
    dynamic current = data;
    
    for (final key in path) {
      if (current == null) return null;
      
      if (key is int) {
        if (current is! List || key >= current.length) return null;
        current = current[key];
      } else if (key is String) {
        if (current is! Map<String, dynamic>) return null;
        current = current[key];
      }
    }
    
    // 如果content字段为空，尝试查找reasoning_content字段（GLM-4.7支持）
    if (current == null || (current is String && current.isEmpty)) {
      // 重新从delta开始查找reasoning_content
      try {
        final delta = data['choices']?[0]?['delta'];
        if (delta is Map<String, dynamic>) {
          final reasoningContent = delta['reasoning_content'];
          if (reasoningContent is String && reasoningContent.isNotEmpty) {
            debugPrint('💡 [SSE] 使用 reasoning_content 字段: "$reasoningContent"');
            return reasoningContent;
          }
        }
      } catch (e) {
        debugPrint('⚠️ [SSE] 查找 reasoning_content 失败: $e');
      }
    }
    
    return current as String?;
  }

  /// 创建流式请求的Dio Options
  /// 
  /// [headers] - 额外的请求头
  /// 返回配置好的Options对象
  static Options createStreamOptions({Map<String, String>? headers}) {
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        ...?headers,
      },
      responseType: ResponseType.stream,
    );
  }
}

/// 流处理异常
class StreamHandlerException implements Exception {
  final String message;
  StreamHandlerException(this.message);

  @override
  String toString() => 'StreamHandlerException: $message';
}

/// SSE内容路径常量
/// 定义不同LLM提供商的响应格式
class SSEContentPaths {
  /// OpenAI兼容格式（GLM、混元等）
  static const List<dynamic> openAICompatible = ['choices', 0, 'delta', 'content'];
  
  /// 自定义路径
  static List<dynamic> custom(List<dynamic> path) => path;
}
