

part of 'chat_cubit.dart';

enum ChatStatus { initial, loading, success, failure }

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatMessage> messages,
    @Default(ChatStatus.initial) ChatStatus status,
  }) = _ChatState;

   static ChatState initial() => const ChatState(
        messages: [],
        status: ChatStatus.success,
      );
}
