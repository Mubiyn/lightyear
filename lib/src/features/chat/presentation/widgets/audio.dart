import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:buzz/src/features/chat/presentation/provider/viewmodels.dart';
import 'package:buzz/src/features/dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VoiceNoteWidget extends StatefulWidget {
  const VoiceNoteWidget({super.key});

  @override
  State<VoiceNoteWidget> createState() => _VoiceNoteWidgetState();
}

class _VoiceNoteWidgetState extends State<VoiceNoteWidget> {
  @override
  void initState() {
    // context.read<ChatProvider>().initialiseController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(20)),
        child: Column(
          spacing: 8,
          children: [
            Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  formatDuration(chatProvider.recordDuration),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Expanded(
                  child: AudioWaveforms(
                    backgroundColor: Colors.grey.withAlpha(100),
                    recorderController: chatProvider.recorderController,
                    enableGesture: true,

                    // waveStyle: WaveStyle(
                    //     showMiddleLine: false, showDurationLabel: true,s),
                    // shouldCalculateScrolledPosition: true,
                    size: Size(MediaQuery.sizeOf(context).width, 30),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      chatProvider.stopRecording();
                      chatProvider.audioFile = null;
                    },
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    )),
                IconButton(
                  icon: Icon(
                    chatProvider.recorderController.isRecording
                        ? Icons.pause
                        : Icons.mic,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    if (chatProvider.recorderController.isRecording) {
                      chatProvider.pauseRecording();
                    } else {
                      chatProvider.startRecording();
                    }
                  },
                ),
                InkWell(
                    onTap: () async {
                      await chatProvider.stopRecording();
                      chatProvider.audioFile = null;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.green.withAlpha(150),
                          shape: BoxShape.circle),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    )),
              ],
            ),
          ],
        ));
  }
}
