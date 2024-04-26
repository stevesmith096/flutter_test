import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_testing/home_screen.dart';

class GroupScreen extends StatefulWidget {
  GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool value = false;

  List<bool> checkedList = [];
  List<String> usersId = []; // Move usersId list outside the build method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: GestureDetector(
                onTap: () async {
                  String roomId = createRoomId(usersId, _auth.currentUser!.uid);
                  log(roomId);
                  if (roomId.contains('_')) {
                    final DocumentReference chatRoomRef =
                        _firestore.collection('groupchatrooms').doc(roomId);
                    debugPrint(chatRoomRef.toString());
                    final chatRoomSnapshot = await chatRoomRef.get();
                    if (!chatRoomSnapshot.exists) {
                      debugPrint(
                          'Chat room document not found. Creating a new chat room document.');
                      await chatRoomRef.set({
                        'userIds': usersId,
                      });
                    }
                  }
                },
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                )),
          ),
        ],
      ),
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
                if (checkedList.length <= index) {
                  // Initialize checkedList to avoid index out of range error
                  checkedList.add(false);
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Toggle the checked state of the checkbox
                      checkedList[index] = !checkedList[index];
                    });

                    String selectedUser = data['userID'];

                    if (usersId.contains(selectedUser)) {
                      debugPrint(selectedUser);

                      usersId.remove(selectedUser);
                    } else {
                      usersId.add(selectedUser);
                    }

                    String roomId =
                        createRoomId(usersId, _auth.currentUser!.uid);
                    debugPrint(roomId);
                  },
                  child: Card(
                      shadowColor: Colors.grey[200],
                      elevation: 4,
                      child: ListTile(
                        title: Text(data['name'] ?? ''),
                        subtitle: Text(data['email'] ?? ''),
                        trailing: Checkbox(
                          value: checkedList[index],
                          onChanged: (bool? value) {},
                        ),
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

String createRoomId(List<String> users, String currentUserId) {
  // Add the current user's ID to the list
  if (users.contains(currentUserId)) {
  } else {
    users.add(currentUserId);
  }

  // Sort the list of users
  users.sort();

  // Join the sorted users with underscores
  return users.join('_');
}
