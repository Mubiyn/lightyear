import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:buzz/src/core/injections/app_container.dart';
import 'package:buzz/src/features/chat/data/data.dart';
import 'package:buzz/src/features/chat/domain/models/models.dart';
import 'package:buzz/src/features/dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider(this._localStorage) {
    _initialize();
  }

  final LocalStorage _localStorage;

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

  MessageType _messageType = MessageType.text;
  MessageType get messageType => _messageType;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Timer? _timer;
  int _recordDuration = 0;
  int get recordDuration => _recordDuration;

  late final RecorderController recorderController;
  File? audioFile;

  // --- INITIALIZATION ---
  void _initialize() {
    _loadChats();
    _initializeRecorder();
  }

  void _initializeRecorder() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;
  }

  // --- LOADING CHATS & MESSAGES ---
  Future<void> _loadChats() async {
    try {
      _chats = await _localStorage.getChats();
      _chats = _chats.isEmpty ? initialChats : _chats;
      notifyListeners();
    } catch (e) {
      _showNotification("Failed to load chats: $e");
    }
  }

  Future<void> loadMessages(String chatId) async {
    _setLoading(true);
    try {
      _messages = await _localStorage.getMessages(chatId);
      _messages = _messages.isEmpty ? initialMessages : _messages;
      notifyListeners();
    } catch (e) {
      _showNotification("Failed to load messages: $e");
    } finally {
      _setLoading(false);
    }
  }

  // --- SETTERS & STATE UPDATES ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setTypingIndicator(bool isTyping) {
    _isTyping = isTyping;
    notifyListeners();
  }

  void setMessageType(MessageType type) {
    _messageType = type;
    notifyListeners();
  }

  void setReplyMessage(ChatMessage message) {
    _repliedMessage = message;
    notifyListeners();
    _showNotification("Replying to: ${message.text}");
  }

  // --- SENDING MESSAGES ---
  void sendMessage(String text) {
    if (text.isEmpty) return;

    final message = _createMessage(text);
    _addMessageToList(message);
    _saveMessageToStorage(message);
    _clearMessageFields();
    _showNotification("Message sent: $text");
    _simulateIncomingMessage();
  }

  void sendMessageWithMedia(List<XFile> mediaFiles, String text) {
    final file = mediaFiles.first;
    final message = _createMessage(text, mediaUrl: file.path);
    _addMessageToList(message);
    _saveMessageToStorage(message);
    _clearMessageFields();
    _showNotification("Media message sent");
    _simulateIncomingMessage();
  }

  ChatMessage _createMessage(String text, {String? mediaUrl}) {
    return ChatMessage(
      id: Random().nextInt(99999).toString(),
      text: text,
      isSentByMe: true,
      timestamp: DateTime.now(),
      type: _messageType,
      mediaUrl: mediaUrl,
      replyToChatMessage: _repliedMessage?.text,
    );
  }

  void _addMessageToList(ChatMessage message) {
    _messages.add(message);
    listKey.currentState?.insertItem(_messages.length - 1,
        duration: Duration(milliseconds: 300));
    notifyListeners();
  }

  void _saveMessageToStorage(ChatMessage message) {
    try {
      _localStorage.saveMessages(currentChatId, _messages);
    } catch (e) {
      _showNotification("Failed to save message: $e");
    }
  }

  void _clearMessageFields() {
    mediaUrl = null;
    _repliedMessage = null;
    notifyListeners();
  }

  // --- DELETING MESSAGES & CHATS ---
  void deleteMessage(String id) {
    _messages.removeWhere((msg) => msg.id == id);
    _localStorage.deleteMessage(currentChatId, id);
    notifyListeners();
    _showNotification("Message deleted");
  }

  void deleteChat(String chatId) {
    _chats.removeWhere((chat) => chat.id == chatId);
    _localStorage.deleteChat(chatId);
    notifyListeners();
    _showNotification("Chat deleted");
  }

  // --- SIMULATING INCOMING MESSAGES ---
  void _simulateIncomingMessage() async {
    setTypingIndicator(true);
    await Future.delayed(Duration(seconds: 2));
    final message =
        dummyReplyMessages[Random().nextInt(dummyReplyMessages.length)];
    _addMessageToList(message);
    setTypingIndicator(false);
    _showNotification("New message: ${message.text}");
  }

  // --- RECORDING AUDIO ---
  Future<void> startRecording() async {
    try {
      await recorderController.checkPermission();
      if (!recorderController.hasPermission) return;
      await recorderController.record();

      _isRecording = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordDuration++;
        notifyListeners();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> stopRecording() async {
    try {
      final result = await recorderController.stop();
      if (result == null) return false;

      audioFile = File(result);
      _isRecording = false;
      _recordDuration = 0;
      _timer?.cancel();
      notifyListeners();

      if (audioFile != null) {
        sendMessageWithMedia([XFile(audioFile!.path)], '');
      }
      return audioFile != null;
    } catch (e) {
      return false;
    }
  }

  void pauseRecording() async {
    try {
      await recorderController.pause();
      _timer?.cancel();
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // --- NOTIFICATIONS ---
  void _showNotification(String message) {
    notificationService.showNotification(0, "New Message", message);
  }

  // --- CLEANUP ---
  @override
  void dispose() {
    _timer?.cancel();
    recorderController.dispose();
    super.dispose();
  }
}
