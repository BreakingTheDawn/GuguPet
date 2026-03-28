import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../services/wish_envelope_service.dart';
import '../widgets/envelope_card.dart';
import 'create_envelope_page.dart';
import '../../../data/datasources/local/database_helper.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 许愿树页面
/// 展示鼓励信封，用户可以领取信封或创建信封
// ═══════════════════════════════════════════════════════════════════════════════
class WishTreePage extends StatefulWidget {
  /// 当前用户ID
  final String userId;
  
  /// 当前用户昵称
  final String userName;
  
  /// 是否已上岸（可以创建信封）
  final bool hasLanded;
  
  /// 用户职位
  final String? userTitle;

  const WishTreePage({
    super.key,
    required this.userId,
    required this.userName,
    this.hasLanded = false,
    this.userTitle,
  });

  @override
  State<WishTreePage> createState() => _WishTreePageState();
}

class _WishTreePageState extends State<WishTreePage> with SingleTickerProviderStateMixin {
  // ────────────────────────────────────────────────────────────────────────────
  // 私有属性
  // ────────────────────────────────────────────────────────────────────────────

  /// 信封服务
  late final WishEnvelopeService _envelopeService;
  
  /// Tab控制器
  late final TabController _tabController;
  
  /// 公开信封列表
  List<WishEnvelope> _publicEnvelopes = [];
  
  /// 我收到的信封
  List<WishEnvelope> _receivedEnvelopes = [];
  
  /// 我创建的信封
  List<WishEnvelope> _createdEnvelopes = [];
  
  /// 是否正在加载
  bool _isLoading = true;
  
  /// 待分配信封数量
  int _pendingCount = 0;

  // ────────────────────────────────────────────────────────────────────────────
  // 生命周期方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initService();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _initService() async {
    final db = await DatabaseHelper().database;
    _envelopeService = WishEnvelopeService(database: db);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('许愿树'),
        actions: [
          // 创建信封按钮（仅上岸用户可见）
          if (widget.hasLanded)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _navigateToCreateEnvelope,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '许愿树'),
            Tab(text: '我收到的'),
            Tab(text: '我创建的'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // 许愿树（公开信封）
                _buildPublicEnvelopesTab(),
                
                // 我收到的信封
                _buildReceivedEnvelopesTab(),
                
                // 我创建的信封
                _buildCreatedEnvelopesTab(),
              ],
            ),
      
      // 领取信封按钮（仅未上岸用户可见）
      floatingActionButton: !widget.hasLanded && _pendingCount > 0
          ? FloatingActionButton.extended(
              onPressed: _receiveEnvelope,
              icon: const Icon(Icons.mail_outline),
              label: const Text('领取信封'),
            )
          : null,
    );
  }

  /// 构建公开信封Tab
  Widget _buildPublicEnvelopesTab() {
    if (_publicEnvelopes.isEmpty) {
      return _buildEmptyState(
        icon: '🌳',
        title: '许愿树上暂时没有信封',
        subtitle: '等待上岸的小伙伴挂上温暖的信封',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _publicEnvelopes.length,
        itemBuilder: (context, index) {
          final envelope = _publicEnvelopes[index];
          return EnvelopeCard(
            envelope: envelope,
            onTap: () => _showEnvelopeDetail(envelope),
            onLike: () => _likeEnvelope(envelope.id),
          );
        },
      ),
    );
  }

  /// 构建收到信封Tab
  Widget _buildReceivedEnvelopesTab() {
    if (_receivedEnvelopes.isEmpty) {
      return _buildEmptyState(
        icon: '📭',
        title: '还没有收到信封',
        subtitle: '点击下方按钮领取一份温暖的鼓励',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _receivedEnvelopes.length,
        itemBuilder: (context, index) {
          final envelope = _receivedEnvelopes[index];
          return EnvelopeCard(
            envelope: envelope,
            onTap: () => _showEnvelopeDetail(envelope, canReply: true),
            onLike: () => _likeEnvelope(envelope.id),
          );
        },
      ),
    );
  }

  /// 构建创建信封Tab
  Widget _buildCreatedEnvelopesTab() {
    if (!widget.hasLanded) {
      return _buildEmptyState(
        icon: '🔒',
        title: '仅上岸用户可创建信封',
        subtitle: '成功上岸后即可创建鼓励信封',
      );
    }

    if (_createdEnvelopes.isEmpty) {
      return _buildEmptyState(
        icon: '✉️',
        title: '还没有创建信封',
        subtitle: '点击右上角创建你的第一份鼓励',
        action: TextButton(
          onPressed: _navigateToCreateEnvelope,
          child: const Text('创建信封'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _createdEnvelopes.length,
        itemBuilder: (context, index) {
          final envelope = _createdEnvelopes[index];
          return EnvelopeCard(
            envelope: envelope,
            onTap: () => _showEnvelopeDetail(envelope),
            onLike: () => _likeEnvelope(envelope.id),
          );
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState({
    required String icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 私有方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 加载数据
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _envelopeService.getPublicEnvelopes(limit: 50),
        _envelopeService.getEnvelopesByReceiver(widget.userId),
        _envelopeService.getEnvelopesByCreator(widget.userId),
        _envelopeService.getPendingCount(),
      ]);

      if (mounted) {
        setState(() {
          _publicEnvelopes = results[0] as List<WishEnvelope>;
          _receivedEnvelopes = results[1] as List<WishEnvelope>;
          _createdEnvelopes = results[2] as List<WishEnvelope>;
          _pendingCount = results[3] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载失败，请重试')),
        );
      }
    }
  }

  /// 显示信封详情
  void _showEnvelopeDetail(WishEnvelope envelope, {bool canReply = false}) {
    EnvelopeDetailSheet.show(
      context,
      envelope: envelope,
      onReply: canReply ? (reply) => _replyEnvelope(envelope.id, reply) : null,
    );
  }

  /// 点赞信封
  Future<void> _likeEnvelope(String envelopeId) async {
    await _envelopeService.likeEnvelope(envelopeId);
    await _loadData();
  }

  /// 回复信封
  Future<void> _replyEnvelope(String envelopeId, String replyContent) async {
    final success = await _envelopeService.replyEnvelope(envelopeId, replyContent);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('回复成功')),
      );
      await _loadData();
    }
  }

  /// 领取信封
  Future<void> _receiveEnvelope() async {
    try {
      final envelope = await _envelopeService.randomAssignEnvelope(
        widget.userId,
        widget.userName,
      );

      if (envelope != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('收到一份温暖的鼓励！')),
        );
        await _loadData();
        
        // 切换到收到的信封Tab
        _tabController.animateTo(1);
        
        // 显示信封详情
        _showEnvelopeDetail(envelope, canReply: true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('暂时没有可领取的信封')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('领取失败，请重试')),
        );
      }
    }
  }

  /// 跳转到创建信封页面
  void _navigateToCreateEnvelope() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEnvelopePage(
          creatorId: widget.userId,
          creatorName: widget.userName,
          creatorTitle: widget.userTitle,
          onCreated: _loadData,
        ),
      ),
    );
  }
}
