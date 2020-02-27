import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mobinsight/geo_position.dart';

import 'mqtt_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MobInsight',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(title: 'MobInsight'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocationData _locationData;
  MqttService _mqttService = new MqttService();

  @override
  void initState() {
    super.initState();

    initMqtt();
  }

  void initMqtt() async {
    await _mqttService.connectMqtt();

    listenToLocationChanges();
  }

  void setLocation(LocationData location) {
    GeoPosition geoPosition = new GeoPosition(
        latitude: location.latitude, longitude: location.longitude);

    this.setState(() => _locationData = location);

    _mqttService.publish(geoPosition.toJson().toString());
  }

  void listenToLocationChanges() async {
    Location _location = new Location();
    bool _serviceEnabled = await _location.serviceEnabled();

    if (_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    PermissionStatus _permissionsGranted = await _location.hasPermission();

    if (_permissionsGranted == PermissionStatus.DENIED) {
      _permissionsGranted = await _location.requestPermission();
      if (_permissionsGranted != PermissionStatus.GRANTED) {
        return;
      }
    }

    LocationData _currentLocation = await _location.getLocation();
    setLocation(_currentLocation);
    _location.onLocationChanged().listen(setLocation);
  }

  @override
  Widget build(BuildContext context) {
    double _latitude = _locationData != null ? _locationData.latitude : 0.0;
    double _longitude = _locationData != null ? _locationData.longitude : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      Text("Latitude"),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(_latitude.toString()),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text("Longitude"),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(_longitude.toString()),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
