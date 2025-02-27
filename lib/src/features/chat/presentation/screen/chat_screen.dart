import 'package:buzz/src/core/assets/assets.dart';
import 'package:buzz/src/features/chat/domain/models/models.dart';
import 'package:buzz/src/features/chat/presentation/provider/viewmodels.dart';
import 'package:buzz/src/features/chat/presentation/widgets/attachment_pop.dart';
import 'package:buzz/src/features/chat/presentation/widgets/audio.dart';
import 'package:buzz/src/features/chat/presentation/widgets/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.chat});
  final Chat chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load messages for the chat
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.loadMessages(widget.chat.id);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    var scaffold = Scaffold(
      appBar: buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            !chatProvider.isLoading
                ? _buildChatList(chatProvider)
                : Center(child: CircularProgressIndicator.adaptive()),
            if (chatProvider.isTyping)
              Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                        child: Text(
                            '${widget.chat.name[0]} ${widget.chat.name[1]}'
                                .toUpperCase())),
                    SizedBox(width: 8),
                    Text("Typing......",
                        style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            _buildBottomWidgets(context, chatProvider),
          ],
        ),
      ),
    );
    return scaffold;
  }

  Padding _buildBottomWidgets(BuildContext context, ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: chatProvider.isRecording
          ? VoiceNoteWidget()
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: SvgPicture.asset(shareSvg),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AttachmentPopup(),
                    );
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (chatProvider.repliedMessage != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Color(0xff3CED78).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                          ),
                          child: Text(
                              "Replying to: ${chatProvider.repliedMessage!.text}"),
                        ),
                      TextField(
                        controller: _messageController,
                        onSubmitted: (s) {
                          if (s.isNotEmpty) {
                            chatProvider.sendMessage(
                              s,
                            );
                            _messageController.clear();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Сообщение...",
                          isDense: true,
                          filled: true,
                          fillColor: Theme.of(context).focusColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: SvgPicture.asset(recordSvg),
                  onPressed: () {
                    chatProvider.setMessageType(MessageType.audio);
                    chatProvider.startRecording();
                  },
                ),
              ],
            ),
    );
  }

  Expanded _buildChatList(ChatProvider chatProvider) {
    return Expanded(
      child: AnimatedList(
        key: chatProvider.listKey,
        controller: ScrollController(
            initialScrollOffset: MediaQuery.sizeOf(context).height,
            keepScrollOffset: false),
        initialItemCount: chatProvider.messages.length,
        itemBuilder: (context, index, animation) {
          final message = chatProvider.messages[index];
          return message.text.isEmpty && message.type == MessageType.text
              ? SizedBox.shrink()
              : SizeTransition(
                  sizeFactor: animation,
                  child: Dismissible(
                    key: Key(message.id),
                    direction: DismissDirection.horizontal,
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        chatProvider.deleteMessage(message.id);
                      }
                    },
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        chatProvider.setReplyMessage(message);
                        return false;
                      }
                      return true;
                    },
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 20),
                      child: Row(
                        spacing: 10,
                        children: [
                          Text('Delete'),
                          Icon(
                            Icons.delete,
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 10,
                        children: [
                          Text('Reply'),
                          Icon(
                            Icons.reply,
                            color: Colors.green.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                    child: ChatBubble(message: message),
                  ),
                );
        },
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      iconTheme: IconThemeData(color: Theme.of(context).dividerColor),
      elevation: 1,
      title: Row(
        spacing: 10,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.chat.avatar),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chat.name,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium!.color),
              ),
              Text(
                widget.chat.isOnline ? "Online" : "Offline",
                style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodyMedium!.color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
