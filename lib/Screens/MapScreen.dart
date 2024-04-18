import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  final dynamic selectedHospital;

  const MapScreen({Key? key, required this.selectedHospital}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  static const LatLng _initialPosition =
      LatLng(-1.2315216391982207, 36.86852477662677);
  LatLng? _presentLocation;


  Set<Marker> _markers = {}; 

  @override
  void initState() {
    super.initState();
    findLocationUpdates();
    if (widget.selectedHospital != null) {
      _centerToHospitalLocation();
    } else {
      fetchHospitals(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) =>
                _mapController.complete(controller),
            initialCameraPosition:
                CameraPosition(target: _initialPosition, zoom: 14),
            markers: _markers, 
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: _centerToCurrentLocation,
                child: Icon(Icons.location_searching),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _centerToCurrentLocation() async {
    if (_presentLocation != null) {
      final GoogleMapController controller = await _mapController.future;
      CameraPosition _newCameraPosition =
          CameraPosition(target: _presentLocation!, zoom: 13);
      await controller
          .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
    }
  }

  //Method to listen for location updates and update the current location on the map
  Future<void> findLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData presentLocation) {
      if (presentLocation.latitude != null &&
          presentLocation.longitude != null) {
        setState(() {
          _presentLocation =
              LatLng(presentLocation.latitude!, presentLocation.longitude!);
        });
      }
    });
  }

  //fetching of the hospitals from the api
  Future<void> fetchHospitals() async {
  try {
    final response = await http.get(
      Uri.parse("https://medicareapi-dy09.onrender.com/getHospitals"),
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> hospitals = jsonData;
      setState(() {
        _markers.clear();
        for (var hospital in hospitals) {
          final lat = hospital["Latitude"]?.toDouble() ?? 0.0;
          final lng = hospital["Longitude"]?.toDouble() ?? 0.0;

          final marker = Marker(
            markerId: MarkerId(hospital["_id"]?.toString() ?? 'unknown'),
            icon: BitmapDescriptor.defaultMarker,
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: hospital["name"],
              snippet: buildHospitalSnippet(hospital),
            ),
          );

          _markers.add(marker);
        }
      });
    } else {
      // This displas an error when loading of maps has encountered an error
      _showErrorDialog();
      print('Failed to load hospitals: ${response.statusCode}');
    }
  } catch (e) {
    // This displays error message on failure to load maps
    _showErrorDialog();
    print('Failed to load hospitals: $e');
  }
}

void _showErrorDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Failed to load maps'),
        content: Text('Please try again later'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  //This is a function to construct a snippet for the info window of a hospital marker on the map
  String buildHospitalSnippet(Map<String, dynamic> hospital) {
    final location = hospital["location"] ?? "No location available";
    final services = hospital["services"] ?? "No services listed";
    return  "$hospital[name]\n$services\nLocation: $location"; 
  }

  //This is a function to center the map camera to the location of the selected hospital
  void _centerToHospitalLocation() async {
    final lat = widget.selectedHospital["Latitude"]?.toDouble() ?? 0.0;
    final lng = widget.selectedHospital["Longitude"]?.toDouble() ?? 0.0;

    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition =
        CameraPosition(target: LatLng(lat, lng), zoom: 13);
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }
}
