import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CameraBottomSheet extends StatelessWidget {
  final BuildContext context;
  final Color borderColor;
  final VoidCallback onImageClick;
  final VoidCallback onCameraClick;
  const CameraBottomSheet(
      {super.key,
      required this.context,
      required this.borderColor,
      required this.onImageClick,
      required this.onCameraClick});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20)),
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 20.0),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close_outlined,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 30,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            GestureDetector(
              onTap: onImageClick,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  leading: Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                        color: const Color(0xffEAEAEA),
                        borderRadius: BorderRadius.circular(7.0)),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xff656565),
                      size: 30,
                    ),
                  ),
                  title: Text(
                    'Take Photo',
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 14.0,
                        fontFamily: 'poppin',
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 90.0),
              child: Divider(
                thickness: 1.2,
                color: Theme.of(context).disabledColor,
              ),
            ),
            GestureDetector(
              onTap: onCameraClick,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  leading: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: const Color(0xffEAEAEA),
                        borderRadius: BorderRadius.circular(7.0)),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Color(0xff656565),
                      size: 30,
                    ),
                  ),
                  title: Text(
                    'From Gallery',
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 14.0,
                        fontFamily: 'poppin',
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            )
          ],
        ));
  }
}
