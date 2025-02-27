import 'package:hive/hive.dart';

part 'type.g.dart';

@HiveType(typeId: 2)
enum MessageType {
  @HiveField(0)
  text,

  @HiveField(1)
  image,

  @HiveField(2)
  video,

  @HiveField(3)
  audio,

  @HiveField(4)
  file,
}
