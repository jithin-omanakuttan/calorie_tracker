
import 'package:freezed_annotation/freezed_annotation.dart';

import '../db/item_entity.dart';
import '../db/meal_entity.dart';
import '../db/totals_entity.dart';
import '../main.dart';
import '../objectbox.g.dart';
import '../services/openai_service.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_state.dart';
part 'chat_cubit.freezed.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super( ChatState.initial());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    emit(state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(isUser: true, text: text),
      ],
      status: ChatStatus.loading,
    ));
    try {
      final aiResponseJson = await OpenAIService.sendMealDescription(text);
      emit(state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(isUser: false, text: aiResponseJson),
        ],
        status: ChatStatus.success,
      ));
      await _parseAndStoreMeal(aiResponseJson);
    } catch (e) {
      emit(state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(isUser: false, text: 'Error: ${e.toString()}'),
        ],
        status: ChatStatus.failure,
      ));
    }
  }

  Future<void> _parseAndStoreMeal(String jsonString) async {
    final decoded = jsonDecode(jsonString);
    final mealType = decoded['meal'] as String;
    final dateStr = decoded['date'] as String;
    final date = DateTime.parse(dateStr);
    final mealEntity = MealEntity(mealType: mealType, date: date);
    final totalsMap = decoded['totals'] as Map<String, dynamic>;
    final totalsEntity = TotalsEntity(
      calories: (totalsMap['calories'] as num).toInt(),
      proteinG: (totalsMap['protein_g'] as num).toDouble(),
      fatG: (totalsMap['fat_g'] as num).toDouble(),
      carbohydratesG: (totalsMap['carbohydrates_g'] as num).toDouble(),
      fiberG: (totalsMap['fiber_g'] as num).toDouble(),
      sugarG: (totalsMap['sugar_g'] as num).toDouble(),
    );
    final itemsList = decoded['items'] as List<dynamic>;
    final itemEntities = <ItemEntity>[];
    for (final itemMap in itemsList) {
      itemEntities.add(ItemEntity(
        name: itemMap['name'] as String,
        quantity: (itemMap['quantity'] as num).toInt(),
        details: itemMap['details'] as String,
      ));
    }
    final mealBox = store.box<MealEntity>();
    final itemBox = store.box<ItemEntity>();
    final totalsBox = store.box<TotalsEntity>();
    store.runInTransaction(TxMode.write, () {
      final mealId = mealBox.put(mealEntity);
      totalsEntity.meal.target = mealEntity;
      totalsBox.put(totalsEntity);
      for (final it in itemEntities) {
        it.meal.target = mealEntity;
        itemBox.put(it);
      }
    });
  }
}

class ChatMessage {
  final bool isUser;
  final String text;
  ChatMessage({required this.isUser, required this.text});
}
