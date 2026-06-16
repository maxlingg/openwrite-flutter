import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/novel_provider.dart';
import 'pages/home_page.dart';
import 'screens/chat_screen.dart';
import 'screens/ai_writing_tools_screen.dart';
import 'screens/ai_novel_writing_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  runApp(const OpenWriteApp());
}

class OpenWriteApp extends StatelessWidget {
  const OpenWriteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => NovelProvider()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: '墨韵笔记',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const HomePage(),
            routes: {
              '/chat': (context) => const ChatScreen(),
              '/ai-tools': (context) => const AIWritingToolsScreen(),
              '/ai-novel': (context) => const AINovelWritingScreen(),
            },
          );
        },
      ),
    );
  }
}
