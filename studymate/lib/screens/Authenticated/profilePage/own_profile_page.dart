import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studymate/provider/authentication.dart';
import 'package:studymate/screens/Authenticated/profilePage/components/body_profile_page.dart';
import 'package:studymate/screens/Authenticated/profilePage/components/edit_timeslots_page.dart';
import 'package:studymate/screens/Authenticated/profilePage/components/updateInterest.dart';
import 'package:studymate/service/storage_service.dart';
import 'package:path/path.dart' as p;

import '../../../../models/user.dart';
import '../../../functions/routingAnimation.dart';
import '../../../models/category.dart';
import '../../../models/timeslot.dart';
import 'components/hoursselection_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OwnProfilePage extends StatefulWidget {
  @override
  State<OwnProfilePage> createState() => _OwnProfilePageState();
}

enum PageOpened {
  none,
  editTImeslots,
  insertTimeslots,
  editPreferences
}

class _OwnProfilePageState extends State<OwnProfilePage> {
  File? _image;
  PageOpened rightPageOpened = PageOpened.none;

  @override
  void initState() {
    super.initState();
  }

  void callbackClosePage(bool isTablet) {
    if (!isTablet) {
      Navigator.pop(context);
    }
    setState(() {
      rightPageOpened = PageOpened.none;
    });
  }

  void callbackOpenEditLesson() {
    setState(() {});
  }

