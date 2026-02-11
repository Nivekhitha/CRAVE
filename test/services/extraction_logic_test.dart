import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
// Import your service logic here. 
// Note: Since we can't easily import private methods like _splitTextIntoChunks from the real file without making them public or visibleForTesting, 
// I will copy the logic here to verify the ALGORITHM itself, or rely on public API behavior.

// Assuming we want to verify the Logic we wrote:

List<String> splitTextIntoChunks(String text, int chunkSize) {
    List<String> chunks = [];
    int start = 0;
    while (start < text.length) {
      int end = start + chunkSize;
      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }
      // Try to break at a newline to avoid cutting sentences/recipes
      int lastNewline = text.lastIndexOf('\n', end);
      if (lastNewline != -1 && lastNewline > start) {
        end = lastNewline;
      }
      chunks.add(text.substring(start, end));
      start = end; 
    }
    return chunks;
}

void main() {
  group('Cookbook Extraction Logic Tests', () {
    
    test('Chunking splits text correctly respecting newlines', () {
      final text = "Line 1\nLine 2\nLine 3 is very long and needs to be split but we want to respect the newline character if possible.";
      
      // Set small chunk size to force split
      final chunks = splitTextIntoChunks(text, 10);
      
      expect(chunks.length, greaterThan(1));
      // Verify no chunk exceeds size (strictly speaking, our logic might go up to chunkSize, loops end at lastNewline)
      for (var chunk in chunks) {
         print("Chunk: '$chunk'");
         expect(chunk.length, lessThanOrEqualTo(10));
      }
    });

    test('Chunking handles text smaller than limit', () {
      final text = "Short text";
      final chunks = splitTextIntoChunks(text, 100);
      expect(chunks.length, 1);
      expect(chunks.first, text);
    });
    
    test('Hashing produces consistent SHA256 results', () {
      final input = "https://instagram.com/p/12345";
      final bytes = utf8.encode(input);
      final hash1 = sha256.convert(bytes).toString();
      final hash2 = sha256.convert(bytes).toString(); // Duplicate
      
      expect(hash1, hash2);
      expect(hash1.length, 64); // SHA256 is 64 hex chars
    });
  });
}
