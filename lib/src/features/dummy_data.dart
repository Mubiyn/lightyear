import 'dart:math';

import 'package:buzz/src/features/chat/domain/models/models.dart';
import 'package:intl/intl.dart';

final initialChats = [
  Chat(
    avatar: "https://i.pravatar.cc/300",
    isOnline: true,
    lastActive: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 2),
    lastMessage: 'Hola, how are you?',
    name: 'Irene Mendoza',
    unreadMessages: 2,
    id: Random().nextInt(10).toString(),
  ),
  Chat(
    avatar: "https://i.pravatar.cc/400",
    isOnline: true,
    lastActive: DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, DateTime.now().hour - 1),
    lastMessage: 'Hola, how are you?',
    name: 'John Snow',
    unreadMessages: 1,
    id: Random().nextInt(10).toString(),
  ),
  Chat(
    avatar: "https://i.pravatar.cc/200",
    isOnline: true,
    lastActive: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day - 1),
    lastMessage: 'Maria, how are you?',
    name: 'Maria Johnson',
    unreadMessages: 0,
    id: Random().nextInt(10).toString(),
  ),
  Chat(
    avatar: "https://i.pravatar.cc/100",
    isOnline: false,
    lastActive: DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
      DateTime.now().minute - 2,
    ),
    lastMessage: 'What is the status of the job?',
    name: 'Mendeley Grivstova',
    unreadMessages: 9,
    id: Random().nextInt(10).toString(),
  ),
];

final dummyReplyMessages = [
  ChatMessage(
      id: Random().nextInt(100).toString(),
      text: 'Hola, how are you?',
      isSentByMe: false,
      type: MessageType.text,
      timestamp: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day - 2)),
  ChatMessage(
      id: Random().nextInt(100).toString(),
      text: 'Hola, how are you?',
      isSentByMe: false,
      type: MessageType.image,
      mediaUrl: 'https://i.pravatar.cc/202',
      timestamp: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, DateTime.now().hour - 1)),
  ChatMessage(
      id: Random().nextInt(100).toString(),
      text: 'Hola, how are you?',
      isSentByMe: false,
      type: MessageType.image,
      mediaUrl: 'https://i.pravatar.cc/130',
      timestamp: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day - 1)),
  ChatMessage(
      id: Random().nextInt(100).toString(),
      text: 'Check out this image?',
      isSentByMe: false,
      type: MessageType.image,
      mediaUrl: 'https://i.pravatar.cc/200',
      timestamp: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        DateTime.now().hour,
        DateTime.now().minute - 2,
      )),
];

final initialMessages = [
  ChatMessage(
      id: Random().nextInt(100).toString(),
      text: 'Hola, how are you?',
      isSentByMe: false,
      type: MessageType.text,
      timestamp: DateTime.now()),
  ChatMessage(
      id: Random().nextInt(100).toString(),
      text: 'What have you been upto?',
      isSentByMe: true,
      type: MessageType.text,
      timestamp: DateTime.now()),
  ChatMessage(
      id: Random().nextInt(100).toString(),
      text: 'Checkout this image',
      isSentByMe: true,
      type: MessageType.image,
      mediaUrl: 'https://i.pravatar.cc/300',
      timestamp: DateTime.now()),
  ChatMessage(
      id: Random().nextInt(100).toString(),
      text: 'Hola, listen to this',
      isSentByMe: false,
      type: MessageType.image,
      mediaUrl: 'https://i.pravatar.cc/200',
      timestamp: DateTime.now()),
  // ChatMessage(
  //     id: '5',
  //     text: 'Hola, how are you?',
  //     isSentByMe: true,
  //     type: MessageType.video,
  //     mediaUrl: sampleVid,
  //     timestamp: DateTime.now())
];

String formatLastActive(DateTime lastActive) {
  final now = DateTime.now();
  final difference = now.difference(lastActive);

  if (difference.inDays == 0) {
    // Today: Show time for today
    if (difference.inHours < 1) {
      // Less than an hour ago
      if (difference.inMinutes == 1) {
        return '1 minute ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } else if (difference.inHours < 24) {
      // More than an hour but less than a day
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      // More than 1 hour today, show time
      return 'Today at ${DateFormat('h:mm a').format(lastActive)}';
    }
  } else if (difference.inDays == 1) {
    // Yesterday
    return 'Yesterday at ${DateFormat('h:mm a').format(lastActive)}';
  } else if (difference.inDays < 7) {
    // Day of the week (e.g., Monday)
    return DateFormat('EEEE, h:mm a').format(lastActive);
  } else if (now.year == lastActive.year) {
    // Last week
    return 'Last week at ${DateFormat('h:mm a').format(lastActive)}';
  } else if (now.year - lastActive.year == 1) {
    // Last year
    return 'Last year at ${DateFormat('h:mm a').format(lastActive)}';
  } else {
    // For older dates, show full date and time
    return DateFormat('d MMMM yyyy, h:mm a').format(lastActive);
  }
}

String formatDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$secs';
}