  Stream<List<Category>> readCategory(String category) => FirebaseFirestore
      .instance
      .collection('categories')
      .where('name', isEqualTo: category)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList());

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.noImgSelected)));
        return;
      }
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);

      if (img == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.noImgCropped)));
        return;
      }

      final path = img.path;
      final extension = p.extension(path); // '.jpg'

      final fileName = user.uid + extension;
      final Storage storage = Storage();

      storage.uploadProfilePicture(path, fileName).then((value) =>
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'profileImage': 'profilePictures/$fileName'}));
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.imgLoaded)));
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

  final user = FirebaseAuth.instance.currentUser!;
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    Stream<List<Users>> readUsers() => FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Users.fromJson(doc.data())).toList());
    Stream<List<TimeslotsWeek>> readTimeslot() => FirebaseFirestore.instance
        .collection('timeslots')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TimeslotsWeek.fromJson(doc.data()))
            .toList());

    return StreamBuilder(
        stream: readUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong!');
          } else if (snapshot.hasData) {
            var users = snapshot.data!;

            return StreamBuilder(
                stream: readTimeslot(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong!');
                  } else if (snapshot.hasData) {
                    var timeslots = snapshot.data!;

                    return _buildPage(users.first, timeslots);
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                });
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildPage(Users us, List<TimeslotsWeek> ts) {
    final Storage storage = Storage();
    final isMobile = MediaQuery.of(context).size.shortestSide < 600;


    List<String> interest = [];
    us.categoriesOfInterest!.forEach((element) {
      interest.add(element.toString());
    });
    int randNum = Random().nextInt(100);
    String randomCategory =
        us.categoriesOfInterest![randNum % us.categoriesOfInterest!.length];

    return Row(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  elevation: 0,
                  toolbarHeight: 70,
                  automaticallyImplyLeading: false,
                  //Buttons top
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(

                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    us.hours.toString(),
                                    style: TextStyle(fontSize: 40),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Icon(
                                    Icons.av_timer,
                                    size: 40,
                                  ),
                                ],
                              ),
                              content: Text(AppLocalizations.of(context)!
                                  .helperHoursAvailable(us.hours)),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Close'),
                                  child:
                                      Text(AppLocalizations.of(context)!.close),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                            ),
                            color: Color.fromARGB(211, 255, 255, 255),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                            child: SizedBox(
                              height: 40,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(us.hours.toString()),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Icon(
                                    Icons.av_timer,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            showDragHandle: true,
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => Container(
                              child: Wrap(
                                key: Key("menuModal"),
                                children: [
                                  /*
                                        ListTile(
                                          onTap: () {},
                                          leading: const Icon(Icons.settings),
                                          title: const Text('Edit profile'),
                                        ),
                                         */

                                  ListTile(
                                    onTap: () {
                                      Navigator.pop(
                                          context, 'Edit preferences');
                                      if (isMobile) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    updateInterest(
                                                      interest: interest,
                                                      callbackClosePage:
                                                          callbackClosePage,
                                                      isOpenedRight: false,
                                                    )));
                                      } else {
                                        setState(() {
                                          rightPageOpened =
                                              PageOpened.editPreferences;
                                        });
                                      }
                                    },
                                    leading: const Icon(Icons.favorite),
                                    title: Text(AppLocalizations.of(context)!
                                        .editPreferences),
                                  ),
                                  (() {
                                    if (ts.isEmpty) {
                                      return ListTile(
                                        onTap: () {
                                          Navigator.pop(
                                              context, 'Insert timeslots');
                                          if (isMobile) {
                                            Navigator.of(context).push(
                                                createRoute(HoursSelectionPage(
                                              callbackClosePage:
                                                  callbackClosePage,
                                              isOpenedRight: false,
                                            )));
                                          } else {
                                            setState(() {
                                              rightPageOpened =
                                                  PageOpened.insertTimeslots;
                                            });
                                          }

                                          return;
                                        },
                                        leading: const Icon(Icons.schedule),
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .insertTimeslots),
                                      );
                                    } else {
                                      return ListTile(
                                        onTap: () {
                                          Navigator.pop(
                                              context, 'Edit timeslots');
                                          if (isMobile) {
                                            Navigator.of(context).push(
                                                createRoute(EditTimeslotsPage(
                                              timeslots: ts.first,
                                              callbackClosePage:
                                                  callbackClosePage,
                                              isOpenedRight: false,
                                            )));
                                          } else {
                                            setState(() {
                                              rightPageOpened =
                                                  PageOpened.editTImeslots;
                                            });
                                          }

                                          return;
                                        },
                                        leading: const Icon(Icons.schedule),
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .editTimeslots),
                                      );
                                    }
                                  }()),
                                  _isSigningOut
                                      ? CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                              Color.fromARGB(255, 233, 64, 87)),
                                        )
                                      : ListTile(
                                          onTap: () {
                                            setState(() {
                                              _isSigningOut = true;
                                            });
                                            Authentication.signOutWithGoogle(
                                                context: context);
                                            setState(() {
                                              _isSigningOut = true;
                                            });
                                          },
                                          leading: const Icon(Icons.logout),
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .logout),
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                            ),
                            color: Color.fromARGB(211, 255, 255, 255),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 40,
                              width: 40,
                              child: Center(
                                child: Icon(
                                  Icons.menu,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(70),
                    child: Container(
                      height: 120,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            right: 0,
                            left: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Theme.of(context)
                                        .colorScheme
                                        .background
                                        .withOpacity(0),
                                    Theme.of(context).colorScheme.background
                                  ],
                                ),
                                color: Theme.of(context).colorScheme.background,
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 120,
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 20,
                            right: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: _image == null
                                            ? FutureBuilder(
                                                future: storage.downloadURL(
                                                    us.profileImageURL),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError) {
                                                    return const Text(
                                                        "Something went wrong!");
                                                  } else if (snapshot.hasData) {
                                                    return Image(
                                                      image: NetworkImage(
                                                          snapshot.data!),
                                                    );
                                                  } else {
                                                    return const Card(
                                                      margin: EdgeInsets.zero,
                                                    );
                                                  }
                                                })
                                            : Image(
                                                image: FileImage(_image!),
                                              ),
                                      ),
                                    ),
                                    IconButton(
                                        icon:
                                            const Icon(Icons.mode_edit_outline),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            showDragHandle: true,
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) => Container(
                                              key: Key('modalEdicPic'),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const SizedBox(height: 10),
                                                  ElevatedButton(
                                                      onPressed: (() {
                                                        _pickImage(ImageSource
                                                            .gallery);
                                                        return;
                                                      }),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons
                                                              .collections_outlined),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(AppLocalizations
                                                                  .of(context)!
                                                              .browseGallery),
                                                        ],
                                                      )),
                                                  Text(AppLocalizations.of(
                                                          context)!
                                                      .or),
                                                  ElevatedButton(
                                                      onPressed: (() {
                                                        _pickImage(
                                                            ImageSource.camera);
                                                        return;
                                                      }),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons
                                                              .camera_alt_outlined),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(AppLocalizations
                                                                  .of(context)!
                                                              .useCamera),
                                                        ],
                                                      )),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        style: IconButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          disabledBackgroundColor:
                                              Theme.of(context)
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
                                  child: Row(
                                    children: [
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 10, 10),
                                          child: SizedBox(
                                            child: Column(
                                              children: [
                                                Text(
                                                  us.numRating.toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(AppLocalizations.of(
                                                        context)!
                                                    .reviews),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10, 10, 10, 10),
                                          child: SizedBox(
                                            child: Column(
                                              children: [
                                                Text(
                                                  '${us.userRating}/5.0',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Text(AppLocalizations.of(
                                                        context)!
                                                    .rating),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pinned: true,
                  collapsedHeight: 120,
                  expandedHeight: 280,
                  //Background
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 3,
                            color: Theme.of(context).colorScheme.background,
                          ),
                        ),
                      ),
                      child: StreamBuilder<List<Category>>(
                          stream: readCategory(randomCategory),
                          builder: ((context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text("Something went wrong!");
                            } else if (snapshot.hasData) {
                              final category = snapshot.data!.first;
                              return FutureBuilder(
                                  future:
                                      storage.downloadURL(category.imageURL),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text(
                                          "Something went wrong!");
                                    } else if (snapshot.hasData) {
                                      return Image.network(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                      );
                                    } else {
                                      return SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Card(
                                          margin: EdgeInsets.zero,
                                        ),
                                      );
                                    }
                                  });
                            } else {
                              return const Center(
                                  //child: CircularProgressIndicator(),
                                  );
                            }
                          })),
                    ),
                  ),
                ),
                //BODY LESSON
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                    child: Column(
                      children: [
                        Align(
                          alignment:Alignment.topLeft,
                          child: Text(
                            '${us.firstname} ${us.lastname}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: Container(child: BodyProfilePage()),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        (!isMobile)
            ? const VerticalDivider(thickness: 1, width: 1)
            : SizedBox(),
        (!isMobile && rightPageOpened != PageOpened.none)
            ? Expanded(
                child: (() {
                switch (rightPageOpened) {
                  case PageOpened.none:
                    return Container();
                  case PageOpened.editTImeslots:
                    return Container(
                        child: EditTimeslotsPage(
                      timeslots: ts.first,
                      callbackClosePage: callbackClosePage,
                      isOpenedRight: true,
                    ));
                  case PageOpened.insertTimeslots:
                    return Container(
                        child: HoursSelectionPage(
                      callbackClosePage: callbackClosePage,
                      isOpenedRight: true,
                    ));
                  case PageOpened.editPreferences:
                    return Container(
                        child: updateInterest(
                      interest: interest,
                      callbackClosePage: callbackClosePage,
                      isOpenedRight: true,
                    ));
                }
              }()))
            : SizedBox()
      ],
    );
  }

  /*logout() async {
    FirebaseAuth.instance.signOut();
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>['email'],
    );
    if (await googleSignIn.isSignedIn()) {
      googleSignIn.signOut();
    }
  }*/
}
