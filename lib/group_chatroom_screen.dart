import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_testing/chat_room_screen.dart';
import 'package:flutter_testing/group_chat_screen.dart';
import 'package:flutter_testing/group_screen.dart';
import 'package:intl/intl.dart';

class GroupChatRoomScreen extends StatefulWidget {
  GroupChatRoomScreen({super.key});

  @override
  State<GroupChatRoomScreen> createState() => _GroupChatRoomScreenState();
}

class _GroupChatRoomScreenState extends State<GroupChatRoomScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String roomId = '';
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
            .collection('groupchatrooms')
            .where('userIds', arrayContains: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No documents found.'));
          } else {
            List<DocumentSnapshot> docs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    docs[index].data() as Map<String, dynamic>;

                // debugPrint(data['lastMessage'].toString());
                Timestamp timestamp = data['lastMessage'] != null
                    ? (data['lastMessage']['timestamp'] as Timestamp)
                    : Timestamp.now();
                String formattedTime = formatTimestamp(timestamp);
                debugPrint(formattedTime);
                String textType = data['lastMessage'] != null
                    ? (data['lastMessage']['texType'] ?? '')
                    : '';

                bool isImage = textType == 'image';
                return StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .where(FieldPath.documentId, whereIn: data['userIds'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<DocumentSnapshot> docsUser = snapshot.data?.docs ?? [];
                    List<String> userNames = [];
                    String groupName = '';
                    // debugPrint(docsUser[index].id);
                    for (var i = 0; i < docsUser.length; i++) {
                      userNames.add(
                          docsUser[i]['userID'] == _auth.currentUser!.uid
                              ? 'You'
                              : docsUser[i]['name'] ?? '');

                      groupName = userNames.join(',');
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: GestureDetector(
                        onTap: () {
                          List<String> id = [];
                          for (var e in data['userIds']) {
                            id.add(e);
                          }
                          debugPrint('group chat');

                          roomId = createRoomId(id, _auth.currentUser!.uid);
                          log(roomId.toString());
                          debugPrint(roomId);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupChatScreen(
                                  groupName: groupName,
                                  roomId: roomId,
                                  userIds: id,
                                  // data: data['userIds'],
                                ),
                              ));
                        },
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
                                            StreamBuilder<QuerySnapshot>(
                                              stream: _firestore
                                                  .collection('groupchatrooms')
                                                  .where(FieldPath.documentId,
                                                      isEqualTo: roomId)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                final docs =
                                                    snapshot.data?.docs ?? [];

                                                return docs.isEmpty
                                                    ? Text(
                                                        groupName,
                                                        style: const TextStyle(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    : Text(
                                                        docs[0]['groupName'] ==
                                                                ''
                                                            ? groupName
                                                            : docs[0]
                                                                ['groupName'],
                                                        style: const TextStyle(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      );
                                              },
                                            ),
                                            isImage
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.network(
                                                      data['lastMessage']
                                                          ['content'],
                                                      height: 50,
                                                    ),
                                                  )
                                                : Text(data['lastMessage']
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
                                            // StreamBuilder<QuerySnapshot>(
                                            //   stream: _firestore
                                            //       .collection('groupchatrooms')
                                            //       .doc(roomId)
                                            //       .collection('messages')
                                            //       .doc(docsUser[index].id)
                                            //       .collection('isRead')
                                            //       .snapshots(),
                                            //   builder: (context, snapshot) {
                                            //     if (snapshot.connectionState ==
                                            //         ConnectionState.waiting) {
                                            //       return Container(); // or return a loading indicator
                                            //     }
                                            //     if (snapshot.hasError) {
                                            //       return Container(); // or handle the error
                                            //     }
                                            //     List<DocumentSnapshot> docs =
                                            //         snapshot.data!.docs;
                                            //     List<bool> unReadVal = [];
                                            //     for (var i = 0;
                                            //         i < docs.length;
                                            //         i++) {
                                            //       Map<String, dynamic>
                                            //           dataDocs = docs[i].data()
                                            //               as Map<String,
                                            //                   dynamic>;
                                            //       if (dataDocs['isRead'] ==
                                            //           false) {
                                            //         unReadVal.add(
                                            //             dataDocs['isRead']);
                                            //       }
                                            //     }
                                            //     debugPrint(
                                            //         unReadVal.toString());

                                            //     return unReadVal.isEmpty
                                            //         ? Container()
                                            //         : Container(
                                            //             decoration:
                                            //                 const BoxDecoration(
                                            //               color: Colors.red,
                                            //               shape:
                                            //                   BoxShape.circle,
                                            //             ),
                                            //             child: Padding(
                                            //               padding:
                                            //                   const EdgeInsets
                                            //                       .all(6.0),
                                            //               child: Text(
                                            //                 unReadVal.length
                                            //                     .toString(),
                                            //                 style:
                                            //                     const TextStyle(
                                            //                         color: Colors
                                            //                             .white),
                                            //               ),
                                            //             ),
                                            //           );
                                            //   },
                                            // )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ))),
                      ),
                    );
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

// String formatTimestamp(Timestamp timestamp) {
//   DateTime dateTime = timestamp.toDate();
//   String formattedTime = DateFormat.jm().format(dateTime);
//   return formattedTime;
// }
