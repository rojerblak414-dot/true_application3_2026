import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'document_type_detector.dart';

/// ExpenseModel only has amount / category / createdAt (no description
/// or reference-id field), so this result only carries what can actually
/// be saved. `description` and `refId` are returned anyway — useful for
/// a SnackBar hint or for a future duplicate-check feature — but the
/// UI does not need to persist them.
class OcrExpenseResult {
  final OcrDocType type;
  final double? amount;
  final DateTime? date;
  final String? description;
  final String? refId;
  final String suggestedCategory;

  OcrExpenseResult({
    required this.type,
    this.amount,
    this.date,
    this.description,
    this.refId,
    required this.suggestedCategory,
  });
}

class OcrParserService {
  static final _amountPattern = RegExp(
    r'([\d]{1,3}(?:,\d{3})+|\d+)\s*(LAK|ກີບ|K)\b',
    caseSensitive: false,
  );

  static final _datePattern = RegExp(
    r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?',
  );

  static final _refPattern = RegExp(r'[A-Z]{2,4}\d{8,}|\d{12,}');

  static OcrExpenseResult parse(RecognizedText recognizedText) {
    final rawText = recognizedText.text;
    final type = OcrDocTypeDetector.detect(rawText);

    final amount = _extractAmount(recognizedText);
    final date = _extractDate(rawText);
    final refId = _extractRef(rawText);

    String? description;
    String category;

    switch (type) {
      case OcrDocType.transfer:
        description = _extractTransferReceiver(rawText);
        category = 'ໂອນເງິນ'; // Transfer
        break;
      case OcrDocType.shipping:
        description = refId != null ? 'ຄ່າຂົນສົ່ງ: $refId' : 'ຄ່າຂົນສົ່ງ';
        category = 'ຂົນສົ່ງ'; // Shipping
        break;
      case OcrDocType.unknown:
        category = 'ອື່ນໆ'; // Other
        break;
    }

    return OcrExpenseResult(
      type: type,
      amount: amount,
      date: date,
      description: description,
      refId: refId,
      suggestedCategory: category,
    );
  }

  static double? _extractAmount(RecognizedText recognizedText) {
    double? bestValue;
    double bestHeight = -1;

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final match = _amountPattern.firstMatch(line.text);
        if (match != null) {
          final numStr = match.group(1)!.replaceAll(',', '');
          final value = double.tryParse(numStr);
          if (value != null) {
            final height = (line.boundingBox.bottom - line.boundingBox.top)
                .toDouble();
            if (height > bestHeight) {
              bestHeight = height;
              bestValue = value;
            }
          }
        }
      }
    }

    return bestValue;
  }

  static DateTime? _extractDate(String rawText) {
    final match = _datePattern.firstMatch(rawText);
    if (match == null) return null;

    try {
      var day = int.parse(match.group(1)!);
      var month = int.parse(match.group(2)!);
      var year = int.parse(match.group(3)!);
      if (year < 100) year += 2000;

      final hour = match.group(4) != null ? int.parse(match.group(4)!) : 0;
      final minute = match.group(5) != null ? int.parse(match.group(5)!) : 0;
      final second = match.group(6) != null ? int.parse(match.group(6)!) : 0;

      return DateTime(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
  }

  static String? _extractRef(String rawText) {
    final match = _refPattern.firstMatch(rawText);
    return match?.group(0);
  }

  static String? _extractTransferReceiver(String rawText) {
    final lines = rawText.split('\n');
    final nameLinePattern = RegExp(r'^[A-Z][A-Za-z\s.]{3,40}$');
    for (final line in lines) {
      final trimmed = line.trim();
      if (nameLinePattern.hasMatch(trimmed)) {
        return trimmed;
      }
    }
    return null;
  }
}
