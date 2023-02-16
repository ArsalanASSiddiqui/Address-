import 'dart:developer';

import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:clima/services/location.dart';

import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your
  // application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  bool _isChecked = false;
  String Location = 'Current Location';
  //String? lat;
  //String? long;
  //String? _currentAddress;
  //Position? _currentPosition;
  String? _currentAddress;
  Position? _currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        //${place.locality}, ${place.country},
        //${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}
        _currentAddress =
            '${place.street.toString()}, ${place.subLocality.toString()}, ${place.subAdministrativeArea.toString()}, ${place.postalCode.toString()}';

        //print('${place.street}');
      });
    }).catchError((e) {
      debugPrint(e);
    });
    print('this is Address $_currentAddress.latitude');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                child: SizedBox(
              child: Text(
                'LAT: ${_currentPosition?.latitude ?? ""},LNG: ${_currentPosition?.longitude ?? ""},ADDRESS: ${_currentAddress ?? ""}',
              ),
            )),
            // TextField(
            //   controller: _textController,
            //   decoration: InputDecoration(
            //     border: OutlineInputBorder(),
            //     labelText:
            //         'LAT: ${_currentPosition?.latitude ?? ""},LNG: ${_currentPosition?.longitude ?? ""},ADDRESS: ${_currentAddress ?? ""}',
            //   ),
            // ),
            SizedBox(height: 20.0),
            CheckboxListTile(
              value: _isChecked,
              onChanged: (value) async {
                setState(() {
                  _isChecked = value!;
                });
                if (_isChecked) {
                  Text('LAT: ${_currentPosition?.latitude ?? ""}');
                  Text('LNG: ${_currentPosition?.longitude ?? ""}');
                  Text('ADDRESS: ${_currentAddress ?? ""}');
                  const SizedBox(height: 40);
                  _getCurrentPosition();
                }
              },
              title: Text('Live location'),
            ),
          ],
        ),
      ),
    );
  }
}
