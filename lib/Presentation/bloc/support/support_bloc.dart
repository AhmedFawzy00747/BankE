import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/usecases/send_message.dart';

// Events
abstract class SupportEvent extends Equatable {
  const SupportEvent();
  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends SupportEvent {
  final String text;
  final String? attachmentPath;
  const SendMessageEvent(this.text, {this.attachmentPath});
  @override
  List<Object?> get props => [text, attachmentPath];
}

class SelectQuickActionIconEvent extends SupportEvent {
  final String action;
  const SelectQuickActionIconEvent(this.action);
  @override
  List<Object?> get props => [action];
}

// State
class SupportState extends Equatable {
  final List<MessageEntity> messages;
  final bool isBotTyping;

  const SupportState({
    this.messages = const [],
    this.isBotTyping = false,
  });

  SupportState copyWith({
    List<MessageEntity>? messages,
    bool? isBotTyping,
  }) {
    return SupportState(
      messages: messages ?? this.messages,
      isBotTyping: isBotTyping ?? this.isBotTyping,
    );
  }

  @override
  List<Object?> get props => [messages, isBotTyping];
}

// BLoC
class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final SendMessageUseCase sendMessageUseCase;
  final _uuid = const Uuid();

  SupportBloc({required this.sendMessageUseCase}) : super(const SupportState()) {
    on<SendMessageEvent>(_onSendMessage);
    on<SelectQuickActionIconEvent>(_onQuickAction);

    // Initial greeting
    emit(state.copyWith(
      messages: [
        MessageEntity(
          id: _uuid.v4(),
          text: "Hi there! I'm your Contro virtual assistant. How can I help you today?",
          isUser: false,
          timestamp: DateTime.now(),
        )
      ]
    ));
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<SupportState> emit) async {
    final userMessage = MessageEntity(
      id: _uuid.v4(),
      text: event.text,
      isUser: true,
      timestamp: DateTime.now(),
      attachmentPath: event.attachmentPath,
    );

    emit(state.copyWith(
      messages: List.from(state.messages)..add(userMessage),
      isBotTyping: true,
    ));

    try {
      // Simulate smarter AI response logic based on keywords
      final botResponse = await _getSmartResponse(event.text);
      
      emit(state.copyWith(
        messages: List.from(state.messages)..add(botResponse),
        isBotTyping: false,
      ));
    } catch (_) {
       emit(state.copyWith(
        messages: List.from(state.messages)..add(
          MessageEntity(
            id: _uuid.v4(),
            text: "Sorry, I am having trouble connecting to the network.",
            isUser: false,
            timestamp: DateTime.now(),
          )
        ),
        isBotTyping: false,
      ));
    }
  }

  Future<void> _onQuickAction(SelectQuickActionIconEvent event, Emitter<SupportState> emit) async {
    add(SendMessageEvent(event.action));
  }

  Future<MessageEntity> _getSmartResponse(String text) async {
    // Artificial delay to feel natural
    await Future.delayed(const Duration(seconds: 2));
    
    String responseText = "I'm sorry, I didn't quite understand that. Could you please rephrase?";
    final input = text.toLowerCase();

    if (input.contains('loan')) {
      responseText = "You can apply for a loan in the 'Loans' section on the dashboard. Would you like me to explain the requirements?";
    } else if (input.contains('card')) {
      responseText = "Your card management is available under the 'Cards' tab. You can freeze, unfreeze, or change your PIN there.";
    } else if (input.contains('transfer')) {
      responseText = "To transfer money, use the 'Transfer' button on the main screen. You can send to existing beneficiaries or add new ones.";
    } else if (input.contains('points') || input.contains('rewards')) {
      responseText = "You earn loyalty points for every transaction. Check your 'Rewards' section to redeem them for vouchers!";
    } else if (input.contains('limit')) {
      responseText = "You can adjust your daily transfer limits in 'Settings' -> 'Advanced Settings'.";
    }

    return MessageEntity(
      id: _uuid.v4(),
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
