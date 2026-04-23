import 'dart:math';

class UuidGenerator {
  static final _random = Random();

  static String generate() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = _random.nextInt(999999).toString().padLeft(6, '0');
    return '$ts$rand';
  }
}
