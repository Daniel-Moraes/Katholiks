import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/bible.dart';

class SimpleBibleService {
  /// Carrega a lista de livros disponíveis
  static Future<List<Map<String, String>>> getBooksIndex() async {
    try {
      final String indexJson =
          await rootBundle.loadString('assets/data/books/index.json');
      final Map<String, dynamic> indexData = json.decode(indexJson);
      final List<dynamic> books = indexData['books'] ?? [];

      return books.map((book) => Map<String, String>.from(book)).toList();
    } catch (e) {
      throw Exception('Erro ao carregar índice da Bíblia: $e');
    }
  }

  /// Carrega um livro específico
  static Future<BibleBook> loadBook(String abbreviation) async {
    try {
      final String bookJson =
          await rootBundle.loadString('assets/data/books/$abbreviation.json');
      final Map<String, dynamic> bookData = json.decode(bookJson);

      return BibleBook.fromJson(bookData);
    } catch (e) {
      throw Exception('Erro ao carregar livro $abbreviation: $e');
    }
  }

  /// Carrega versículos de um capítulo específico
  static Future<List<BibleVerse>> getChapterVerses(
      String bookAbbrev, int chapter) async {
    try {
      final book = await loadBook(bookAbbrev);
      if (chapter > 0 && chapter <= book.chapters.length) {
        return book.chapters[chapter - 1].verses;
      }
      return [];
    } catch (e) {
      throw Exception(
          'Erro ao carregar capítulo $chapter do livro $bookAbbrev: $e');
    }
  }

  /// Busca versículos em toda a Bíblia (opcional - implementação básica)
  static Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final books = await getBooksIndex();
      final List<Map<String, dynamic>> results = [];

      for (final bookInfo in books) {
        final book = await loadBook(bookInfo['abbreviation']!);

        for (int chapterIndex = 0;
            chapterIndex < book.chapters.length;
            chapterIndex++) {
          final chapter = book.chapters[chapterIndex];

          for (final verse in chapter.verses) {
            if (verse.text.toLowerCase().contains(query.toLowerCase())) {
              results.add({
                'bookName': book.name,
                'bookAbbrev': book.abbreviation,
                'chapter': chapter.chapter,
                'verse': verse.verse,
                'text': verse.text,
              });
            }
          }
        }
      }

      return results;
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }
}
