class ScreenshotModel {
  final int? id;
  final String imagePath;
  final String? extractedText;
  final String? category;
  final DateTime dateAdded;
  final DateTime? dateTaken;
  final bool isPinned;
  final bool isScanned;
  final String? fileHash;
  final String? thumbnailPath;

  ScreenshotModel({
    this.id,
    required this.imagePath,
    this.extractedText,
    this.category,
    required this.dateAdded,
    this.dateTaken,
    this.isPinned = false,
    this.isScanned = false,
    this.fileHash,
    this.thumbnailPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'extracted_text': extractedText,
      'category': category,
      'date_added': dateAdded.millisecondsSinceEpoch,
      'date_taken': dateTaken?.millisecondsSinceEpoch,
      'is_pinned': isPinned ? 1 : 0,
      'is_scanned': isScanned ? 1 : 0,
      'file_hash': fileHash,
      'thumbnail_path': thumbnailPath,
    };
  }

  factory ScreenshotModel.fromMap(Map<String, dynamic> map) {
    return ScreenshotModel(
      id: map['id'] as int?,
      imagePath: map['image_path'] as String,
      extractedText: map['extracted_text'] as String?,
      category: map['category'] as String?,
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['date_added'] as int),
      dateTaken: map['date_taken'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date_taken'] as int)
          : null,
      isPinned: (map['is_pinned'] as int?) == 1,
      isScanned: (map['is_scanned'] as int?) == 1,
      fileHash: map['file_hash'] as String?,
      thumbnailPath: map['thumbnail_path'] as String?,
    );
  }

  ScreenshotModel copyWith({
    int? id,
    String? imagePath,
    String? extractedText,
    String? category,
    DateTime? dateAdded,
    DateTime? dateTaken,
    bool? isPinned,
    bool? isScanned,
    String? fileHash,
    String? thumbnailPath,
  }) {
    return ScreenshotModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      category: category ?? this.category,
      dateAdded: dateAdded ?? this.dateAdded,
      dateTaken: dateTaken ?? this.dateTaken,
      isPinned: isPinned ?? this.isPinned,
      isScanned: isScanned ?? this.isScanned,
      fileHash: fileHash ?? this.fileHash,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  @override
  String toString() {
    return 'ScreenshotModel(id: $id, path: $imagePath, category: $category, pinned: $isPinned)';
  }
}
