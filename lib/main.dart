import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GpsMapApp(),
    );
  }
}

class GpsMapApp extends StatefulWidget {
  const GpsMapApp({super.key});

  @override
  State<GpsMapApp> createState() => MapSampleState();
}

class MapSampleState extends State<GpsMapApp> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();


  CameraPosition? _initialCameraPosition;



  @override
  void initState() {
    super.initState();

    init();
  } // 최초 한번만 실행하면 되기 때문에 _determinePosition()을 넣어야 하지만, future다 -> initState에서는 async - await이 불가능 하기에
  // 새로운 함수를 생성하여 그 함수를 넣어주기.


  Future init() async {
 final position = await _determinePosition();

 _initialCameraPosition = CameraPosition(
     target: LatLng (position.latitude, position.longitude),
 zoom: 17,);

 setState(() {

 });


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialCameraPosition == null ?
          const Center(child:  CircularProgressIndicator())
      :

      GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _initialCameraPosition!,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    final position = await Geolocator.getCurrentPosition();
    final cameraPosition = CameraPosition(target: LatLng(position.latitude, position.longitude),
      zoom: 18,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));



  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }


}
