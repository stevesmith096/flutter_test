import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_testing/camera_sheet.dart';
import 'package:flutter_testing/chat_model.dart';
import 'package:flutter_testing/chat_room_screen.dart';
import 'package:flutter_testing/message_box.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final Map<String, dynamic> data;
  const ChatScreen({super.key, required this.roomId, required this.data});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _messageController = TextEditingController();

  final User currentUser = FirebaseAuth.instance.currentUser!;

////////////////////////////////////////////////////////////////////////////////////////
  Future<void> _sendMessage(
      String messageContent, User currentUser, String type) async {
    // Reference to the Firestore instance
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Reference to the chat room document
    final DocumentReference chatRoomRef =
        _firestore.collection('chatrooms').doc(widget.roomId);

    // First, check if the chat room document exists
    final chatRoomSnapshot = await chatRoomRef.get();
    if (!chatRoomSnapshot.exists) {
      debugPrint(
          'Chat room document not found. Creating a new chat room document.');
      await chatRoomRef.set({
        'userIds': [currentUser.uid, widget.data['userID']],
      });
    }
    await _firestore.runTransaction((transaction) async {
      final DocumentReference newMessageRef =
          chatRoomRef.collection('messages').doc();
      await transaction.set(newMessageRef, {
        'senderId': currentUser.uid,
        'text': messageContent,
        'textType': type,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Update the lastMessage field in the chat room document
      await transaction.update(chatRoomRef, {
        'lastMessage': {
          'senderId': currentUser.uid,
          'content': messageContent,
          'texType': type,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
      _messageController.clear();
    }).catchError((error) {
      debugPrint('Error sending message and updating chat room: $error');
    });
  }

  ////////////////////////////////////////////////////////
  final ImagePicker picker = ImagePicker();
  String image = '';
  final _firebaseStorage = FirebaseStorage.instance;
  void getImage(
    ImageSource imageSource,
  ) async {
    // isBottomSheetOpen = true;
    final pickedFile = await ImagePicker().pickImage(source: imageSource);
    if (pickedFile != null) {
      File data = File(pickedFile.path);

      if (data.path.isNotEmpty) {
        //Upload to Firebase
        var snapshot = await _firebaseStorage
            .ref()
            .child('images/imageName')
            .putFile(data);
        var downloadUrl = await snapshot.ref.getDownloadURL();

        image = downloadUrl;
        // isBottomSheetOpen = false;
        setState(() {});
      } else {
        Get.snackbar(
          'Error',
          'No Image Picked',
          colorText: Colors.red,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

// //////////////////////////////////////////////////////////////////////
  late StreamSubscription<QuerySnapshot> _messageStreamSubscription;

  @override
  void initState() {
    super.initState();
    _messageStreamSubscription = FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.roomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: _auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      snapshot.docs.forEach((doc) async {
        await FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(widget.roomId)
            .collection('messages')
            .doc(doc.id)
            .update({'isRead': true});
      });
    });
  }

  @override
  void dispose() {
    _messageStreamSubscription.cancel();
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // _startMessageStream();
  //   // WidgetsBinding.instance.addObserver(this);
  //   FirebaseFirestore.instance
  //       .collection('chatrooms')
  //       .doc(widget.roomId)
  //       .collection('messages')
  //       .where('senderId', isNotEqualTo: _auth.currentUser!.uid)
  //       .snapshots()
  //       .listen((snapshot) {
  //     // debugPrint(snapshot.docs.length.toString());
  //     snapshot.docs.forEach((doc) async {
  //       // Update each document's isRead field to true
  //       await FirebaseFirestore.instance
  //           .collection('chatrooms')
  //           .doc(widget.roomId)
  //           .collection('messages')
  //           .doc(doc.id)
  //           .update({'isRead': true});
  //     });
  //   });
  // }

  // @override
  // void dispose() {
  //   _stopMessageStream();

  //   _messageController.dispose();
  //   super.dispose();
  // }

  // bool isBottomSheetOpen = false;

  // void _startMessageStream() {
  //   debugPrint('on Stream');
  //   _messageStreamSubscription = FirebaseFirestore.instance
  //       .collection('chatrooms')
  //       .doc(widget.roomId)
  //       .collection('messages')
  //       .where('senderId', isNotEqualTo: _auth.currentUser!.uid)
  //       .snapshots()
  //       .listen((snapshot) {
  //     // debugPrint(snapshot.docs.length.toString());
  //     snapshot.docs.forEach((doc) async {
  //       // Update each document's isRead field to true
  //       await FirebaseFirestore.instance
  //           .collection('chatrooms')
  //           .doc(widget.roomId)
  //           .collection('messages')
  //           .doc(doc.id)
  //           .update({'isRead': true});
  //     });
  //   });
  // }

  // void _stopMessageStream() {
  //   debugPrint('off Stream');
  //   _messageStreamSubscription.cancel();
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only handle lifecycle events if bottom sheet is not open
    if (state == AppLifecycleState.resumed) {
      // online
      _messageStreamSubscription.resume();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // offline
      _messageStreamSubscription.cancel();
    }
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
            Text(widget.data['name']),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(widget.data['userID'])
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
                  .doc(widget.roomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
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
                    reverse: true,
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
                                textType: data['textType'],
                                chat: ChatModel(
                                    titile: 'titile',
                                    isRead: data['isRead'],
                                    status: isMe.toString(),
                                    time: formattedTime,
                                    image: 'image',
                                    message: data['text']),
                              )),
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
                    child: image.isNotEmpty
                        ? TextField(
                            decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    Get.bottomSheet(
                                        elevation: 0,
                                        enableDrag: true,
                                        // backgroundColor:
                                        //     Color(0xFFD9D9D9).withOpacity(0.3),
                                        isScrollControlled: true,
                                        CameraBottomSheet(
                                          onImageClick: () {
                                            getImage(
                                              ImageSource.camera,
                                            );
                                            Get.back();
                                          },
                                          onCameraClick: () {
                                            getImage(
                                              ImageSource.gallery,
                                            );
                                            Get.back();
                                          },
                                          context: context,
                                          borderColor:
                                              Theme.of(context).hintColor,
                                        ));
                                  },
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.blue,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Image.network(
                                    image,
                                    height: 50,
                                  ),
                                )),
                          )
                        : TextField(
                            controller: _messageController,
                            style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).secondaryHeaderColor),
                            decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  Get.bottomSheet(
                                      elevation: 0,
                                      enableDrag: true,
                                      // backgroundColor:
                                      //     Color(0xFFD9D9D9).withOpacity(0.3),
                                      isScrollControlled: true,
                                      CameraBottomSheet(
                                        onImageClick: () {
                                          getImage(
                                            ImageSource.camera,
                                          );
                                          Get.back();
                                        },
                                        onCameraClick: () {
                                          getImage(
                                            ImageSource.gallery,
                                          );
                                          Get.back();
                                        },
                                        context: context,
                                        borderColor:
                                            Theme.of(context).hintColor,
                                      ));
                                },
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.blue,
                                ),
                              ),
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          )),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty ||
                        image.isNotEmpty) {
                      _sendMessage(
                          image.isEmpty ? _messageController.text : image,
                          currentUser,
                          image.isEmpty ? 'text' : 'image');
                      image = '';
                    }

                    setState(() {});
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
