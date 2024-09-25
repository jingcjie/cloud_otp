import 'package:otp/otp.dart';

class OtpItem {
  final String label;
  final String secret;
  final String issuer;
  final int length;
  final int interval;
  final Algorithm algorithm;

  OtpItem({
    required this.label,
    required this.secret,
    required this.issuer,
    this.length = 6,
    this.interval = 30,
    this.algorithm = Algorithm.SHA1,
  });

  factory OtpItem.fromUri(String uri) {
    final parsedUri = Uri.parse(uri);
    final String label = Uri.decodeComponent(parsedUri.path.substring(1));
    final secret = parsedUri.queryParameters['secret'] ?? '';
    final issuer = parsedUri.queryParameters['issuer'] ?? '';
    final length = int.tryParse(parsedUri.queryParameters['digits'] ?? '6') ?? 6;
    final interval = int.tryParse(parsedUri.queryParameters['period'] ?? '30') ?? 30;
    final algorithm = _parseAlgorithm(parsedUri.queryParameters['algorithm']);

    return OtpItem(
      label: label,
      secret: secret,
      issuer: issuer,
      length: length,
      interval: interval,
      algorithm: algorithm,
    );
  }

  static Algorithm _parseAlgorithm(String? algorithmStr) {
    switch (algorithmStr?.toUpperCase()) {
      case 'SHA256':
        return Algorithm.SHA256;
      case 'SHA512':
        return Algorithm.SHA512;
      default:
        return Algorithm.SHA1;
    }
  }
}
