import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/bible.dart';

class SimpleBibleScreen extends StatefulWidget {
  const SimpleBibleScreen({super.key});

  @override
  State<SimpleBibleScreen> createState() => _SimpleBibleScreenState();
}

class _SimpleBibleScreenState extends State<SimpleBibleScreen> {
  List<Map<String, String>> booksIndex = [];
  BibleBook? currentBook;
  int currentChapter = 1;
  List<BibleVerse> currentVerses = [];
  bool isLoading = false;
  double fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadBooksIndex();
  }

  Future<void> _loadBooksIndex() async {
    try {
      final String indexJson =
          await rootBundle.loadString('assets/data/books/index.json');
      final Map<String, dynamic> indexData = json.decode(indexJson);
      final List<dynamic> books = indexData['books'] ?? [];

      setState(() {
        booksIndex =
            books.map((book) => Map<String, String>.from(book)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar índice da Bíblia: $e')),
      );
    }
  }

  Future<void> _loadBook(String abbreviation, {int chapter = 1}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final String bookJson =
          await rootBundle.loadString('assets/data/books/$abbreviation.json');
      final Map<String, dynamic> bookData = json.decode(bookJson);

      final book = BibleBook.fromJson(bookData);
      final chapterData = book.chapters[chapter - 1];

      setState(() {
        currentBook = book;
        currentChapter = chapter;
        currentVerses = chapterData.verses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar livro: $e')),
      );
    }
  }

  void _showBookSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Selecionar Livro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: booksIndex.length,
                itemBuilder: (context, index) {
                  final book = booksIndex[index];
                  return ListTile(
                    title: Text(book['name']!),
                    onTap: () {
                      Navigator.pop(context);
                      _loadBook(book['abbreviation']!);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChapterSelector() {
    if (currentBook == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Capítulos - ${currentBook!.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.5,
                ),
                itemCount: currentBook!.chapters.length,
                itemBuilder: (context, index) {
                  final chapterNum = index + 1;
                  return Card(
                    color: chapterNum == currentChapter ? Colors.blue : null,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _loadBook(currentBook!.abbreviation,
                            chapter: chapterNum);
                      },
                      child: Center(
                        child: Text(
                          chapterNum.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: chapterNum == currentChapter
                                ? Colors.white
                                : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextChapter() {
    if (currentBook != null && currentChapter < currentBook!.chapters.length) {
      _loadBook(currentBook!.abbreviation, chapter: currentChapter + 1);
    }
  }

  void _previousChapter() {
    if (currentChapter > 1) {
      _loadBook(currentBook!.abbreviation, chapter: currentChapter - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bíblia Católica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Tamanho da Fonte'),
                  content: StatefulBuilder(
                    builder: (context, setState) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${fontSize.toInt()}px'),
                        Slider(
                          value: fontSize,
                          min: 12,
                          max: 24,
                          divisions: 12,
                          onChanged: (value) {
                            setState(() {
                              fontSize = value;
                            });
                            this.setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de navegação
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: const Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _showBookSelector,
                  child: Text(currentBook?.name ?? 'Selecionar Livro'),
                ),
                const SizedBox(width: 8),
                if (currentBook != null) ...[
                  ElevatedButton(
                    onPressed: _showChapterSelector,
                    child: Text('Cap. $currentChapter'),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: currentChapter > 1 ? _previousChapter : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    onPressed: currentBook != null &&
                            currentChapter < currentBook!.chapters.length
                        ? _nextChapter
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ],
            ),
          ),
          // Conteúdo
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : currentVerses.isEmpty
                    ? const Center(
                        child: Text(
                          'Selecione um livro para começar a leitura',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: currentVerses.length,
                        itemBuilder: (context, index) {
                          final verse = currentVerses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: Colors.black,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${verse.verse} ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  TextSpan(text: verse.text),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
