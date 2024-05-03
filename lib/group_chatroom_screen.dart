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
  late Stream<QuerySnapshot> _stream; // Define the stream variable

  @override
  void initState() {
    super.initState();
    _stream = _firestore
        .collection('groupchatrooms')
        .where('userIds', arrayContains: _auth.currentUser!.uid)
        .snapshots(); // Initialize the stream
  }

  void _resetStream() {
    setState(() {
      _stream = _firestore
          .collection('groupchatrooms')
          .where('userIds', arrayContains: _auth.currentUser!.uid)
          .snapshots(); // Reset the stream
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group'),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back)),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          _resetStream(); // Call the method to reset the stream
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: _stream,
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
                  List<String> id = [];
                  for (var e in data['userIds']) {
                    id.add(e);
                  }
                  debugPrint('group chat');

                  roomId = createRoomId(id, _auth.currentUser!.uid);
                  log(roomId.toString());
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
                      List<DocumentSnapshot> docsUser =
                          snapshot.data?.docs ?? [];
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
                              color: Colors.brown[900],
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
                                                    .collection(
                                                        'groupchatrooms')
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
                                              StreamBuilder<QuerySnapshot>(
                                                stream: _firestore
                                                    .collection(
                                                        'groupchatrooms')
                                                    .doc(roomId)
                                                    .collection('messages')
                                                    .where('senderId',
                                                        isNotEqualTo: _auth
                                                            .currentUser!.uid)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Container(); // Return a loading indicator
                                                  }
                                                  if (snapshot.hasError) {
                                                    return Container(); // Handle the error
                                                  }
                                                  List<DocumentSnapshot>
                                                      messageDocs =
                                                      snapshot.data!.docs;

                                                  return FutureBuilder(
                                                    future: _getUnreadCount(
                                                        messageDocs),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<int>
                                                            unreadSnapshot) {
                                                      if (unreadSnapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return Container(); // Return a loading indicator while waiting for the future to complete
                                                      }
                                                      if (unreadSnapshot
                                                          .hasError) {
                                                        return Container(); // Handle the error
                                                      }

                                                      int unreadCount =
                                                          unreadSnapshot.data ??
                                                              0;

                                                      return unreadCount == 0
                                                          ? Container()
                                                          : Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        6.0),
                                                                child: Text(
                                                                  unreadCount
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            );
                                                    },
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
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<int> _getUnreadCount(List<DocumentSnapshot> messageDocs) async {
    int unreadCount = 0;
    for (DocumentSnapshot messageDoc in messageDocs) {
      // Query the "isRead" subcollection for the current user
      DocumentSnapshot isReadDoc = await _firestore
          .collection('groupchatrooms')
          .doc(roomId)
          .collection('messages')
          .doc(messageDoc.id)
          .collection('isRead')
          .doc(_auth.currentUser!.uid)
          .get();

      // Check if the "isRead" field value is false
      bool isRead = isReadDoc.exists ? isReadDoc['isRead'] : false;
      if (!isRead) {
        unreadCount++;
      }
    }
    return unreadCount;
  }
}
