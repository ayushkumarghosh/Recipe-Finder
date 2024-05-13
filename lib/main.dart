import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/api_controller.dart';
import 'services/storage_service.dart';
import 'utils/page_transitions.dart';

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
        Provider(create: (_) => StorageService()),
      ],
      child: MaterialApp(
        title: 'Recipe Finder',
        theme: AppTheme.lightTheme(),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return PageTransitions.fadeTransition(
                const HomeScreen(),
                settings: settings,
              );
            case '/favorites':
              return PageTransitions.slideTransition(
                const FavoritesScreen(),
                settings: settings,
              );
            default:
              return PageTransitions.fadeTransition(
                const HomeScreen(),
                settings: settings,
              );
          }
        },
      ),
    );
  }
}
