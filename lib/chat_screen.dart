// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ChatScreen extends StatelessWidget {
//   final String chatroomId; // The chatroom ID
//   final Map<String, dynamic> selectedUser; // The selected user's data

//   ChatScreen({required this.chatroomId, required this.selectedUser});
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   TextEditingController _messageController = TextEditingController();

//   // Function to send a message
//   // Future<void> _sendMessage() async {
//   //   if (_messageController.text.isNotEmpty) {
//   //     print(_messageController.text);
//   //     User? currentUser = _auth.currentUser;

//   //     await _firestore
//   //         .collection('chatrooms')
//   //         .doc(chatroomId)
//   //         .collection('messages')
//   //         .add({
//   //       'senderId': currentUser!.uid,
//   //       'text': _messageController.text,
//   //       'timestamp': FieldValue.serverTimestamp(),
//   //     });

//   //     _messageController.clear();
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     final User? currentUser = FirebaseAuth.instance.currentUser;
//     print('UserChat');
//     print(selectedUser['userIds']);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(selectedUser['name'] ?? 'Chat'),
//       ),
//       body: Column(
//         children: [
// //           Expanded(
// //             child: StreamBuilder<QuerySnapshot>(
// //               stream: FirebaseFirestore.instance
// //                   .collection('chatrooms')
// //                   .doc(chatroomId)
// //                   .collection('messages')
// //                   .orderBy('timestamp')
// //                   .snapshots(),
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return Center(child: CircularProgressIndicator());
// //                 }

// //                 if (snapshot.hasError) {
// //                   return Center(child: Text('Error: ${snapshot.error}'));
// //                 }

// //                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //                   // Handle empty data
// //                   return Center(child: Text('No messages found.'));
// //                 }

// //                 // Get the list of messages
// //                 List<DocumentSnapshot> docs = snapshot.data!.docs;

// //                 return ListView.builder(
// //                   itemCount: docs.length,
// //                   itemBuilder: (context, index) {
// //                     // Get the message data
// //                     Map<String, dynamic> messageData = docs[index].data() as Map<String, dynamic>;
// // print(messageData);
// //                     // Determine if the message is from the current user
// //                     bool isSender = messageData['senderId'] == currentUser!.uid;

// //                     return Align(
// //                       alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
// //                       child: Container(
// //                         padding: EdgeInsets.all(10),
// //                         margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
// //                         decoration: BoxDecoration(
// //                           color: isSender ? Colors.blue[200] : Colors.grey[300],
// //                           borderRadius: BorderRadius.circular(10),
// //                         ),
// //                         child: Text(
// //                           messageData['text']!,
// //                           style: TextStyle(
// //                             color: isSender ? Colors.white : Colors.black,
// //                           ),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 );
// //               },
// //             ),
// //           ),

//           Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//             stream: _firestore
//                 .collection('chatrooms')
//                 .doc(chatroomId)
//                 .collection('messages')
//                 .orderBy('timestamp')
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               }

//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 // Handle empty data
//                 return const Center(child: Text('No messages found.'));
//               } else {
//                 List<DocumentSnapshot> docs = snapshot.data!.docs;
//                 return ListView.builder(
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     Map<String, dynamic> data =
//                         docs[index].data() as Map<String, dynamic>;

//                     bool isMe = data['senderId'] == _auth.currentUser!.uid
//                         ? true
//                         : false;
//                     return Align(
//                       alignment: isMe ? Alignment.topRight : Alignment.topLeft,
//                       child: Padding(
//                         padding: const EdgeInsets.only(bottom: 10.0),
//                         child: Container(
//                           color: isMe ? Colors.pink : Colors.blue,
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Text(data['text']),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }
//             },
//           )),
//           // Bottom input for sending messages
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: Theme.of(context).secondaryHeaderColor),
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () {
//                     _sendMessage(_messageController.text, currentUser!);
//                     // Add your code here to send the message
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_testing/chat_model.dart';
import 'package:flutter_testing/chat_room_screen.dart';
import 'package:flutter_testing/home_screen.dart';
import 'package:flutter_testing/message_box.dart';

class ChatScreen extends StatelessWidget {
  final String roomId;
  final Map<String, dynamic> data;
  ChatScreen({super.key, required this.roomId, required this.data});
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _messageController = TextEditingController();
  final User currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> _sendMessage(String messageContent, User currentUser) async {
    // Reference to the Firestore instance
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Reference to the chat room document
    final DocumentReference chatRoomRef =
        _firestore.collection('chatrooms').doc(roomId);

    // First, check if the chat room document exists
    final chatRoomSnapshot = await chatRoomRef.get();
    if (!chatRoomSnapshot.exists) {
      print('Chat room document not found. Creating a new chat room document.');
      await chatRoomRef.set({
        'userIds': [currentUser.uid, data['userID']],
      });
    }
    await _firestore.runTransaction((transaction) async {
      final DocumentReference newMessageRef =
          chatRoomRef.collection('messages').doc();
      await transaction.set(newMessageRef, {
        'senderId': currentUser.uid,
        'text': messageContent,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the lastMessage field in the chat room document
      await transaction.update(chatRoomRef, {
        'lastMessage': {
          'senderId': currentUser.uid,
          'content': messageContent,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
      _messageController.clear();
    }).catchError((error) {
      print('Error sending message and updating chat room: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back)),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['name']),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(data['userID'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...'); // Add a loading indicator
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.data() == null) {
                  return const Text(
                      'No data available'); // Handle case where snapshot is empty or data is null
                }

                // Safely access the data from the snapshot
                Map<String, dynamic> userData =
                    snapshot.data!.data() as Map<String, dynamic>;
                bool isOnline = userData['isOnline'] == true;

                return Text(isOnline ? 'Online' : 'Offline');
              },
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatrooms')
                  .doc(roomId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No users found.'));
                } else {
                  List<DocumentSnapshot> docs = snapshot.data!.docs;
                  debugPrint(docs.toString());

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                          docs[index].data() as Map<String, dynamic>;
                      Timestamp timestamp = data['timestamp'];
                      String formattedTime = formatTimestamp(timestamp);
                      bool isMe = data['senderId'] == _auth.currentUser!.uid
                          ? true
                          : false;
                      debugPrint(isMe.toString());
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Align(
                          alignment:
                              isMe ? Alignment.topRight : Alignment.topLeft,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: MessageBox(
                                recieved: isMe,
                                text: data['text'],
                                chat: ChatModel(
                                    titile: 'titile',
                                    status: isMe.toString(),
                                    time: formattedTime,
                                    image: 'image',
                                    message: data['text']),
                              )
                              // Container(
                              //   decoration: BoxDecoration(
                              //       color: isMe ? Colors.purple : Colors.blue,
                              //       borderRadius: BorderRadius.circular(10.0)),
                              //   child: Padding(
                              //     padding: const EdgeInsets.all(15.0),
                              //     child: Column(

                              //       children: [
                              //         Text(data['text']),
                              //         Text(formattedTime),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).secondaryHeaderColor),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text, currentUser);
                    // Add your code here to send the message
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
