// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:buzz/src/features/chat/domain/models/type.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class ChatMessage {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final bool isSentByMe;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? replyToChatMessage;

  @HiveField(5)
  final MessageType type;

  @HiveField(6)
  final String? mediaUrl;

  @HiveField(7)
  final List<double>? audioWaveform;
  ChatMessage({
    required this.id,
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.replyToChatMessage,
    required this.type,
    this.mediaUrl,
    this.audioWaveform,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isSentByMe,
    DateTime? timestamp,
    String? replyToChatMessage,
    MessageType? type,
    String? mediaUrl,
    List<double>? audioWaveform,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      timestamp: timestamp ?? this.timestamp,
      replyToChatMessage: replyToChatMessage ?? this.replyToChatMessage,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      audioWaveform: audioWaveform ?? this.audioWaveform,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'isSentByMe': isSentByMe,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'replyToChatMessage': replyToChatMessage,
      'type': type,
      'mediaUrl': mediaUrl,
      'audioWaveform': audioWaveform,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      text: map['text'] as String,
      isSentByMe: map['isSentByMe'] as bool,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      replyToChatMessage: map['replyToChatMessage'] != null
          ? map['replyToChatMessage'] as String
          : null,
      type: map['type'] as MessageType,
      mediaUrl: map['mediaUrl'] != null ? map['mediaUrl'] as String : null,
      audioWaveform: map['audioWaveform'] != null
          ? List<double>.from((map['audioWaveform'] as List<double>))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessage.fromJson(String source) =>
      ChatMessage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatMessage(id: $id, text: $text, isSentByMe: $isSentByMe, timestamp: $timestamp, replyToChatMessage: $replyToChatMessage, type: $type, mediaUrl: $mediaUrl, audioWaveform: $audioWaveform)';
  }

  @override
  bool operator ==(covariant ChatMessage other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.text == text &&
        other.isSentByMe == isSentByMe &&
        other.timestamp == timestamp &&
        other.replyToChatMessage == replyToChatMessage &&
        other.type == type &&
        other.mediaUrl == mediaUrl &&
        listEquals(other.audioWaveform, audioWaveform);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        isSentByMe.hashCode ^
        timestamp.hashCode ^
        replyToChatMessage.hashCode ^
        type.hashCode ^
        mediaUrl.hashCode ^
        audioWaveform.hashCode;
  }
}
