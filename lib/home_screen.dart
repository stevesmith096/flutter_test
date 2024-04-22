// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_testing/auth_service.dart';
// import 'package:flutter_testing/chat_room_screen.dart';
// import 'package:get/get.dart';

// import 'chat_screen.dart';

// class UserListScreen extends StatelessWidget {
//   // Reference to the Firestore instance
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     String? currentUserId = _auth.currentUser?.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User List'),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 Get.to(ChatRoomScreen());
//               },
//               icon: const Icon(Icons.chat_rounded)),
//           IconButton(
//               onPressed: () {
//                 AuthService().signOut();
//               },
//               icon: const Icon(Icons.logout))
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore
//             .collection('users')
//             .where(FieldPath.documentId, isNotEqualTo: currentUserId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: const CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No users found.'));
//           }
//           List<DocumentSnapshot> docs = snapshot.data!.docs;
//           return ListView.builder(
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               // Get the data of each document
//               Map<String, dynamic> userData =
//                   docs[index].data() as Map<String, dynamic>;
//               print(userData['name']);
//               // Display the user's name and email
//               return Card(
//                 color: Theme.of(context).cardColor,
//                 child: ListTile(
//                   title: Text(
//                     userData['name'] ?? 'No Name',
//                     style: TextStyle(
//                         fontSize: 20.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Theme.of(context).secondaryHeaderColor),
//                   ),
//                   subtitle: Text(userData['email']),
//                   onTap: () {
//                     // Get the current user ID (assume using FirebaseAuth)
//                     String currentUserId =
//                         FirebaseAuth.instance.currentUser!.uid;

//                     // Get the selected user's ID
//                     String selectedUserId = userData['userID'];

//                     String chatroomId =
//                         createChatroomId(currentUserId, selectedUserId);

//                     // Navigate to the chat screen, passing the chatroom ID and selected user's data
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ChatScreen(
//                           chatroomId: chatroomId,
//                           selectedUser: userData,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   String createChatroomId(String userId1, String userId2) {
//     // Create a list with both user IDs
//     List<String> userIds = [userId1, userId2];

//     // Sort the user IDs alphabetically
//     userIds.sort();

//     // Combine the sorted user IDs with an underscore to create the chatroomId
//     return '${userIds[0]}_${userIds[1]}';
//   }
// }

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_testing/chat_room_screen.dart';
import 'package:flutter_testing/chat_screen.dart';
import 'package:flutter_testing/signin_screen.dart';

class UserListScreen extends StatefulWidget {
  UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus(true);
  }

  void setStatus(bool val) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update(
      {
        'isOnline': val,
      },
    );
    debugPrint('dsdsds');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // offline
      setStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomScreen(),
                      ));
                },
                child: const Icon(Icons.message)),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: GestureDetector(
                onTap: () async {
                  _auth.signOut();
                  await _firestore
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .update(
                    {
                      'isOnline': false,
                    },
                  );
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SigninScreen(),
                      ));
                },
                child: const Icon(Icons.login)),
          )
        ],
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
                return GestureDetector(
                  onTap: () {
                    String selectedUser = data['userID'];
                    String roomId =
                        createRoomId(_auth.currentUser!.uid, selectedUser);
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
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(data['email'] ?? ''),
                      )),
                );
              },
            );
          }
        },
      ),
    );
  }
}

String createRoomId(String user1, String user2) {
  List<String> users = [user1, user2];

  users.sort();

  return '${users[0]}_${users[1]}';
}
