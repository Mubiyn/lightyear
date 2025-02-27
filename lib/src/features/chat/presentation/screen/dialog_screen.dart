import 'dart:developer';

import 'package:buzz/src/features/chat/presentation/provider/viewmodels.dart';
import 'package:buzz/src/features/dummy_data.dart';
import 'package:buzz/src/features/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_screen.dart';

class ChatDialogScreen extends StatefulWidget {
  const ChatDialogScreen({super.key});

  @override
  State<ChatDialogScreen> createState() => _ChatDialogScreenState();
}

class _ChatDialogScreenState extends State<ChatDialogScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) => Scaffold(
        appBar: AppBar(
          title: Text("Чаты", style: TextTheme.of(context).titleLarge),
          centerTitle: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: [SettingsView()],
        ),
        body: chatProvider.chats.isEmpty
            ? Center(child: Text('No Messages Yet'))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        hintText: "Search...",
                        fillColor: Theme.of(context).focusColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedList(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      key: _listKey,
                      initialItemCount: chatProvider.chats.length,
                      itemBuilder: (context, index, animation) {
                        final message = chatProvider.chats[index];
                        return SizeTransition(
                          sizeFactor: animation,
                          child: InkWell(
                            onTap: () {
                              chatProvider.loadMessages(message.id);
                              chatProvider.currentChatId = message.id;
                              log('index: ${chatProvider.chats[index].id}');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                          chat: message,
                                        )),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        spacing: 10,
                                        children: [
                                          CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(message.avatar),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message.name,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                message.lastMessage,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                        formatLastActive(message.lastActive),
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Divider(
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withValues(alpha: 0.2),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
