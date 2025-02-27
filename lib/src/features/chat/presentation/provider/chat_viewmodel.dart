import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:buzz/src/core/injections/app_container.dart';
import 'package:buzz/src/features/chat/data/data.dart';
import 'package:buzz/src/features/chat/domain/models/models.dart';
import 'package:buzz/src/features/dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this.localStorage) {
    _loadChats();
    _initialiseController();
  }

  final LocalStorage localStorage;
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  String currentChatId = '';

  List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  ChatMessage? _repliedMessage;
  ChatMessage? get repliedMessage => _repliedMessage;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  String? mediaUrl;
  List<double>? audioWaveform;

  MessageType _messageType = MessageType.text;
  MessageType get messageType => _messageType;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool val) {
    _isLoading = val;
    Timer(Durations.short4, () {
      notifyListeners();
    });
  }

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Timer? timer;
  int _recordDuration = 0;
  int get recordDuration => _recordDuration;
  late final RecorderController recorderController;

  File? _audioFile;

  File? get audioFile => _audioFile;

  set audioFile(File? audioFile) {
    _audioFile = audioFile;
    notifyListeners();
  }

  // Load chats from local storage
  void _loadChats() async {
    debugPrint("Loading chats...");
    try {
      _chats = await localStorage.getChats();
      if (_chats.isEmpty) {
        _chats = initialChats;
      }
      notifyListeners();
    } catch (e) {
      _showNotification("Failed to load chats: $e");
    }
  }

  // Load messages for a specific chat
  void loadMessages(String id) async {
    isLoading = true;
    try {
      _messages = await localStorage.getMessages(id);

      if (_messages.isEmpty) {
        _messages = initialMessages;
      }
      notifyListeners();
    } catch (e) {
      _showNotification("Failed to load messages: $e");
    } finally {
      isLoading = false;
    }
  }

  // Set typing indicator
  void setTypingIndicator(bool isTyping) {
    _isTyping = isTyping;
    notifyListeners();
  }

  // Set message type (text, image, video, etc.)
  void setMessageType(MessageType type) {
    _messageType = type;
    notifyListeners();
  }

  // Send a message
  void sendMessage(String text, GlobalKey<AnimatedListState> listKey) {
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      id: Random().nextInt(99999).toString(),
      text: text,
      isSentByMe: true,
      timestamp: DateTime.now(),
      type: messageType,
      mediaUrl: mediaUrl,
      audioWaveform: audioWaveform,
      replyToChatMessage: _repliedMessage?.text,
    );

    _addMessageToList(newMessage, listKey);
    _saveMessageToStorage(currentChatId, newMessage);
    _clearMessageFields(); // Clear fields after sending
    _showNotification("Message sent: $text");

    simulateIncomingMessage(listKey);
  }

  // Send a message with media
  void sendMessageWithMedia(
    List<XFile> mediaFiles,
    String text,
  ) {
    final file = mediaFiles.first;

    final newMessage = ChatMessage(
      id: Random().nextInt(99999).toString(),
      text: text,
      isSentByMe: true,
      timestamp: DateTime.now(),
      type: messageType,
      mediaUrl: file.path,
      replyToChatMessage: _repliedMessage?.text,
    );

    _addMessageToList(newMessage, listKey);
    _saveMessageToStorage(currentChatId, newMessage);
    _clearMessageFields();
    _showNotification("Media message sent");

    simulateIncomingMessage(listKey);
  }

  // Add a message to the list and animate it
  void _addMessageToList(
      ChatMessage message, GlobalKey<AnimatedListState> listKey) {
    _messages.add(message);
    listKey.currentState?.insertItem(_messages.length - 1,
        duration: Duration(milliseconds: 300));
    notifyListeners();
  }

  // Save a message to local storage
  void _saveMessageToStorage(String chatId, ChatMessage message) {
    try {
      localStorage.saveMessages(chatId, _messages);
    } catch (e) {
      _showNotification("Failed to save message: $e");
    }
  }

  // Clear message fields after sending
  void _clearMessageFields() {
    mediaUrl = null;
    audioWaveform = null;
    _repliedMessage = null;
    notifyListeners();
  }

  // Save chats to local storage
  void saveChat(List<Chat> chats) {
    try {
      for (var chat in chats) {
        localStorage.saveChat(chat);
      }
      notifyListeners();
      _showNotification("Chat saved successfully");
    } catch (e) {
      _showNotification("Failed to save chat: $e");
    }
  }

  // Delete a message
  void deleteMessage(String id, String chatId) {
    try {
      _messages.removeWhere((msg) => msg.id == id);
      localStorage.deleteMessage(chatId, id);
      notifyListeners();
      _showNotification("Message deleted");
    } catch (e) {
      _showNotification("Failed to delete message: $e");
    }
  }

  // Delete a chat
  void deleteChat(String chatId) {
    try {
      _chats.removeWhere((chat) => chat.id == chatId);
      localStorage.deleteChat(chatId);
      notifyListeners();
      _showNotification("Chat deleted");
    } catch (e) {
      _showNotification("Failed to delete chat: $e");
    }
  }

  // Set a message as a reply
  void setReplyMessage(ChatMessage message) {
    _repliedMessage = message;
    notifyListeners();
    _showNotification("Replying to: ${message.text}");
  }

  // Simulate an incoming message
  void simulateIncomingMessage(GlobalKey<AnimatedListState> listKey) async {
    setTypingIndicator(true);
    await Future.delayed(Duration(seconds: 2));
    final r = Random().nextInt(dummyReplyMessages.length - 1);
    final newMessage = dummyReplyMessages[r];
    _addMessageToList(newMessage, listKey);
    setTypingIndicator(false);
    _showNotification("New message: ${newMessage.text}");
  }

  void _initialiseController() async {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;
  }

  void startRecording() async {
    try {
      await recorderController.checkPermission();
      if (recorderController.hasPermission) {
        await recorderController.record();

        _isRecording = true;

        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _recordDuration++;
          notifyListeners();
        });
      }
    } catch (e, stackTrace) {
      debugPrint(stackTrace.toString());
    }
  }

  Future<bool> stopRecording() async {
    try {
      final res = await recorderController.stop();

      debugPrint("The result is $res");
      _isRecording = false;
      debugPrint(isRecording.toString());
      _recordDuration = 0;

      timer?.cancel();

      _audioFile = (File(res!));

      notifyListeners();
      if (_audioFile != null) {
        sendMessageWithMedia([XFile(audioFile!.path)], '');
      }
      return _audioFile != null;
    } catch (e) {
      return false;
    }
  }

  void pauseRecording() async {
    try {
      await recorderController.pause();
      timer?.cancel();

      // _isRecording = false;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  // Show a notification
  void _showNotification(String message) async {
    notificationService.showNotification(0, "Новое сообщение", message);
  }

  @override
  void dispose() {
    timer?.cancel();
    recorderController.dispose();
    super.dispose();
  }
}
