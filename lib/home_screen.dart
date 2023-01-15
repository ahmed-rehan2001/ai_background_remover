import 'dart:io';
import 'package:bacground/api.dart';
import 'package:bacground/dashed_border.dart';
import 'package:before_after/before_after.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var loaded = false;
  dynamic image;
  String imagePath = "";
  var isLoading = false;
  var removedbg = false;
  ScreenshotController screenshotController = ScreenshotController();

  pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (img != null) {
      imagePath = img.path;

      loaded = true;
      setState(() {});
    } else {}
  }

  downloadImage() async {
    var perm = await Permission.storage.request();
    var folderName = "BGremover";
    var fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
    if (perm.isGranted) {
      final directory = Directory("storage/emulated/0/");
      if (!await directory.exists()) {
        directory.create(recursive: true);
      }
      await screenshotController.captureAndSave(directory.path,
          delay: const Duration(milliseconds: 100),
          fileName: fileName,
          pixelRatio: 1.0);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Downloaded to ${directory.path}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                downloadImage();
              },
              icon: const Icon(Icons.download))
        ],
        leading: const Icon(Icons.sort_rounded),
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          'AI Background Remover',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: Center(
        child: removedbg
            ? BeforeAfter(
                beforeImage: Image.file(File(imagePath)),
                afterImage: Screenshot(
                    controller: screenshotController,
                    child: Image.memory(image)))
            : loaded
                ? GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Image.file(
                      File(imagePath),
                    ),
                  )
                : DashedBorder(
                    padding: const EdgeInsets.all(40),
                    color: Colors.grey,
                    radius: 12,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          pickImage();
                        },
                        child: const Text("Remove background"),
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: loaded
              ? () async {
                  setState(() {
                    isLoading = true;
                  });
                  image = await Api.removebg(imagePath);
                  if (image != null) {
                    removedbg = true;
                    isLoading = false;
                    setState(() {});
                  }
                }
              : null,
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                )
              : const Text("Remove background"),
        ),
      ),
    );
  }
}
