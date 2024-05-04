import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/api_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  runApp(const RecipeFinderApp());
}

class RecipeFinderApp extends StatelessWidget {
  const RecipeFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiController()),
      ],
      child: MaterialApp(
        title: 'Recipe Finder',
        theme: AppTheme.lightTheme(),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
