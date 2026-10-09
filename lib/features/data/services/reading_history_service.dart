import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/news_model.dart';

class ReadingHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _historyCollection {
    final userId = _userId;

    if (userId == null) return null;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reading_history');
  }

  Future<void> addToHistory(NewsModel news) async {
    final collection = _historyCollection;

    if (collection == null || news.url.trim().isEmpty) {
      return;
    }

    final documentId = base64Url.encode(
      utf8.encode(news.url.trim()),
    );

    await collection.doc(documentId).set({
      'title': news.title,
      'url': news.url,
      'imageUrl': news.imageUrl,
      'sourceName': news.sourceName,
      'author': news.author,
      'publishedAt': news.publishedAt,
      'viewedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getHistory() {
    final collection = _historyCollection;

    if (collection == null) {
      return const Stream.empty();
    }

    return collection
        .orderBy('viewedAt', descending: true)
        .snapshots();
  }

  Future<void> removeFromHistory(String url) async {
    final collection = _historyCollection;

    if (collection == null || url.trim().isEmpty) {
      return;
    }

    final documentId = base64Url.encode(
      utf8.encode(url.trim()),
    );

    await collection.doc(documentId).delete();
  }

  Future<void> clearHistory() async {
    final collection = _historyCollection;

    if (collection == null) return;

    final snapshot = await collection.get();

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }

    await batch.commit();
  }
}
