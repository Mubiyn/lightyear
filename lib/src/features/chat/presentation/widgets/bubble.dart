import 'dart:developer';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:buzz/src/features/chat/domain/models/models.dart';
import 'package:buzz/src/features/chat/presentation/widgets/thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final PlayerController playerController = PlayerController();

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  void initializePlayer() async {
    if (widget.message.type == MessageType.audio &&
        widget.message.mediaUrl != null) {
      log(widget.message.toString());
      await playerController.preparePlayer(path: widget.message.mediaUrl!);
    }
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isSentByMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Color(0xff3CED78) : Color(0xffEDF2F6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: isMe ? Radius.circular(16) : Radius.circular(0),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.message.replyToChatMessage != null)
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.message.replyToChatMessage!,
                  style: TextStyle(
                      color: Colors.black54, fontStyle: FontStyle.italic),
                ),
              ),
            // Display image or video thumbnail
            if (widget.message.type == MessageType.image &&
                widget.message.mediaUrl != null)
              if (widget.message.mediaUrl != null)
                if (widget.message.mediaUrl!.startsWith('https'))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.message.mediaUrl!,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(widget.message.mediaUrl!),
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
            if (widget.message.type == MessageType.video &&
                widget.message.mediaUrl != null)
              VideoThumbnailWidget(videoUrl: widget.message.mediaUrl!),

            if (widget.message.type == MessageType.audio &&
                widget.message.mediaUrl != null)
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                        !playerController.playerState.isPaused
                            ? Icons.play_arrow
                            : Icons.pause,
                        color: isMe ? Colors.white : Colors.black),
                    onPressed: () {
                      setState(() {
                        if (playerController.playerState.isPaused) {}
                        playerController.startPlayer();
                        if (playerController.playerState.isPlaying) {
                          playerController.pausePlayer();
                        }
                        if (playerController.playerState.isStopped) {
                          playerController.startPlayer();
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            // Text(widget.message.mediaUrl.toString())
                            AudioFileWaveforms(
                                size: Size(
                                    MediaQuery.sizeOf(context).width * 0.7, 30),
                                playerController: playerController)),
                  ),
                ],
              ),

            if (widget.message.type != MessageType.audio)
              TextWidget(message: widget.message, isMe: isMe),
          ],
        ),
      ),
    );
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.message,
    required this.isMe,
  });

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 20,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          message.text,
          style: TextStyle(color: isMe ? Color(0xff00521C) : Color(0xff2B333E)),
        ),
        Text(
          DateFormat('HH:mm').format(message.timestamp),
          style: TextStyle(
              fontSize: 12, color: isMe ? Colors.white70 : Colors.black54),
        ),
      ],
    );
  }
}

class AudioWaveformPainter extends CustomPainter {
  final List<double> waveform;

  AudioWaveformPainter({required this.waveform});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final barWidth = size.width / waveform.length;
    for (var i = 0; i < waveform.length; i++) {
      final barHeight = waveform[i] * size.height;
      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth,
          size.height - barHeight,
          barWidth - 2,
          barHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
