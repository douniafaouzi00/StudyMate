import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:line_icons/line_icons.dart';
import 'package:search_map_location/search_map_location.dart';
import 'package:search_map_location/utils/google_search/latlng.dart' as latlng;
import 'package:search_map_location/utils/google_search/place.dart' as place;
import '../../../component/utils.dart';
import '../../../models/msg.dart';
import '../../../models/notification.dart';
import '../../../models/user.dart';
import '../../../service/storage_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPosition extends StatefulWidget {
  final String? chatId;
  final Users? reciver;
  final String? fromId;
  final int? num;
  const SearchPosition({
    super.key,
    required this.chatId,
    required this.fromId,
    required this.reciver,
    required this.num,
  });
  @override
  _SearchPositionState createState() => _SearchPositionState();
}

const kGoogleApiKey = "AIzaSyC3otkGlIdVywPmB7VQS9CYEBEphXSZtko";

class _SearchPositionState extends State<SearchPosition> {
  late Position _currentPosition = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime(0),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);
  late GoogleMapController _controller;
  late Set<Marker> _markers = {};
  final LatLng _initialCameraPosition = const LatLng(45.475714, 9.1365314);
  late String title = AppLocalizations.of(context)!.sharePosition;
  late bool localizationAllowed = true;
  Utils utils = Utils();
  late LatLng _destination = LatLng(0, 0);

  @override
  void dispose() {
    // Dispose any resources or cleanup code here

    super.dispose();
  }

  //this method is used for settings the map during the creation phase
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _markers = {};
    _getCurrentLocation();
  }

  //this method is used for create the markers on the map
  _createMarker(String? desc) async {
    final Set<Marker> markers = {};

    Marker m = Marker(
      markerId: MarkerId("destination"),
      position: LatLng(_destination.latitude, _destination.longitude),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: desc,
      ),
    );
    markers.add(m);

    _markers = markers;
  }

  Future<void> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      localizationAllowed = false;
      print('Location services are disabled.');
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // The user permanently denied location permission
      localizationAllowed = false;
      print('Location permissions are permanently denied.');
    }

    if (permission == LocationPermission.denied) {
      // Request location permission
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // The user denied location permission
        localizationAllowed = false;
        print('Location permissions are denied.');
      }
    }
  }

  //this method is used to get the current locations
  _getCurrentLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition();
    _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
        zoom: 12.0,
      ),
    ));
  }

  //this method is used to get the current locations
  _getDestinationLocation() async {
    _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: _destination,
        zoom: 12.0,
      ),
    ));
  }

  //this return the map frame
  Stack _mapFrame(double w) {
    return Stack(
      children: <Widget>[
        Center(
          child: ClipRRect(
            child: (localizationAllowed)
                ? GoogleMap(
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    //zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    compassEnabled: true,
                    rotateGesturesEnabled: true,
                    //mapToolbarEnabled: false,
                    tiltGesturesEnabled: true,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                        target: _initialCameraPosition, zoom: 11),
                    markers: _markers,
                  )
                : Container(
                    margin: EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.tunrOnGPS,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromARGB(255, 233, 64, 87)),
                    )),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: (localizationAllowed)
              ? Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
                  child: IconButton(
                      onPressed: () => _getCurrentLocation(),
                      icon: const Icon(Icons.my_location_outlined)),
                )
              : SizedBox(),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: (localizationAllowed)
              ? Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
                  child: IconButton(
                      onPressed: () {
                        if (_destination != LatLng(0, 0)) {
                          _getDestinationLocation();
                        }
                      },
                      icon: const Icon(LineIcons.map)),
                )
              : SizedBox(),
        ),
        Align(
          alignment: Alignment.topRight,
          child: (localizationAllowed)
              ? IconButton(
                  onPressed: () {
                    if (_destination != LatLng(0, 0) && localizationAllowed) {
                      send();

                      Navigator.of(context).pop();
                    } else {
                      utils.showAlertDialog(
                          context,
                          AppLocalizations.of(context)!.attention,
                          AppLocalizations.of(context)!.selectLocation);
                    }
                  },
                  icon: Container(
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.all(10),
                    margin:
                        const EdgeInsets.only(bottom: 10, right: 60, top: 5),
                    child: const Icon(
                      Icons.send,
                      color: Color.fromARGB(255, 233, 64, 87),
                      size: 30,
                    ),
                  ))
              : SizedBox(),
        ),
        Align(
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                Expanded(
                  child: (localizationAllowed)
                      ? Container(
                          margin: const EdgeInsets.only(
                              bottom: 10, top: 10, left: 10, right: 125),
                          //width: 0.6 * w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Color.fromARGB(255, 255, 255, 255)),
                          child: SearchLocation(
                            apiKey: kGoogleApiKey,
                            // The language of the autocompletion
                            language:
                                Localizations.localeOf(context).languageCode,
                            // location is the center of a place and the radius provided here are between this radius of this place search result
                            //will be provided,you can set this LatLng dynamically by getting user lat and long in double value
                            location: latlng.LatLng(
                                latitude: 9.072264, longitude: 7.491302),
                            radius: 1100,
                            iconColor: Color.fromARGB(255, 233, 64, 87),
                            onSelected: (place.Place place) async {
                              final geolocation = await place.geolocation;
                              latlng.LatLng tmp = geolocation!.coordinates;
                              if (mounted) {
                                setState(() {
                                  _destination =
                                      LatLng(tmp.latitude, tmp.longitude);
                                });
                              }

                              _createMarker(place.description);
                              _getDestinationLocation();
                            },
                          ))
                      : SizedBox(),
                ),
              ],
            ))
      ],
    );
  }

  Future send() async {
    try {
      if (_destination != LatLng(0, 0)) {
        String docId = "";
        final docUser = FirebaseFirestore.instance.collection('msg');
        final addMsg = Msg(
            view: false,
            chatId: widget.chatId,
            addtime: Timestamp.now(),
            from_uid: widget.fromId,
            //to_uid: widget.reciver.id,
            content:
                "l4t:${_destination.latitude};l0n:${_destination.longitude}");
        final json = addMsg.toFirestore();
        await docUser.add(json).then((DocumentReference doc) {
          docId = doc.id;
        });
        print(
            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ${_destination.latitude},${_destination.longitude}");

        docUser.doc(docId).update({'id': docId});
        int num = widget.num! + 1;
        FirebaseFirestore.instance
            .collection('chat')
            .doc(widget.chatId)
            .update({
          'num_msg': num,
          'last_msg': addMsg.content,
          'last_time': addMsg.addtime,
          'from_uid': addMsg.from_uid,
          'view': false
        });
        final docChat = FirebaseFirestore.instance.collection('notification');
        await docChat.add({}).then((DocumentReference doc) {
          var notif = Notifications(
            id: doc.id,
            from_id: addMsg.from_uid,
            to_id: widget.reciver!.id,
            eventId: addMsg.id,
            type: "message",
            content: "${addMsg.content}",
            view: false,
            time: Timestamp.now(),
          );
          final json = notif.toFirestore();
          docChat.doc(doc.id).update(json);
        });
      }
    } on FirebaseAuthException catch (e) {
      utils.showAlertDialog(context, "error", e.message!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double w = size.width;
    final Storage storage = Storage();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: const Color.fromARGB(18, 233, 64, 87),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  padding: const EdgeInsets.only(top: 60.0, bottom: 10),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_ios)),
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: FutureBuilder(
                              future: storage
                                  .downloadURL(widget.reciver!.profileImageURL),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Text("Something went wrong!");
                                } else if (snapshot.hasData) {
                                  return Image(
                                    image: NetworkImage(snapshot.data!),
                                  );
                                } else {
                                  return const Card(
                                    margin: EdgeInsets.zero,
                                  );
                                }
                              }),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: _mapFrame(w),
                )
              ]),
        ));
  }
}
