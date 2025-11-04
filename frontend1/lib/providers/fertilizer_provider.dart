import 'package:flutter/material.dart';
import '../models/fertilizer.dart';
import '../models/chat_message.dart';
import '../data/fertilizer_data.dart';

class FertilizerProvider extends ChangeNotifier {
  String _selectedCrop = '';
  FertilizerInfo? _fertilizerInfo;
  final List<ChatMessage> _chatMessages = [
    const ChatMessage(role: 'bot', text: 'Ask a fertilizer question, e.g., "Tomato fertilizer"'),
  ];

  String get selectedCrop => _selectedCrop;
  FertilizerInfo? get fertilizerInfo => _fertilizerInfo;
  List<ChatMessage> get chatMessages => _chatMessages;

  void setSelectedCrop(String crop) {
    _selectedCrop = crop;
    _fertilizerInfo = fertilizerData[crop];
    notifyListeners();
  }

  void sendMessage(String input) {
    if (input.trim().isEmpty) return;
    
    final userMessage = ChatMessage(role: 'user', text: input);
    final botMessage = ChatMessage(role: 'bot', text: _answerQuestion(input));
    
    _chatMessages.addAll([userMessage, botMessage]);
    notifyListeners();
  }

  String _answerQuestion(String query) {
    final q = query.toLowerCase();
    
    for (final entry in fertilizerData.entries) {
      if (q.contains(entry.key.toLowerCase())) {
        final basal = entry.value.basal;
        return 'For ${entry.key}: Basal N-P-K ${basal.nitrogen}-${basal.phosphorus}-${basal.potash} kg/acre. Top dress as scheduled.';
      }
    }
    
    if (q.contains('hello') || q.contains('hi')) {
      return 'Hello! Ask me about fertilizer doses for a crop.';
    }
    
    return 'Sorry, I can answer basic fertilizer questions like: "Tomato fertilizer".';
  }
}
