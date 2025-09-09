class BibleVerse {
  final int verse;
  final String text;

  BibleVerse({
    required this.verse,
    required this.text,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      verse: json['verse'] ?? json['number'] ?? 0,
      text: json['text'] ?? json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verse': verse,
      'text': text,
    };
  }
}

class BibleChapter {
  final int chapter;
  final List<BibleVerse> verses;

  BibleChapter({
    required this.chapter,
    required this.verses,
  });

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    return BibleChapter(
      chapter: json['chapter'] ?? json['number'] ?? 0,
      verses: (json['verses'] as List<dynamic>?)
              ?.map((verse) => BibleVerse.fromJson(verse))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter': chapter,
      'verses': verses.map((verse) => verse.toJson()).toList(),
    };
  }
}

class BibleBook {
  final String name;
  final String abbreviation;
  final List<BibleChapter> chapters;
  final bool isDeuterocanonical;

  BibleBook({
    required this.name,
    required this.abbreviation,
    required this.chapters,
    this.isDeuterocanonical = false,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      name: json['name'] ?? '',
      abbreviation: json['abbrev'] ?? json['abbreviation'] ?? '',
      chapters: (json['chapters'] as List<dynamic>?)
              ?.map((chapter) => BibleChapter.fromJson(chapter))
              .toList() ??
          [],
      isDeuterocanonical: json['isDeuterocanonical'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'abbreviation': abbreviation,
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
      'isDeuterocanonical': isDeuterocanonical,
    };
  }
}

class Bible {
  final String version;
  final String language;
  final List<BibleBook> books;

  Bible({
    required this.version,
    required this.language,
    required this.books,
  });

  factory Bible.fromJson(Map<String, dynamic> json) {
    return Bible(
      version: json['version'] ?? 'Bíblia Ave Maria',
      language: json['language'] ?? 'pt-BR',
      books: (json['books'] ?? json)
          .map<BibleBook>((book) => BibleBook.fromJson(book))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'language': language,
      'books': books.map((book) => book.toJson()).toList(),
    };
  }

  List<BibleBook> get oldTestament {
    const oldTestamentBooks = [
      'genesis',
      'exodus',
      'leviticus',
      'numbers',
      'deuteronomy',
      'joshua',
      'judges',
      'ruth',
      '1samuel',
      '2samuel',
      '1kings',
      '2kings',
      '1chronicles',
      '2chronicles',
      'ezra',
      'nehemiah',
      'tobit',
      'judith',
      'esther',
      '1maccabees',
      '2maccabees',
      'job',
      'psalms',
      'proverbs',
      'ecclesiastes',
      'song',
      'wisdom',
      'sirach',
      'isaiah',
      'jeremiah',
      'lamentations',
      'baruch',
      'ezekiel',
      'daniel',
      'hosea',
      'joel',
      'amos',
      'obadiah',
      'jonah',
      'micah',
      'nahum',
      'habakkuk',
      'zephaniah',
      'haggai',
      'zechariah',
      'malachi'
    ];

    return books
        .where((book) => oldTestamentBooks.any((otBook) =>
            book.name.toLowerCase().replaceAll(' ', '').contains(otBook) ||
            book.abbreviation
                .toLowerCase()
                .replaceAll(' ', '')
                .contains(otBook)))
        .toList();
  }

  List<BibleBook> get newTestament {
    const newTestamentBooks = [
      'matthew',
      'mark',
      'luke',
      'john',
      'acts',
      'romans',
      '1corinthians',
      '2corinthians',
      'galatians',
      'ephesians',
      'philippians',
      'colossians',
      '1thessalonians',
      '2thessalonians',
      '1timothy',
      '2timothy',
      'titus',
      'philemon',
      'hebrews',
      'james',
      '1peter',
      '2peter',
      '1john',
      '2john',
      '3john',
      'jude',
      'revelation'
    ];

    return books
        .where((book) => newTestamentBooks.any((ntBook) =>
            book.name.toLowerCase().replaceAll(' ', '').contains(ntBook) ||
            book.abbreviation
                .toLowerCase()
                .replaceAll(' ', '')
                .contains(ntBook)))
        .toList();
  }

  BibleBook? getBook(String nameOrAbbrev) {
    return books.firstWhere(
      (book) =>
          book.name.toLowerCase() == nameOrAbbrev.toLowerCase() ||
          book.abbreviation.toLowerCase() == nameOrAbbrev.toLowerCase(),
      orElse: () => books.firstWhere(
        (book) =>
            book.name.toLowerCase().contains(nameOrAbbrev.toLowerCase()) ||
            book.abbreviation
                .toLowerCase()
                .contains(nameOrAbbrev.toLowerCase()),
      ),
    );
  }

  BibleChapter? getChapter(String bookName, int chapterNumber) {
    final book = getBook(bookName);
    if (book == null ||
        chapterNumber < 1 ||
        chapterNumber > book.chapters.length) {
      return null;
    }
    return book.chapters[chapterNumber - 1];
  }

  BibleVerse? getVerse(String bookName, int chapter, int verse) {
    final chapterData = getChapter(bookName, chapter);
    if (chapterData == null || verse < 1 || verse > chapterData.verses.length) {
      return null;
    }
    return chapterData.verses[verse - 1];
  }
}
