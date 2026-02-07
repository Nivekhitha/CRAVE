import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Utility class for generating consistent content hashes for caching
class ContentHasher {
  /// Generate SHA256 hash from string content
  static String hashString(String content) {
    final bytes = utf8.encode(content.trim());
    return sha256.convert(bytes).toString();
  }

  /// Generate SHA256 hash from file bytes
  static Future<String> hashFile(File file) async {
    final bytes = await file.readAsBytes();
    return sha256.convert(bytes).toString();
  }

  /// Generate hash from URL (normalized)
  static String hashUrl(String url) {
    // Normalize URL by removing query params and fragments for consistent caching
    final uri = Uri.parse(url);
    final cleanUrl = '${uri.scheme}://${uri.host}${uri.path}';
    return hashString(cleanUrl);
  }

  /// Generate composite hash from multiple inputs
  static String hashComposite(List<String> inputs) {
    final combined = inputs.join('|');
    return hashString(combined);
  }
}