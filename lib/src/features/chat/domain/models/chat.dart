import 'dart:convert';
import 'package:hive/hive.dart';

part 'chat.g.dart';

@HiveType(typeId: 1)
class Chat {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String lastMessage;

  @HiveField(3)
  final String avatar;

  @HiveField(4)
  final DateTime lastActive;

  @HiveField(5)
  final int unreadMessages;

  @HiveField(6)
  final bool isOnline;
  Chat({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.avatar,
    required this.lastActive,
    required this.unreadMessages,
    required this.isOnline,
  });

  Chat copyWith({
    String? id,
    String? name,
    String? lastMessage,
    String? avatar,
    DateTime? lastActive,
    int? unreadMessages,
    bool? isOnline,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      avatar: avatar ?? this.avatar,
      lastActive: lastActive ?? this.lastActive,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'avatar': avatar,
      'lastActive': lastActive.millisecondsSinceEpoch,
      'unreadMessages': unreadMessages,
      'isOnline': isOnline,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      name: map['name'] as String,
      lastMessage: map['lastMessage'] as String,
      avatar: map['avatar'] as String,
      lastActive: DateTime.fromMillisecondsSinceEpoch(map['lastActive'] as int),
      unreadMessages: map['unreadMessages'] as int,
      isOnline: map['isOnline'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) =>
      Chat.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Chat(id: $id, name: $name, lastMessage: $lastMessage, avatar: $avatar, lastActive: $lastActive, unreadMessages: $unreadMessages, isOnline: $isOnline)';
  }

  @override
  bool operator ==(covariant Chat other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.lastMessage == lastMessage &&
        other.avatar == avatar &&
        other.lastActive == lastActive &&
        other.unreadMessages == unreadMessages &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        lastMessage.hashCode ^
        avatar.hashCode ^
        lastActive.hashCode ^
        unreadMessages.hashCode ^
        isOnline.hashCode;
  }
}
