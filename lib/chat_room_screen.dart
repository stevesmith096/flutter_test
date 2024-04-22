// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_testing/auth_service.dart';

// import 'chat_screen.dart';

// class ChatRoomScreen extends StatelessWidget {
//   // Reference to the Firestore instance
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     String? currentUserId = _auth.currentUser?.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User Chat Room'),
//       ),
// //       body: StreamBuilder<QuerySnapshot>(
// //         // Query the Firestore collection containing user data
// //         stream: _firestore.collection('users').where(FieldPath.documentId, isNotEqualTo: currentUserId)
// //             .snapshots(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             // Display a loading indicator while waiting for data
// //             return Center(child: CircularProgressIndicator());
// //           }

// //           if (snapshot.hasError) {
// //             // Handle errors
// //             return Center(child: Text('Error: ${snapshot.error}'));
// //           }

// //           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //             // Handle empty data
// //             return Center(child: Text('No users found.'));
// //           }

// //           // Get the list of documents from the snapshot
// //           List<DocumentSnapshot> docs = snapshot.data!.docs;

// //           return ListView.builder(
// //   itemCount: docs.length,
// //   itemBuilder: (context, index) {
// //     // Get the data of each document
// //     Map<String, dynamic> userData = docs[index].data() as Map<String, dynamic>;
// // print(userData);
// //     // Display the user's name and email
// //     return Card(
// //       color: Theme.of(context).cardColor,
// //       child: ListTile(
// //         title: Text(
// //           userData['name'] ?? 'No Name',
// //           style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Theme.of(context).secondaryHeaderColor),
// //         ),
// //         subtitle: Text(userData['email'] ?? 'No Email'),
// //         onTap: () {
// //           // Get the current user ID (assume using FirebaseAuth)
// //           String currentUserId = FirebaseAuth.instance.currentUser!.uid;

// //           // Get the selected user's ID
// //           String selectedUserId = userData['userID']; // Make sure the 'userId' field is in the Firestore document

// //           // Create the chatroom ID
// //           String chatroomId = createChatroomId(currentUserId, selectedUserId);

// //           // Navigate to the chat screen, passing the chatroom ID and selected user's data
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder: (context) => ChatScreen(
// //                 chatroomId: chatroomId,
// //                 selectedUser: userData,
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   },
// // );

// //         },
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore
//             .collection('users')
//             .where(FieldPath.documentId, isNotEqualTo: currentUserId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Display a loading indicator while waiting for data
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             // Handle errors
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             // Handle empty data
//             return const Center(child: Text('No users found.'));
//           } else {
//             List<DocumentSnapshot> docs = snapshot.data!.docs;

//             return ListView.builder(
//                 itemCount: docs.length,
//                 itemBuilder: (context, index) {
//                   Map<String, dynamic> data =
//                       docs[index].data() as Map<String, dynamic>;
//                   String roomId =
//                       createChatRoomId(_auth.currentUser!.uid, data['userID']);

//                   return StreamBuilder<DocumentSnapshot>(
//                     stream: _firestore
//                         .collection('chatrooms')
//                         .doc(roomId)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasData && snapshot.data!.exists) {
//                         // Document exists
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 20.0),
//                           child: GestureDetector(
//                             onTap: () {
//                               String selectedUser = data['userID'];
//                               String roomId = createChatRoomId(
//                                   _auth.currentUser!.uid, selectedUser);
//                               debugPrint(roomId);
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ChatScreen(
//                                     chatroomId: roomId,
//                                     selectedUser: data,
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               color: Colors.purple,
//                               child: ListTile(
//                                 title: Text(data['name']),
//                                 subtitle: Text(data['email']),
//                               ),
//                             ),
//                           ),
//                         );
//                       } else {
//                         // Document doesn't exist
//                         return SizedBox(); // or any other widget if you want to show something else
//                       }
//                     },
//                   );
//                 });
//           }
//         },
//       ),
//     );
//   }

//   String createChatRoomId(String user1, String user2) {
//     // Create a list with both user IDs
//     List<String> userIds = [user1, user2];

//     // Sort the user IDs alphabetically
//     userIds.sort();

//     // Combine the sorted user IDs with an underscore to create the chatroomId
//     return '${userIds[0]}_${userIds[1]}';
//   }
// }
// // String createChatroomId(String userId1, String userId2) {
// //     // Create a list with both user IDs
// //     List<String> userIds = [userId1, userId2];

// //     // Sort the user IDs alphabetically
// //     userIds.sort();

// //     // Combine the sorted user IDs with an underscore to create the chatroomId
// //     return '${userIds[0]}_${userIds[1]}';
// // }

// // }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_testing/chat_screen.dart';
import 'package:flutter_testing/home_screen.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatelessWidget {
  ChatRoomScreen({super.key});
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
            child: Icon(Icons.arrow_back)),
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
                      debugPrint(snapshot.data?['lastMessage']['timestamp']
                          .toString());
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
                        child: Card(
                            shadowColor: Colors.grey[200],
                            elevation: 4,
                            child: ListTile(
                              trailing: Text(formattedTime),
                              title: Text(data['name'] ?? ''),
                              subtitle: Text(snapshot.data!['lastMessage']
                                      ['content'] ??
                                  ''),
                            )),
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
