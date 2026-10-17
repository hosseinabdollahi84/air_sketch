import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class OpenAiService {
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  static const _prompt = '''
You are a senior Flutter developer.
The image is a rough wireframe of a phone screen, drawn by hand in the air, so the lines are shaky and not straight.
Read it like this:
- big rectangles are cards, containers or sections
- small wide rectangles are buttons or text fields
- circles are avatars or icons
- short horizontal lines are text
- a box with an X inside is an image
- handwritten words are labels, use them as the real text
Build one complete, runnable Flutter screen with Material 3 that follows the same layout from top to bottom.
Make it look modern and polished, with good spacing and rounded corners.
Reply with Dart code only, in a single file that has a main() function. No explanation.
''';

  Future<String> sketchToFlutter({
    required String apiKey,
    required String model,
    required Uint8List image,
  }) async {
    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': _prompt},
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'text',
                    'text': 'Turn this sketch into Flutter code.',
                  },
                  {
                    'type': 'image_url',
                    'image_url': {
                      'url': 'data:image/png;base64,${base64Encode(image)}',
                    },
                  },
                ],
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 120));

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final message = (data['error'] as Map?)?['message'] ?? 'Request failed';
      throw Exception(message);
    }

    final content = data['choices'][0]['message']['content'] as String? ?? '';
    final fenced = RegExp(
      r'```(?:dart)?\s*\n([\s\S]*?)```',
    ).firstMatch(content);
    return (fenced?.group(1) ?? content).trim();
  }
}
