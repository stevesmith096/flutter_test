class ChatModel {
  final String image;
  final String titile;
  final String status;
  final String time;
  final String message;
  final bool isRead;

  ChatModel(
      {required this.titile,
      required this.status,
      required this.time,
      required this.image,
      required this.message,
      required this.isRead});
}
