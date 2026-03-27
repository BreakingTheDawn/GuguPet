import 'package:flutter/material.dart';
import '../../../core/services/security_service.dart';
import '../../../core/services/security_monitor_service.dart';

/// 安全设置页面
/// 显示设备安全状态、安全事件日志、安全报告等
class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final SecurityService _securityService = SecurityService();
  final SecurityMonitorService _monitorService = SecurityMonitorService();

  bool _isDeviceSecure = true;
  SecurityReport? _securityReport;
  List<SecurityEvent> _recentEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityData();
  }

  /// 加载安全数据
  Future<void> _loadSecurityData() async {
    setState(() => _isLoading = true);

    try {
      // 检查设备安全性
      final isSecure = await _securityService.isDeviceSecure();

      // 获取最近的安全事件
      final events = await _monitorService.getSecurityEvents(limit: 10);

      // 生成安全报告（使用默认用户ID）
      final report = await _monitorService.generateSecurityReport('current_user');

      setState(() {
        _isDeviceSecure = isSecure;
        _recentEvents = events;
        _securityReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载安全数据失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('安全设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSecurityData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeviceSecurityCard(),
                  const SizedBox(height: 16),
                  if (_securityReport != null) _buildSecurityReportCard(),
                  const SizedBox(height: 16),
                  _buildRecentEventsCard(),
                ],
              ),
            ),
    );
  }

  /// 构建设备安全卡片
  Widget _buildDeviceSecurityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isDeviceSecure ? Icons.security : Icons.warning,
                  color: _isDeviceSecure ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  '设备安全状态',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isDeviceSecure
                  ? '✅ 您的设备安全，未检测到Root/越狱'
                  : '⚠️ 检测到设备已Root/越狱，数据安全风险较高',
              style: TextStyle(
                color: _isDeviceSecure ? Colors.green : Colors.orange,
              ),
            ),
            if (!_isDeviceSecure) ...[
              const SizedBox(height: 8),
              const Text(
                '建议：不要在Root/越狱设备上使用VIP等付费功能',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建安全报告卡片
  Widget _buildSecurityReportCard() {
    final report = _securityReport!;
    final score = report.securityScore;
    final level = report.securityLevel;

    Color scoreColor;
    if (score >= 90) {
      scoreColor = Colors.green;
    } else if (score >= 70) {
      scoreColor = Colors.blue;
    } else if (score >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '安全评分',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: score / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(scoreColor),
                          ),
                        ),
                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      level,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow('总事件', report.totalEvents),
                    _buildStatRow('严重', report.criticalEvents, color: Colors.red),
                    _buildStatRow('警告', report.warningEvents, color: Colors.orange),
                    _buildStatRow('信息', report.infoEvents, color: Colors.blue),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计行
  Widget _buildStatRow(String label, int count, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (color ?? Colors.grey).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建最近事件卡片
  Widget _buildRecentEventsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最近安全事件',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_recentEvents.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _showAllEvents();
                    },
                    child: const Text('查看全部'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_recentEvents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('暂无安全事件'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentEvents.length,
                itemBuilder: (context, index) {
                  final event = _recentEvents[index];
                  return _buildEventItem(event);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// 构建事件项
  Widget _buildEventItem(SecurityEvent event) {
    IconData icon;
    Color color;

    switch (event.severity) {
      case SecuritySeverity.critical:
        icon = Icons.error;
        color = Colors.red;
        break;
      case SecuritySeverity.warning:
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case SecuritySeverity.info:
        icon = Icons.info;
        color = Colors.blue;
        break;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(_getEventTypeText(event.eventType)),
      subtitle: Text(
        event.details,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(event.timestamp),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  /// 获取事件类型文本
  String _getEventTypeText(SecurityEventType type) {
    switch (type) {
      case SecurityEventType.rootDetected:
        return 'Root检测';
      case SecurityEventType.signatureVerificationFailed:
        return '签名验证失败';
      case SecurityEventType.vipStatusChanged:
        return 'VIP状态变更';
      case SecurityEventType.dataTamperingDetected:
        return '数据篡改检测';
      case SecurityEventType.unauthorizedAccess:
        return '未授权访问';
      case SecurityEventType.apiKeyCompromised:
        return 'API密钥泄露';
      case SecurityEventType.deviceBindingFailed:
        return '设备绑定失败';
      case SecurityEventType.suspiciousActivity:
        return '可疑活动';
    }
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else {
      return '${diff.inDays}天前';
    }
  }

  /// 显示所有事件
  void _showAllEvents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '所有安全事件',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: FutureBuilder<List<SecurityEvent>>(
                      future: _monitorService.getSecurityEvents(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final events = snapshot.data!;
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            return _buildEventItem(events[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
