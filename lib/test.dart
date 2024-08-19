import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MyApp> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      markers.add(Marker(
        markerId: MarkerId('marker1'),
        position: LatLng(-6.284845660580077, 107.17067504157188),
        // infoWindow: InfoWindow(title: 'San Francisco'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(-6.284845660580077, 107.17067504157188),
            zoom: 15,
          ),
          markers: markers,
        ),
      ),
    );
  }

}
