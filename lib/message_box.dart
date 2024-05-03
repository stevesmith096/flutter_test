import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_testing/chat_model.dart';

class MessageBox extends StatelessWidget {
  final bool recieved;
  final String? text;
  final ChatModel chat;
  final String textType;
  final bool? isGroupChat;
  final String? chatUserName;
  final VoidCallback? onTap;

  MessageBox(
      {Key? key,
      this.recieved = false,
      this.text,
      required this.chat,
      this.isGroupChat = false,
      this.chatUserName,
      this.onTap,
      required this.textType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: recieved
            ? ChatBubble(
                clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
                alignment: Alignment.topRight,
                backGroundColor: const Color(0xffE7E7ED),
                margin: const EdgeInsets.only(top: 20),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        isGroupChat == true
                            ? Text(
                                chatUserName!,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )
                            : const SizedBox(),
                        isGroupChat == true
                            ? const SizedBox(
                                width: 40,
                                child: Divider(
                                  color: Colors.black,
                                ),
                              )
                            : const SizedBox(),
                        textType == 'text'
                            ? Text(
                                chat.message,
                                style: const TextStyle(color: Colors.black),
                              )
                            : Image.network(chat.message),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: onTap,
                              child: Icon(
                                Icons.delete,
                                color: Colors.grey[700],
                              ),
                            ),
                            chat.isRead == true
                                ? Image.asset(
                                    'assets/images/double-check.png',
                                    color: Colors.blue,
                                    height: 20,
                                  )
                                : Image.asset(
                                    'assets/images/check.png',
                                    color: Colors.grey[700],
                                    height: 20,
                                  ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              chat.time,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 11.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChatBubble(
                    alignment: Alignment.topLeft,
                    clipper:
                        ChatBubbleClipper1(type: BubbleType.receiverBubble),
                    backGroundColor: Colors.blue,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isGroupChat == true
                                ? Text(
                                    chatUserName!,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                : const SizedBox(),
                            isGroupChat == true
                                ? const SizedBox(
                                    width: 40,
                                    child: Divider(
                                      color: Colors.white,
                                    ),
                                  )
                                : const SizedBox(),
                            textType == 'text'
                                ? Text(
                                    chat.message,
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : Image.network(chat.message),
                            const SizedBox(
                              height: 5.0,
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  chat.time,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11.0),
                                ),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                chat.isRead == true
                                    ? Image.asset(
                                        'assets/images/double-check.png',
                                        color: Colors.white,
                                        height: 20,
                                      )
                                    : Image.asset(
                                        'assets/images/check.png',
                                        color: Colors.grey[200],
                                        height: 20,
                                      ),
                                GestureDetector(
                                    onTap: onTap, child: Icon(Icons.delete))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ));
  }
}
