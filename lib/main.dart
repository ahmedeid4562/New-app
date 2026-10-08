import 'package:flutter/material.dart';
import 'package:news_app/features/data/model/news_model.dart';
import 'package:news_app/features/view/screens/details_screen.dart';
import 'package:news_app/features/view/screens/home_screen.dart';

import 'core/routes/routes_app.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: RoutesApp.home,

      routes: {
        RoutesApp.home: (context) => const HomeScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == RoutesApp.details) {
          final news = settings.arguments as NewsModel;

          return MaterialPageRoute(
            builder: (context) {
              return DetailsScreen(news: news);
            },
          );
        }

        return null;
      },
    );
  }
}
