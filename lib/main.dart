import 'package:calorie_chat_app/objectbox.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'db/objectbox.dart';
import 'theme.dart';
import 'utils/custom_route.dart';

late Store store;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  store = await createStore();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Chat',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: generateRoute,
    );
  }
}

final apiKey = dotenv.env['API_KEY'];