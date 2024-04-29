import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class GroupNameBottomSheet extends StatefulWidget {
  final String currentName;
  final Function(String) onUpdate;

  GroupNameBottomSheet({required this.currentName, required this.onUpdate});

  @override
  _GroupNameBottomSheetState createState() => _GroupNameBottomSheetState();
}

class _GroupNameBottomSheetState extends State<GroupNameBottomSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Group Name',
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.blue)),
            onPressed: () {
              String newName = _controller.text;
              if (newName.isNotEmpty) {
                widget.onUpdate(newName);
                Navigator.pop(context);
              } else {
                // Show error message or handle empty input
              }
            },
            child: Text('Change'),
          ),
        ],
      ),
    );
  }
}

void showGroupNameBottomSheet(
    String groupName, BuildContext context, String roomId) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GroupNameBottomSheet(
        currentName: groupName,
        onUpdate: (newName) {
          FirebaseFirestore.instance
              .collection('groupchatrooms')
              .doc(roomId)
              .update({'groupName': newName});
        },
      ),
    ),
  );
}
