import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LatLng _position;

  @override
  Widget build(BuildContext context) {
    final latitude = _position?.latitude;
    final longitude = _position?.longitude;
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps Sample'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'マップで選択した位置情報を表示する',
            ),
            SizedBox(height: 50),
            _position != null
                ? Text(
                    '緯度 : $latitude / 軽度 : $longitude',
                    style: Theme.of(context).textTheme.bodyText2,
                  )
                : Text(
                    '未設定',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MapPage(
                        position: _position,
                      ))).then((value) {
            setState(() {
              _position = value;
            });
          });
        },
        tooltip: 'マップを表示する',
        child: Icon(Icons.map),
      ),
    );
  }
}
