import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:line_icons/line_icons.dart';
import 'package:studymate/models/user.dart';
import '../../../service/storage_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SharePosition extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Users reciver;
  const SharePosition({
    super.key,
    required this.reciver,
    required this.latitude,
    required this.longitude,
  });
  @override
  _SharePositionState createState() => _SharePositionState();
}

class _SharePositionState extends State<SharePosition> {
  late Position _currentPosition;
  late GoogleMapController _controller;
  late Set<Marker> _markers = {};
  final LatLng _initialCameraPosition = const LatLng(45.475714, 9.1365314);
  late String title = AppLocalizations.of(context)!.sharedPosition;
  late bool localizationAllowed = true;
  @override
  void initState() {
    super.initState();
    _getAddressFromLatLng(); // Call your initialization function here
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      await placemarkFromCoordinates(widget.latitude, widget.longitude)
          .then((List<Placemark> placemarks) {
        Placemark place = placemarks[0];
        if (placemarks.isEmpty) {
          title = AppLocalizations.of(context)!.sharedPosition;
        } else {
          setState(() {
            title = "${place.street},  ${place.subAdministrativeArea}";
          });
        }
      }).catchError((e) {
        debugPrint(e);
      });
    } catch (e) {
      title = AppLocalizations.of(context)!.sharedPosition;
    }
  }

  //this method is used for settings the map during the creation phase
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _markers = {};
    //_getCurrentLocation();
    _getAddressFromLatLng();
    _createMarker(widget.latitude, widget.longitude, "destination", title);
    _getDestinationLocation();
  }

  //this method is used for create the markers on the map
  _createMarker(double lat, double lon, String id, String desc) async {
    final Set<Marker> markers = {};

    Marker m = Marker(
      markerId: MarkerId(id),
      position: LatLng(lat, lon),
      icon: BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: desc,
      ),
    );
    markers.add(m);

    setState(() {
      _markers = markers;
    });
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
        target: LatLng(widget.latitude, widget.longitude),
        zoom: 12.0,
      ),
    ));
  }

  //this return the map frame
  Stack _mapFrame() {
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
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
            child: (localizationAllowed)
                ? IconButton(
                    onPressed: () => _getCurrentLocation(),
                    icon: const Icon(Icons.my_location_outlined))
                : SizedBox(),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
            child: (localizationAllowed)
                ? IconButton(
                    onPressed: () => _getDestinationLocation(),
                    icon: const Icon(LineIcons.map))
                : SizedBox(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    return Scaffold(
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
                              .downloadURL(widget.reciver.profileImageURL),
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
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
            Expanded(
              child: _mapFrame(),
            )
          ]),
    ));
  }
}
