import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studymate/screens/Authenticated/FirstLogin/intrest.dart';
import 'package:path/path.dart' as p;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studymate/service/storage_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../component/utils.dart';
import '../../../models/user.dart';

class SetUser extends StatefulWidget {
  @override
  State<SetUser> createState() => _SetUserState();
}

class _SetUserState extends State<SetUser> {
  final formKey = GlobalKey<FormState>();
  final firstnameControler = TextEditingController();
  final lastnameControler = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  File? _image;
  final Storage storage = Storage();

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar( SnackBar(content: Text(AppLocalizations.of(context)!.noImgSelected)));
        return;
      }
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);

      if (img == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.noImgCropped)));
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.imgLoaded)));
      setState(() {
        _image = img;
      });
      Navigator.pop(context);
    } on PlatformException catch (e) {
      print(e);
      Navigator.pop(context);
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 1080,
      maxWidth: 1080,
      compressQuality: 30,
    );
    if (croppedImage == null) {
      return null;
    }
    return File(croppedImage.path);
  }

  @override
  void dispose() {
    firstnameControler.dispose();
    lastnameControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double h = size.height;
    double w = size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                Column(children: <Widget>[
                  SizedBox(
                    height: h > w
                        ? w * 0.3
                        : (h > 720 && w > 490)
                            ? 0.1 * h
                            : 0,
                  ),
                  Text(
                    AppLocalizations.of(context)!.welcome,
                    style: TextStyle(
                      fontFamily: "Crimson Pro",
                      fontWeight: FontWeight.bold,
                      fontSize: (w > 490 && h > 720) ? 60 : 35,
                      color: Color.fromARGB(255, 233, 64, 87),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(75),
                          child: _image == null
                              ? Image.asset("assets/login/user.png")
                              : Image(
                                  image: FileImage(_image!),
                                ),
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.mode_edit_outline),
                          onPressed: () {
                            showModalBottomSheet(
                              showDragHandle: true,
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                        onPressed: (() {
                                          _pickImage(ImageSource.gallery);
                                          return;
                                        }),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.collections_outlined),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(AppLocalizations.of(context)!.browseGallery),
                                          ],
                                        )),
                                    Text(AppLocalizations.of(context)!.or),
                                    ElevatedButton(
                                        onPressed: (() {
                                          _pickImage(ImageSource.camera);
                                          return;
                                        }),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.camera_alt_outlined),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(AppLocalizations.of(context)!.useCamera),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            );
                          },
                          style: IconButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            disabledBackgroundColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.12),
                            hoverColor: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.08),
                            focusColor: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.12),
                            highlightColor: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.12),
                          )),
                    ],
                  ),
                  Container(
                    width: w * 0.8,
                    alignment: Alignment.center,
                    child: TextFormField(
                      controller: firstnameControler,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.name,
                        labelStyle:
                            TextStyle(fontSize: (w > 490 && h > 720) ? 25 : 14),
                        hintStyle:
                            TextStyle(fontSize: (w > 490 && h > 720) ? 16 : 12),
                        errorStyle:
                            TextStyle(fontSize: (w > 490 && h > 720) ? 16 : 12),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => value != null && value.isEmpty
                          ? AppLocalizations.of(context)!.validName
                          : null,
                      style:
                          TextStyle(fontSize: (w > 490 && h > 720) ? 25 : 14),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Container(
                    alignment: Alignment.center,
                    width: w * 0.8,
                    child: TextFormField(
                      controller: lastnameControler,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.surname,
                        labelStyle:
                            TextStyle(fontSize: (w > 490 && h > 720) ? 25 : 14),
                        hintStyle:
                            TextStyle(fontSize: (w > 490 && h > 720) ? 16 : 12),
                        errorStyle:
                            TextStyle(fontSize: (w > 490 && h > 720) ? 16 : 12),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => value != null && value.isEmpty
                          ? AppLocalizations.of(context)!.surname
                          : null,
                      style:
                          TextStyle(fontSize: (w > 490 && h > 720) ? 25 : 14),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: 0.03 * h, left: 0.03 * h, right: 0.03 * h),
                    height: 0.08 * h,
                    width: 0.8 * w,
                    child: ElevatedButton(
                        onPressed: setProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 233, 64, 87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.continueText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: (w > 490 && h > 720) ? 30 : 16,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        )),
                  ),
                ]),
              ],
            ),
          ),
        ));
  }

  Future setProfile() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      if (_image != null) {
        final path = _image!.path;
        final extension = p.extension(path); // '.jpg'

        final fileName = user.uid + extension;
        final Storage storage = Storage();
        final addUser = Users(
            id: user.uid,
            firstname: firstnameControler.text.trim(),
            lastname: lastnameControler.text.trim(),
            profileImageURL: 'profilePictures/$fileName',
            userRating: "0",
            hours: 5,
            numRating: 0);
        storage.uploadProfilePicture(path, fileName).then((value) =>
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Intrest(addUser: addUser))));
      } else {
        final addUser = Users(
            id: user.uid,
            firstname: firstnameControler.text.trim(),
            lastname: lastnameControler.text.trim(),
            profileImageURL: 'profilePictures/user.png',
            userRating: "0",
            hours: 5,
            numRating: 0);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Intrest(addUser: addUser)));
      }
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
      Navigator.of(context).pop();
    }
  }
}
