import 'package:flutter/material.dart';
import '../services/webdav_service.dart';

/// WebDav 同步对话框
class WebDavSyncDialog extends StatefulWidget {
  final WebDavService service;
  final Function()? onSyncComplete;

  const WebDavSyncDialog({
    super.key,
    required this.service,
    this.onSyncComplete,
  });

  @override
  State<WebDavSyncDialog> createState() => _WebDavSyncDialogState();
}

class _WebDavSyncDialogState extends State<WebDavSyncDialog> {
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pathController = TextEditingController(text: '/OpenWrite');
  
  bool _isTesting = false;
  bool _isSyncing = false;
  String? _testResult;
  String _syncDirection = 'upload';

  @override
  void initState() {
    super.initState();
    if (widget.service.hasConfig) {
      _loadConfig();
    }
  }

  void _loadConfig() {
    // 从服务获取配置（如果实现了持久化）
    _pathController.text = '/OpenWrite';
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (_serverController.text.isEmpty) {
      setState(() => _testResult = '请输入服务器地址');
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final config = WebDavConfig(
      serverUrl: _serverController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      basePath: _pathController.text,
    );
    
    widget.service.setConfig(config);
    final success = await widget.service.testConnection();
    
    setState(() {
      _isTesting = false;
      _testResult = success ? '连接成功！' : '连接失败，请检查配置';
    });
  }

  Future<void> _sync() async {
    setState(() => _isSyncing = true);

    try {
      if (_syncDirection == 'upload') {
        // 上传逻辑
        await widget.service.syncUpload({
          'timestamp': DateTime.now().toIso8601String(),
          'notes': [],
          'novels': [],
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('上传成功')),
          );
        }
      } else {
        // 下载逻辑
        final data = await widget.service.syncDownload();
        if (mounted) {
          if (data != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('下载成功')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('云端没有备份数据')),
            );
          }
        }
      }
      widget.onSyncComplete?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('同步失败: $e')),
        );
      }
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.cloud_sync, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'WebDav 云同步',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 服务器地址
            TextField(
              controller: _serverController,
              decoration: const InputDecoration(
                labelText: '服务器地址',
                hintText: 'https://dav.example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.dns),
              ),
            ),
            const SizedBox(height: 12),

            // 用户名
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // 密码
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),

            // 路径
            TextField(
              controller: _pathController,
              decoration: const InputDecoration(
                labelText: '同步目录',
                hintText: '/OpenWrite',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 测试结果
            if (_testResult != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _testResult!.contains('成功')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testResult!.contains('成功') ? Icons.check_circle : Icons.error,
                      color: _testResult!.contains('成功') ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(_testResult!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 测试连接按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering),
                label: const Text('测试连接'),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 同步选项
            const Text('同步方向', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'upload',
                  label: Text('上传'),
                  icon: Icon(Icons.cloud_upload),
                ),
                ButtonSegment(
                  value: 'download',
                  label: Text('下载'),
                  icon: Icon(Icons.cloud_download),
                ),
              ],
              selected: {_syncDirection},
              onSelectionChanged: (v) => setState(() => _syncDirection = v.first),
            ),

            const SizedBox(height: 24),

            // 同步按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSyncing ? null : _sync,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_syncDirection == 'upload' 
                        ? Icons.cloud_upload 
                        : Icons.cloud_download),
                label: Text(_isSyncing ? '同步中...' : '开始同步'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示 WebDav 同步对话框的便捷函数
Future<void> showWebDavSyncDialog(
  BuildContext context, {
  required WebDavService service,
  Function()? onSyncComplete,
}) async {
  await showDialog(
    context: context,
    builder: (context) => WebDavSyncDialog(
      service: service,
      onSyncComplete: onSyncComplete,
    ),
  );
}
