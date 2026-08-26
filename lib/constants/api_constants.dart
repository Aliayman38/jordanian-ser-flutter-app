/// API Configuration and Constants for Jordanian SER backend
class ApiConstants {
  ApiConstants._();

  /// The production backend domain
  static const String baseUrl = 'https://serios.eqratech.com';

  /// Endpoint paths
  static const String submitAudioEndpoint = '/api/submit-audio';
  static const String healthCheckEndpoint = '/';

  /// Request timeouts
  static const Duration uploadTimeout = Duration(seconds: 45);

  /// Default headers
  static const String userAgent = 'JordanianSERApp/Flutter';
}
