import 'package:uuid/uuid.dart';

/// 笔记服务 - 简化版本，仅用于演示
class NoteService {
  final _uuid = const Uuid();

  String generateId() => _uuid.v4();

  // 数据存储由调用方自行实现
}
