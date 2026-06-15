import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// DOCX 导入服务
class DocxImportService {
  /// 从 DOCX 文件导入文本
  Future<String> importFromDocx(List<int> data) async {
    try {
      // 保存临时文件
      final tempDir = Directory.systemTemp;
      final tempFile = File(path.join(tempDir.path, 'temp_${DateTime.now().millisecondsSinceEpoch}.docx'));
      await tempFile.writeAsBytes(data);

      // 解析 DOCX（简化版 - 实际应该用 xml 解析库）
      // 这里先尝试读取纯文本
      final content = await _extractText(tempFile);
      
      // 删除临时文件
      await tempFile.delete();
      
      return content;
    } catch (e) {
      throw Exception('导入失败: $e');
    }
  }

  Future<String> _extractText(File file) async {
    // 简化实现 - 实际应该使用 archive 或 xml 库解析 DOCX
    // DOCX 本质上是 ZIP 文件，包含 document.xml
    try {
      final bytes = await file.readAsBytes();
      
      // 简单检查是否为有效文件
      if (bytes.length < 4) {
        return '';
      }

      // 检查 ZIP 签名
      if (bytes[0] != 0x50 || bytes[1] != 0x4B) {
        // 不是 ZIP，直接返回原始文本
        return utf8.decode(bytes, allowMalformed: true);
      }

      // 简化处理 - 提取可读文本
      final content = StringBuffer();
      final text = utf8.decode(bytes, allowMalformed: true);
      
      // 移除 XML 标签
      final cleaned = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
      // 移除多余空格
      final trimmed = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      return trimmed;
    } catch (e) {
      return '';
    }
  }

  /// 从文件导入
  Future<String> importFromFile(File file) async {
    final data = await file.readAsBytes();
    
    if (path.extension(file.path).toLowerCase() == '.docx') {
      return importFromDocx(data);
    } else if (path.extension(file.path).toLowerCase() == '.txt') {
      return utf8.decode(data, allowMalformed: true);
    } else if (path.extension(file.path).toLowerCase() == '.md') {
      return utf8.decode(data, allowMalformed: true);
    } else {
      return utf8.decode(data, allowMalformed: true);
    }
  }
}
