enum OcrDocType { transfer, shipping, unknown }

class OcrDocTypeDetector {
  static final _transferKeywords = [
    'ໂອນເງິນ',
    'ສຳເລັດ',
    'ຈາກບັນຊີ',
    'ຫາບັນຊີ',
    'ONE',
    'LTC',
  ];

  static final _shippingKeywords = [
    'HAL',
    'ODI',
    'ຄ່າຝາກ',
    'ນ້ຳໜັກ',
    'ເລກທີ່ຕິດຕາມ',
  ];

  static final _trackingCodePattern = RegExp(r'[A-Z]{2,4}\d{8,}');

  static OcrDocType detect(String rawText) {
    final text = rawText.toUpperCase();

    final transferScore = _transferKeywords
        .where((k) => text.contains(k.toUpperCase()))
        .length;
    final shippingScore =
        _shippingKeywords.where((k) => text.contains(k.toUpperCase())).length +
        (_trackingCodePattern.hasMatch(rawText) ? 1 : 0);

    if (shippingScore > transferScore && shippingScore > 0) {
      return OcrDocType.shipping;
    }
    if (transferScore > 0) {
      return OcrDocType.transfer;
    }
    return OcrDocType.unknown;
  }
}
