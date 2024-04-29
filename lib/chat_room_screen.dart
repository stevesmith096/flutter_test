import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_testing/chat_screen.dart';
import 'package:flutter_testing/home_screen.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back)),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where(FieldPath.documentId, isNotEqualTo: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            List<DocumentSnapshot> docs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    docs[index].data() as Map<String, dynamic>;
                String roomId =
                    createRoomId(_auth.currentUser!.uid, data['userID']);
                return StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('chatrooms')
                      .doc(roomId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.exists) {
                      Timestamp timestamp =
                          snapshot.data!['lastMessage']['timestamp'];
                      String formattedTime = formatTimestamp(timestamp);
                      String textType =
                          snapshot.data!['lastMessage']['texType'].toString();
                      bool isImage = textType == 'image';
                      debugPrint(isImage.toString());
                      return GestureDetector(
                        onTap: () {
                          String selectedUser = data['userID'];
                          String roomId = createRoomId(
                              _auth.currentUser!.uid, selectedUser);
                          debugPrint(roomId);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  roomId: roomId,
                                  data: data,
                                ),
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Card(
                              shadowColor: Colors.grey[200],
                              elevation: 4,
                              child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['name'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              isImage
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Image.network(
                                                        snapshot.data![
                                                                'lastMessage']
                                                            ['content'],
                                                        height: 50,
                                                      ),
                                                    )
                                                  : Text(snapshot.data![
                                                              'lastMessage']
                                                          ['content'] ??
                                                      '')
                                            ],
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(formattedTime),
                                              StreamBuilder<QuerySnapshot>(
                                                stream: _firestore
                                                    .collection('chatrooms')
                                                    .doc(roomId)
                                                    .collection('messages')
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Container(); // or return a loading indicator
                                                  }
                                                  if (snapshot.hasError) {
                                                    return Container(); // or handle the error
                                                  }
                                                  List<DocumentSnapshot> docs =
                                                      snapshot.data!.docs;
                                                  List<bool> unReadVal = [];
                                                  for (var i = 0;
                                                      i <
                                                          snapshot.data!.docs
                                                              .length;
                                                      i++) {
                                                    Map<String, dynamic>
                                                        dataDocs =
                                                        docs[i].data() as Map<
                                                            String, dynamic>;
                                                    if (dataDocs['senderId'] !=
                                                            _auth.currentUser!
                                                                .uid &&
                                                        dataDocs['isRead'] ==
                                                            false) {
                                                      unReadVal.add(
                                                          dataDocs['isRead']);
                                                    }
                                                  }

                                                  return unReadVal.isEmpty
                                                      ? Container()
                                                      : Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.red,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(6.0),
                                                            child: Text(
                                                              unReadVal.length
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        );
                                                },
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ))),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  String formattedTime = DateFormat.jm().format(dateTime);
  return formattedTime;
}
