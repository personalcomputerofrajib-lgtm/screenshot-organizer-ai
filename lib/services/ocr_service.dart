import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  TextRecognizer? _textRecognizer;

  TextRecognizer get textRecognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Extract text from an image file.
  ///
  /// Returns the full extracted text as a string.
  /// Returns empty string if file not found or on benign errors.
  /// Re-throws errors that signal the ML model is not ready (so the caller can
  /// show a "model still loading" message rather than silently skipping).
  Future<String> extractText(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      return '';
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      final err = e.toString().toLowerCase();

      // Re-throw if model is still initialising / downloading
      if (err.contains('waiting') ||
          err.contains('download') ||
          err.contains('internal') ||
          err.contains('not ready') ||
          err.contains('initializ')) {
        rethrow;
      }

      // For corrupt/unreadable images just return empty so we don't block the queue
      debugPrint('[OCR] Failed to process $imagePath: $e');
      return '';
    }
  }

  /// Extract text with block-level details.
  Future<OcrResult> extractTextDetailed(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return OcrResult.empty();
      }

      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      final blocks = <OcrTextBlock>[];
      for (final block in recognizedText.blocks) {
        blocks.add(OcrTextBlock(
          text: block.text,
          lines: block.lines.map((l) => l.text).toList(),
          confidence: block.lines.isNotEmpty
              ? block.lines
                      .map((l) => l.confidence ?? 0.0)
                      .reduce((a, b) => a + b) /
                  block.lines.length
              : 0.0,
        ));
      }

      return OcrResult(
        fullText: recognizedText.text,
        blocks: blocks,
        blockCount: recognizedText.blocks.length,
      );
    } catch (e) {
      debugPrint('[OCR] Detailed extraction failed: $e');
      return OcrResult.empty();
    }
  }

  /// Check if an image has very little or no text (likely a meme or photo)
  Future<bool> hasMinimalText(String imagePath) async {
    final text = await extractText(imagePath);
    return text.trim().length < 20;
  }

  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}

class OcrResult {
  final String fullText;
  final List<OcrTextBlock> blocks;
  final int blockCount;

  OcrResult({
    required this.fullText,
    required this.blocks,
    required this.blockCount,
  });

  factory OcrResult.empty() => OcrResult(
        fullText: '',
        blocks: [],
        blockCount: 0,
      );

  bool get isEmpty => fullText.trim().isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class OcrTextBlock {
  final String text;
  final List<String> lines;
  final double confidence;

  OcrTextBlock({
    required this.text,
    required this.lines,
    required this.confidence,
  });
}
