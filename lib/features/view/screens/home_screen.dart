import 'package:flutter/material.dart';
import 'package:news_app/features/data/model/news_model.dart';
import 'package:news_app/features/data/services/news_api.dart';
import 'package:news_app/features/view/widgit/news_card_widgit.dart';


import '../../../core/routes/routes_app.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsApi newsApi = NewsApi();

  late Future<List<NewsModel>> news;

  @override
  void initState() {
    super.initState();
    news = newsApi.getTopHeadlines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff181818),

      appBar: AppBar(
        backgroundColor: const Color(0xff1976D2),
        elevation: 0,
        title: const Text(
          'News App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<List<NewsModel>>(
        future: news,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Something went wrong!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Failed to load news.\nPlease try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        news = newsApi.getTopHeadlines();
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          // Empty
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No news found',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }

          final newsList = snapshot.data!;

          // News
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final article = newsList[index];

              return NewsCard(
                news: article,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RoutesApp.details,
                    arguments: article,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

