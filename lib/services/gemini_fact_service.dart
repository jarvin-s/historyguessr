import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiFactService {
  GeminiFactService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _model = 'gemini-2.5-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models';

  Future<String?> fetchFact(String figureName) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('GEMINI_API_KEY is not set.');
      return null;
    }

    final uri = Uri.parse('$_endpoint/$_model:generateContent?key=$apiKey');
    final prompt =
        'Share one interesting, lesser-known, and verifiable fact about the '
        'historical figure $figureName. Respond with a single concise '
        'sentence and no preamble.';

    try {
      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.9,
            'maxOutputTokens': 256,
            // Simple one-sentence facts don't need thinking; without this,
            // gemini-2.5-flash can spend the token budget on internal
            // reasoning and return only a few visible words.
            'thinkingConfig': {
              'thinkingBudget': 0,
            },
          },
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(
          'Gemini fact request failed (${response.statusCode}): ${response.body}',
        );
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return _extractResponseText(body);
    } catch (error) {
      debugPrint('Gemini fact request error: $error');
      return null;
    }
  }

  String? _extractResponseText(Map<String, dynamic> body) {
    final candidates = body['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      return null;
    }

    final candidate = candidates.first as Map<String, dynamic>;
    final finishReason = candidate['finishReason'] as String?;
    if (finishReason == 'MAX_TOKENS') {
      debugPrint('Gemini fact response was truncated (MAX_TOKENS).');
    }

    final content = candidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      return null;
    }

    final textParts = <String>[];
    for (final part in parts) {
      if (part is! Map<String, dynamic>) {
        continue;
      }

      // Skip internal reasoning chunks; only keep the user-visible answer.
      if (part['thought'] == true) {
        continue;
      }

      final text = part['text'] as String?;
      if (text != null && text.trim().isNotEmpty) {
        textParts.add(text.trim());
      }
    }

    if (textParts.isEmpty) {
      return null;
    }

    return textParts.join(' ');
  }
}
