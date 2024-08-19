import 'package:car/models/car_model.dart';
import 'package:car/firebase/firebase_controller.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class LocationPage extends StatefulWidget {
  final Car? car;

  LocationPage({Key? key, required this.car}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final FirebaseController firebaseController = Get.put(FirebaseController());
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  GoogleMapController? mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRentalMonitorings();
    });
  }

  Future<void> initializeMap() async {
    await Future.delayed(
        Duration(milliseconds: 500)); // Ensures controller is ready
    _loadRentalMonitorings(); // Loads and displays markers
  }

  Future<void> _loadRentalMonitorings() async {
    try {
      final rentalMonitoringsData = widget.car != null
          ? await firebaseController.getRentalMonitoringData(
              carID: widget.car!.id)
          : await firebaseController.getRentalMonitoringData(carID: '');
      _updateMarkers(rentalMonitoringsData);
    } catch (error) {
      print('Error fetching rental moni torings: $error');
    }
  }

  void _updateMarkers(List<RentalMonitoring> rentalMonitorings) {
    if (mapController == null) {
      print('Map Controller is not ready yet.');
      return;
    }

    setState(() {
      _markers.clear();
      for (var rentalMonitoring in rentalMonitorings) {
        double latitude = double.tryParse(rentalMonitoring.latitude) ?? 0.0;
        double longitude = double.tryParse(rentalMonitoring.longitude) ?? 0.0;

        if (latitude != 0.0 && longitude != 0.0) {
          String smokePresenceText =
              rentalMonitoring.smokePresence ? "YES" : "NO";

          final marker = Marker(
            markerId: MarkerId(rentalMonitoring.carId ?? 'unknown'),
            position: LatLng(latitude, longitude),
            onTap: () {
              if (_customInfoWindowController.googleMapController != null) {
                _customInfoWindowController.addInfoWindow!(
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${rentalMonitoring.carName}',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Rented By: ${rentalMonitoring.customerName}',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Temperature: ${rentalMonitoring.temperature}°',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Smoke Presence: $smokePresenceText',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          padding: EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                  LatLng(latitude, longitude),
                );
              }
            },
          );
          _markers.add(marker);
        }
      }
    });

    if (widget.car != null && _markers.isNotEmpty) {
      final marker = _markers.firstWhere(
          (m) => m.markerId.value == widget.car!.id,
          orElse: () => _markers.first);
      _focusOnMarker(marker.position);
    } else if (_markers.isNotEmpty) {
      _focusOnMarker(_markers.first.position);
    } else {
      mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(0.0, 0.0), zoom: 2)));
    }
  }

  void _focusOnMarker(LatLng position) {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15)));
  }

  @override
  Widget build(BuildContext context) {
    _loadRentalMonitorings();

    return Scaffold(
        body: Stack(
      // Use a Stack to overlay the CustomInfoWindow on the GoogleMap
      children: <Widget>[
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _customInfoWindowController.googleMapController = controller;
            mapController = controller;
            initializeMap();
          },
          onTap: (LatLng latLng) {
            _customInfoWindowController.hideInfoWindow!();
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(0.0, 0.0), // Default initial position
            zoom: 2,
          ),
          markers: _markers,
        ),
        CustomInfoWindow(
          controller: _customInfoWindowController,
          height: 175,
          width: 250,
          offset: 50, // Offset from the marker position
        ),
      ],
    ));
  }

  @override
  void dispose() {
    mapController?.dispose(); // Properly dispose of the map controller
    super.dispose();
  }
}
