import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/note.dart';
import 'storage_service.dart';

/// 导入导出服务
class ImportExportService {
  final StorageService _storageService;

  ImportExportService(this._storageService);

  /// 导出为 JSON
  Future<String?> exportToJson() async {
    try {
      final notes = await _storageService.getAllNotes();
      final data = notes.map((n) => n.toJson()).toList();
      final json = jsonEncode(data);
      
      // 保存到文件
      final dir = Directory.systemTemp;
      final file = File(path.join(dir.path, 'openwrite_backup_${DateTime.now().millisecondsSinceEpoch}.json'));
      await file.writeAsString(json);
      
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// 导出为 ZIP（简化版本）
  Future<String?> exportToZip() async {
    try {
      final notes = await _storageService.getAllNotes();
      final data = notes.map((n) => n.toJson()).toList();
      final json = jsonEncode(data);
      
      // 保存为 JSON 文件（ZIP 功能简化）
      final dir = Directory.systemTemp;
      final file = File(path.join(dir.path, 'openwrite_backup_${DateTime.now().millisecondsSinceEpoch}.json'));
      await file.writeAsString(json);
      
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// 从 JSON 导入
  Future<int> importFromJson() async {
    // 简化版本，返回 0
    return 0;
  }

  /// 从 ZIP 导入
  Future<int> importFromZip() async {
    // 简化版本，返回 0
    return 0;
  }
}
