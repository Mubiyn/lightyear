import 'package:buzz/src/features/chat/domain/models/models.dart';
import 'package:buzz/src/features/dummy_data.dart';
import 'package:hive/hive.dart';
import 'dart:developer' as developer;

class LocalStorage {
  // Open the 'chats' box with a consistent type
  Future<Box<Chat>> _openChatsBox() async {
    try {
      if (!Hive.isBoxOpen('chats')) {
        developer.log('Opening chats box');
        return await Hive.openBox<Chat>('chats');
      }
      developer.log('Chats box already open');
      return Hive.box<Chat>('chats');
    } catch (e) {
      developer.log('Error opening chats box: $e');
      rethrow;
    }
  }

  // Open a message box for a specific chat
  Future<Box<ChatMessage>> _openMessageBox(String chatId) async {
    try {
      if (!Hive.isBoxOpen('messages_$chatId')) {
        developer.log('Opening messages box for chat $chatId');
        return await Hive.openBox<ChatMessage>('messages_$chatId');
      }
      developer.log('Messages box for chat $chatId already open');
      return Hive.box<ChatMessage>('messages_$chatId');
    } catch (e) {
      developer.log('Error opening messages box for chat $chatId: $e');
      rethrow;
    }
  }

  // Save a chat
  Future<void> saveChat(Chat chat) async {
    try {
      developer.log('Saving chat: ${chat.id}');
      var box = await _openChatsBox();
      await box.put(chat.id, chat); // Save chat with its ID as the key
      developer.log('Chat saved successfully');
    } catch (e) {
      developer.log('Error saving chat: $e');
      rethrow;
    }
  }

  Future<void> saveAllChat(List<Chat> chat) async {
    try {
      developer.log('Saving chats:');
      var box = await _openChatsBox();
      await box.addAll(chat); // Save chat with its ID as the key
      developer.log('Chats saved successfully');
    } catch (e) {
      developer.log('Error saving chat: $e');
      rethrow;
    }
  }

  // Save messages for a chat
  Future<void> saveMessages(String chatId, List<ChatMessage> messages) async {
    try {
      developer.log('Saving messages for chat $chatId');
      var box = await _openMessageBox(chatId);
      for (var message in messages) {
        await box.put(
            message.id, message); // Save each message with its ID as the key
      }
      developer.log('Messages saved successfully');
    } catch (e) {
      developer.log('Error saving messages: $e');
      rethrow;
    }
  }

  // Get all messages for a chat
  Future<List<ChatMessage>> getMessages(String chatId) async {
    try {
      developer.log('Retrieving messages for chat $chatId');
      var box = await _openMessageBox(chatId);
      final messages =
          box.values.toList(); // Retrieve all messages for the chat

      // Return default messages if no messages are found
      if (messages.isEmpty) {
        developer.log('No messages found, returning default messages');
        return _getDefaultMessages();
      }
      developer.log('Messages retrieved successfully');
      return messages;
    } catch (e) {
      developer.log('Error retrieving messages: $e');
      rethrow;
    }
  }

  // Delete a single message for a specific chat
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      developer.log('Deleting message $messageId for chat $chatId');
      var box = await _openMessageBox(chatId);
      await box.delete(messageId); // Delete the message by its ID
      developer.log('Message deleted successfully');
    } catch (e) {
      developer.log('Error deleting message: $e');
      rethrow;
    }
  }

  // Delete a chat and all its messages
  Future<void> deleteChat(String chatId) async {
    try {
      developer.log('Deleting chat $chatId');
      var chatBox = await _openChatsBox();
      var messageBox = await _openMessageBox(chatId);

      // Delete all messages for the chat
      await messageBox.clear();
      // Delete the chat
      await chatBox.delete(chatId);
      developer.log('Chat and messages deleted successfully');
    } catch (e) {
      developer.log('Error deleting chat: $e');
      rethrow;
    }
  }

  // Get all chats
  Future<List<Chat>> getChats() async {
    try {
      developer.log('Retrieving chats');
      var box = await _openChatsBox();
      final chats = box.values.toList(); // Retrieve all chats

      // Return default chats if no chats are found
      if (chats.isEmpty) {
        developer.log('No chats found, returning default chats');
        saveAllChat(_getDefaultChats());
        return getChats();
      }
      developer.log('Chats retrieved successfully');
      return chats;
    } catch (e) {
      developer.log('Error retrieving chats: $e');
      rethrow;
    }
  }

  // Default messages
  List<ChatMessage> _getDefaultMessages() {
    developer.log('Returning default messages');
    return initialMessages;
  }

  // Default chats
  List<Chat> _getDefaultChats() {
    developer.log('Returning default chats');
    return initialChats;
  }
}
