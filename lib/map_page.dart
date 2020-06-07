import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key, this.position}) : super(key: key);

  final LatLng position;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();

  LocationData _currentLocation;
  Location _locationService = Location();

  LatLng _position;

  @override
  void initState() {
    super.initState();

    _getLocation();
    _locationService.onLocationChanged.listen((LocationData result) async {
      setState(() {
        _currentLocation = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_position == null) {
      _position = widget.position;
    }

    return new Scaffold(
      body: _makeGoogleMap(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop(_position);
        },
        child: Icon(Icons.check),
      ),
    );
  }

  Widget _makeGoogleMap() {
    if (_currentLocation == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      Set<Marker> markers = Set();
      if (_position != null) {
        markers.add(
            Marker(markerId: MarkerId('OnTapMarker'), position: _position));
      }
      return GoogleMap(
//        mapType: MapType.hybrid, // Map のタイプ（航空写真とか）
        initialCameraPosition: CameraPosition(
          target:LatLng(_currentLocation.latitude, _currentLocation.longitude),
          zoom: 17.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
        onTap: (LatLng value) {
          setState(() {
            _position = value;
          });
        },
      );
    }
  }

  void _getLocation() async {
    var location = await _locationService.getLocation();
    setState(() {
      _currentLocation = location;
    });
  }
}
