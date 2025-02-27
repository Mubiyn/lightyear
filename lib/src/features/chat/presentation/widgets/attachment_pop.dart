import 'dart:io';

import 'package:buzz/src/features/chat/domain/models/type.dart';
import 'package:buzz/src/features/chat/presentation/provider/viewmodels.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AttachmentPopup extends StatelessWidget {
  const AttachmentPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();

    return SimpleDialog(
      title: Text("Выберите вложение"),
      children: [
        SimpleDialogOption(
          child: ListTile(leading: Icon(Icons.image), title: Text("Фото")),
          onPressed: () async {
            chatProvider.setMessageType(MessageType.image);
            final picker = ImagePicker();
            XFile? file = await picker.pickImage(source: ImageSource.gallery);
            if (context.mounted && file != null) {
              chatProvider.mediaUrl = file.path;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PreviewScreen()),
              );
            }
          },
        ),
        SimpleDialogOption(
          child: ListTile(leading: Icon(Icons.videocam), title: Text("Видео")),
          onPressed: () async {
            chatProvider.setMessageType(MessageType.video);
            final picker = ImagePicker();
            XFile? file = await picker.pickVideo(source: ImageSource.gallery);
            if (context.mounted && file != null) {
              chatProvider.mediaUrl = file.path;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PreviewScreen()),
              );
            }
          },
        ),
        SimpleDialogOption(
          child:
              ListTile(leading: Icon(Icons.attach_file), title: Text("Файл")),
          onPressed: () async {
            chatProvider.setMessageType(MessageType.file);
            FilePickerResult? result = await FilePicker.platform.pickFiles();
            if (context.mounted && result != null) {
              final file = XFile(result.files.first.path!);
              chatProvider.mediaUrl = file.path;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PreviewScreen()),
              );
            }
          },
        ),
      ],
    );
  }
}

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();
    final mediaFiles = chatProvider.mediaUrl;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).dividerColor),
        title: Text(
          "Предпросмотр",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium!.color),
        ),
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                final file = mediaFiles;
                if (chatProvider.messageType == MessageType.image) {
                  return ImagePreview(file: XFile(file!));
                } else if (chatProvider.messageType == MessageType.video) {
                  return VideoPreview(file: XFile(file!));
                } else {
                  return FilePreview(file: XFile(file!));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              spacing: 20,
              children: [
                Expanded(
                  child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Сообщение...",
                        isDense: true,
                        filled: true,
                        fillColor: Theme.of(context).focusColor,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                      )),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text;
                    chatProvider.sendMessageWithMedia(
                      [XFile(mediaFiles!)],
                      message,
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final XFile file;

  const ImagePreview({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(file.path),
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class VideoPreview extends StatefulWidget {
  final XFile file;

  const VideoPreview({super.key, required this.file});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.file.path))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FilePreview extends StatelessWidget {
  final XFile file;

  const FilePreview({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.insert_drive_file),
      title: Text(file.name),
    );
  }
}
