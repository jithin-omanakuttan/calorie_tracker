import 'dart:convert';
import 'package:calorie_chat_app/main.dart';
import 'package:http/http.dart' as http;

/// Replace with your OpenAI or Gemini API endpoint and key:
const _apiBaseUrl = "https://api.openai.com/v1/chat/completions";


class OpenAIService {
  /// Sends a free‐text meal description (e.g. “I had 4 chapathis and two pieces of chicken”) to the model.
  /// Expects the model to return a JSON string matching the format:
  /// {
  ///   "meal": "Breakfast",
  ///   "date": "2025-05-31",
  ///   "items": [ { ... }, ... ],
  ///   "totals": { ... }
  /// }
  static Future<String> sendMealDescription(String userMessage) async {
    // 1. Build the system prompt (forces JSON structure).
    final systemPrompt = '''
You are a calorie‐tracking assistant. When the user describes what they ate in free‐text, you must parse it and reply with a JSON object exactly in the following structure (no additional keys, no extraneous text):

{
  "meal": "<MealName>",
  "date": "<YYYY-MM-DD>",
  "items": [
    {
      "name": "<FoodItemName>",
      "quantity": <Integer>,
      "details": "<Approximate kcal, protein, fat, carbohydrates, fiber, sugar>"
    },
    ...
  ],
  "totals": {
    "calories": <Integer>,
    "protein_g": <Number>,
    "fat_g": <Number>,
    "carbohydrates_g": <Number>,
    "fiber_g": <Number>,
    "sugar_g": <Number>
  }
}

- Do not include any explanatory text or formatting other than the JSON object.
- Always set "date" to the current date in YYYY-MM-DD (use UTC+5:30 if necessary).
- Infer "meal" from context (e.g., “morning” → “Breakfast”, “evening” → “Dinner”, or accept exact user‐provided “Breakfast”, “Lunch”, etc.).
- For each “items” entry, estimate the approximate calories, protein_g, fat_g, carbohydrates_g, fiber_g, sugar_g as realistically as possible.
- The JSON must be valid. Use doubles for any decimal values, and integers for whole numbers.
    ''';

    // 2. Build the POST payload
    final Map<String, dynamic> payload = {
      "model": "gpt-4o-mini", // or "gpt-4o", or whichever model supports JSON parsing best
      "messages": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": userMessage}
      ],
      "temperature": 0.2,
      "max_tokens": 512,
    };

    final response = await http.post(
      Uri.parse(_apiBaseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded["choices"] as List<dynamic>;
      if (choices.isEmpty) throw Exception("No choices returned from API");
      final message = choices[0]["message"]["content"] as String;

      // The model might (rarely) wrap the JSON in code fences; strip those if present:
      final jsonString = _stripCodeFencesIfAny(message.trim());
      return jsonString;
    } else {
      throw Exception("OpenAI API Error: ${response.statusCode} ${response.body}");
    }
  }

  static String _stripCodeFencesIfAny(String text) {
    // If text starts with ```json or ``` and ends with ```, remove those fences.
    if (text.startsWith("```")) {
      final parts = text.split("```");
      // Could be ["", "json\n{…}", ""]
      for (final part in parts) {
        final trimmed = part.trimLeft();
        if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
          return trimmed;
        }
      }
    }
    return text;
  }
}
