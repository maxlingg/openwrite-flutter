import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// 应用设置服务 - 持久化存储
class AppSettingsService {
  static const _settingsFile = 'app_settings.json';
  String? _dataPath;
  
  AppSettingsService();

  static Future<AppSettingsService> create() async {
    final service = AppSettingsService();
    await service._init();
    return service;
  }

  Future<void> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    _dataPath = dir.path;
  }
  
  AppSettings _settings = AppSettings();

  /// 加载设置
  Future<AppSettings> loadSettings() async {
    if (_dataPath == null) return _settings;
    try {
      final file = File(path.join(_dataPath!, _settingsFile));
      if (await file.exists()) {
        final content = await file.readAsString();
        _settings = AppSettings.fromJson(jsonDecode(content));
      }
    } catch (_) {
      _settings = AppSettings();
    }
    return _settings;
  }

  /// 保存设置
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
    if (_dataPath == null) return;
    try {
      final file = File(path.join(_dataPath!, _settingsFile));
      await file.writeAsString(jsonEncode(_settings.toJson()));
    } catch (_) {}
  }

  /// 获取 AI 配置
  LlmConfig get llmConfig => _settings.llmConfig;

  /// 更新 AI 配置
  Future<void> updateLlmConfig(LlmConfig config) async {
    _settings = _settings.copyWith(llmConfig: config);
    await saveSettings(_settings);
  }

  /// 获取主题设置
  bool get isDarkMode => _settings.isDarkMode;

  /// 更新主题设置
  Future<void> setDarkMode(bool value) async {
    _settings = _settings.copyWith(isDarkMode: value);
    await saveSettings(_settings);
  }

  /// 获取当前使用的技能 ID
  String? get currentSkillId => _settings.currentSkillId;

  /// 更新当前技能
  Future<void> setCurrentSkill(String? skillId) async {
    _settings = _settings.copyWith(currentSkillId: skillId);
    await saveSettings(_settings);
  }
}

/// 应用设置数据模型
class AppSettings {
  final LlmConfig llmConfig;
  final bool isDarkMode;
  final String? currentSkillId;
  final List<String> installedSkillIds;
  final List<String> favoriteSkillIds;

  AppSettings({
    LlmConfig? llmConfig,
    this.isDarkMode = false,
    this.currentSkillId,
    this.installedSkillIds = const [],
    this.favoriteSkillIds = const [],
  }) : llmConfig = llmConfig ?? LlmConfig();

  AppSettings copyWith({
    LlmConfig? llmConfig,
    bool? isDarkMode,
    String? currentSkillId,
    List<String>? installedSkillIds,
    List<String>? favoriteSkillIds,
  }) {
    return AppSettings(
      llmConfig: llmConfig ?? this.llmConfig,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentSkillId: currentSkillId ?? this.currentSkillId,
      installedSkillIds: installedSkillIds ?? this.installedSkillIds,
      favoriteSkillIds: favoriteSkillIds ?? this.favoriteSkillIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'llmConfig': llmConfig.toJson(),
    'isDarkMode': isDarkMode,
    'currentSkillId': currentSkillId,
    'installedSkillIds': installedSkillIds,
    'favoriteSkillIds': favoriteSkillIds,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      llmConfig: json['llmConfig'] != null
          ? LlmConfig.fromJson(json['llmConfig'])
          : LlmConfig(),
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      currentSkillId: json['currentSkillId'] as String?,
      installedSkillIds: (json['installedSkillIds'] as List?)?.cast<String>() ?? [],
      favoriteSkillIds: (json['favoriteSkillIds'] as List?)?.cast<String>() ?? [],
    );
  }
}

/// LLM 配置
class LlmConfig {
  final String baseUrl;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;

  LlmConfig({
    this.baseUrl = 'https://api.openai.com/v1',
    this.apiKey = '',
    this.model = 'gpt-4o',
    this.temperature = 0.7,
    this.maxTokens = 4000,
  });

  bool get isConfigured => apiKey.isNotEmpty;

  LlmConfig copyWith({
    String? baseUrl,
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
  }) {
    return LlmConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
    );
  }

  Map<String, dynamic> toJson() => {
    'baseUrl': baseUrl,
    'apiKey': apiKey,
    'model': model,
    'temperature': temperature,
    'maxTokens': maxTokens,
  };

  factory LlmConfig.fromJson(Map<String, dynamic> json) {
    return LlmConfig(
      baseUrl: json['baseUrl'] as String? ?? 'https://api.openai.com/v1',
      apiKey: json['apiKey'] as String? ?? '',
      model: json['model'] as String? ?? 'gpt-4o',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: json['maxTokens'] as int? ?? 4000,
    );
  }
}
