import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterService {
  final String _baseUrl = "https://openrouter.ai/api/v1/chat/completions";

  Future<Map<String, dynamic>> fetchRecommendations({
    required String apiKey,
    required String model,
    required String systemPrompt,
    required Map<String, dynamic> telemetryPayload,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
          "HTTP-Referer": "https://aurasync.twin",
          "X-Title": "AuraSync Digital Twin",
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {"role": "system", "content": systemPrompt},
            {
              "role": "user",
              "content": "TELEMETRY METRICS:\n${const JsonEncoder.withIndent('  ').convert(telemetryPayload)}"
            }
          ],
          "temperature": 0.2
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final contentText = data['choices'][0]['message']['content'].toString().trim();

        // Extract JSON block if response is wrapped in markdown blocks
        String cleanedJson = contentText;
        if (contentText.contains('```')) {
          final regExp = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
          final match = regExp.firstMatch(contentText);
          if (match != null && match.group(1) != null) {
            cleanedJson = match.group(1)!;
          }
        }

        try {
          final List<dynamic> parsedList = jsonDecode(cleanedJson.trim());
          return {
            "success": true,
            "cards": parsedList,
            "raw": contentText,
          };
        } catch (e) {
          // If JSON parsing fails, wrap raw content in a warning card
          return {
            "success": true,
            "cards": [
              {
                "type": "warning",
                "tag": "AI DIAGNOSTIC RAW",
                "time": "JUST NOW",
                "title": "Unstructured AI Insights",
                "text": contentText.substring(0, contentText.length > 250 ? 250 : contentText.length)
              },
              {
                "type": "product",
                "tag": "SUSTAINABLE HARDWARE",
                "title": "AuraShield HEPA-9 Air Purifier",
                "text": "General HVAC and energy mitigation hardware recommended.",
                "price": "\$299.00",
                "originalPrice": "\$349.00",
                "rating": 4.8,
                "ratingCount": 110,
                "coupon": "HEPA9SHIELD"
              }
            ],
            "raw": contentText,
          };
        }
      } else {
        return {
          "success": false,
          "error": "HTTP Error: ${response.statusCode} - ${response.body}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }
}
