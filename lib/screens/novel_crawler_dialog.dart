import 'package:flutter/material.dart';
import '../services/novel_crawler_service.dart';

/// 网络小说爬虫对话框
class NovelCrawlerDialog extends StatefulWidget {
  final Function(NovelInfo)? onNovelLoaded;

  const NovelCrawlerDialog({
    super.key,
    this.onNovelLoaded,
  });

  @override
  State<NovelCrawlerDialog> createState() => _NovelCrawlerDialogState();
}

class _NovelCrawlerDialogState extends State<NovelCrawlerDialog> {
  final _urlController = TextEditingController();
  final _crawlerService = NovelCrawlerService();
  
  bool _isLoading = false;
  String? _error;
  NovelInfo? _novelInfo;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _fetchNovel() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = '请输入小说链接');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _novelInfo = null;
    });

    try {
      final info = await _crawlerService.fetchNovel(url);
      setState(() {
        _novelInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _import() {
    if (_novelInfo != null) {
      widget.onNovelLoaded?.call(_novelInfo!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.download, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    '导入网络小说',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // URL 输入
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: '小说链接',
                        hintText: '粘贴小说详情页链接...',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.link),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _isLoading ? null : _fetchNovel,
                        ),
                      ),
                      onSubmitted: (_) => _fetchNovel(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '支持：笔趣阁、新笔趣阁、起点中文网、晋江文学城',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.outline,
                      ),
                    ),

                    // 错误提示
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 加载中
                    if (_isLoading) ...[
                      const SizedBox(height: 24),
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 8),
                      const Center(child: Text('正在获取小说信息...')),
                    ],

                    // 小说信息预览
                    if (_novelInfo != null) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text('小说信息', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildInfoRow('标题', _novelInfo!.title),
                      _buildInfoRow('作者', _novelInfo!.author),
                      _buildInfoRow('章节数', '${_novelInfo!.chapters.length} 章'),
                      if (_novelInfo!.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('简介', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          _novelInfo!.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      if (_novelInfo!.chapters.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          '章节列表预览',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _novelInfo!.chapters.length > 10 
                                ? 10 
                                : _novelInfo!.chapters.length,
                            itemBuilder: (context, index) {
                              final chapter = _novelInfo!.chapters[index];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  chapter.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                leading: Text('${index + 1}'),
                              );
                            },
                          ),
                        ),
                        if (_novelInfo!.chapters.length > 10)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '... 共 ${_novelInfo!.chapters.length} 章',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.outline,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            // 按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _novelInfo == null ? null : _import,
                    icon: const Icon(Icons.download),
                    label: const Text('导入'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label：',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示网络小说爬虫对话框的便捷函数
Future<void> showNovelCrawlerDialog(
  BuildContext context, {
  Function(NovelInfo)? onNovelLoaded,
}) async {
  await showDialog(
    context: context,
    builder: (context) => NovelCrawlerDialog(
      onNovelLoaded: onNovelLoaded,
    ),
  );
}
