import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
                debugPrint(data['userIds'].toString());
                return StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .where(FieldPath.documentId, whereIn: data['userIds'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<DocumentSnapshot> docsUser = snapshot.data?.docs ?? [];
                    List<String> userNames = [];
                    String groupName = '';
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
                          String roomId =
                              createRoomId(id, _auth.currentUser!.uid);
                          log(roomId.toString());

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupChatScreen(
                                  groupName: groupName,
                                  roomId: roomId,
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
                                            Text(
                                              groupName,
                                              style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const Text('hello'),
                                          ],
                                        )
                                      ],
                                    ),
                                    const Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text('18:00AM'),
                                            // StreamBuilder<QuerySnapshot>(
                                            //   stream: _firestore
                                            //       .collection('chatrooms')
                                            //       .doc(roomId)
                                            //       .collection('messages')
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
                                            //         i <
                                            //             snapshot
                                            //                 .data!.docs.length;
                                            //         i++) {
                                            //       Map<String, dynamic> dataDocs =
                                            //           docs[i].data()
                                            //               as Map<String, dynamic>;
                                            //       if (dataDocs['senderId'] !=
                                            //               _auth
                                            //                   .currentUser!.uid &&
                                            //           dataDocs['isRead'] ==
                                            //               false) {
                                            //         unReadVal
                                            //             .add(dataDocs['isRead']);
                                            //       }
                                            //     }

                                            //     return unReadVal.isEmpty
                                            //         ? Container()
                                            //         : Container(
                                            //             decoration:
                                            //                 const BoxDecoration(
                                            //               color: Colors.red,
                                            //               shape: BoxShape.circle,
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
