import 'dart:convert';

import 'package:flutter/material.dart';
import '../db/item_entity.dart';
import '../db/totals_entity.dart';
import '../main.dart';
import '../objectbox.g.dart';
import '../services/openai_service.dart';
import '../db/meal_entity.dart';
import 'history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = []; // We'll define ChatMessage below
  late Store _store;

  @override
  void initState() {
    super.initState();
     _store = store;
  }

  @override
  void dispose() {
    _controller.dispose();
    _store.close();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 1. Add user message to chat
    setState(() {
      _messages.add(ChatMessage(
        isUser: true,
        text: text,
      ));
    });

    _controller.clear();

    // 2. Call the OpenAI service to get structured JSON
    try {
      final aiResponseJson = await OpenAIService.sendMealDescription(text);

      // 3. Add AI response to chat
      setState(() {
        _messages.add(ChatMessage(
          isUser: false,
          text: aiResponseJson, // JSON string returned by the service
        ));
      });

      // 4. Parse the JSON and store into ObjectBox
      await _parseAndStoreMeal(aiResponseJson);
    } catch (e) {
      // Show error in chat
      setState(() {
        _messages.add(ChatMessage(
          isUser: false,
          text: "Error: ${e.toString()}",
        ));
      });
    }
  }

  Future<void> _parseAndStoreMeal(String jsonString) async {
    /// We expect jsonString to match the format:
    /// {
    ///   "meal": "Breakfast",
    ///   "date": "2025-05-31",
    ///   "items": [ { "name": "...", "quantity": X, "details": "..." }, ... ],
    ///   "totals": {
    ///     "calories": 980,
    ///     "protein_g": 61,
    ///     "fat_g": 44,
    ///     "carbohydrates_g": 84,
    ///     "fiber_g": 8,
    ///     "sugar_g": 3
    ///   }
    /// }
    final decoded = jsonDecode(jsonString);

    // 1. Create MealEntity
    final mealType = decoded['meal'] as String;
    final dateStr = decoded['date'] as String;
    final date = DateTime.parse(dateStr);

    final mealEntity = MealEntity(mealType: mealType, date: date);

    // 2. Create TotalsEntity
    final totalsMap = decoded['totals'] as Map<String, dynamic>;
    final totalsEntity = TotalsEntity(
      calories: (totalsMap['calories'] as num).toInt(),
      proteinG: (totalsMap['protein_g'] as num).toDouble(),
      fatG: (totalsMap['fat_g'] as num).toDouble(),
      carbohydratesG: (totalsMap['carbohydrates_g'] as num).toDouble(),
      fiberG: (totalsMap['fiber_g'] as num).toDouble(),
      sugarG: (totalsMap['sugar_g'] as num).toDouble(),
    );

    // 3. Create ItemEntity objects
    final itemsList = decoded['items'] as List<dynamic>;
    final itemEntities = <ItemEntity>[];
    for (final itemMap in itemsList) {
      itemEntities.add(ItemEntity(
        name: itemMap['name'] as String,
        quantity: (itemMap['quantity'] as num).toInt(),
        details: itemMap['details'] as String,
      ));
    }

    // 4. Persist everything in ObjectBox in a single transaction
    final mealBox = _store.box<MealEntity>();
    final itemBox = _store.box<ItemEntity>();
    final totalsBox = _store.box<TotalsEntity>();

    _store.runInTransaction(TxMode.write, () {
      // Save meal first, because items & totals need its ID
      final mealId = mealBox.put(mealEntity);

      // Link and save TotalsEntity
      totalsEntity.meal.target = mealEntity;
      totalsBox.put(totalsEntity);

      // Link and save each ItemEntity
      for (final it in itemEntities) {
        it.meal.target = mealEntity;
        itemBox.put(it);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calorie Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen(store: _store)),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(
                  text: msg.text,
                  isUser: msg.isUser,
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "Describe your meal…",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple data class to hold chat messages:
class ChatMessage {
  final bool isUser;
  final String text;
  ChatMessage({required this.isUser, required this.text});
}

/// Simple chat bubble widget
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const ChatBubble({Key? key, required this.text, required this.isUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = isUser ? Colors.blue[200] : Colors.grey[300];
    final textColor = Colors.black87;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
