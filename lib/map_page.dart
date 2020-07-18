import 'dart:async';
import "dart:math" as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as l;

class MapPage extends StatefulWidget {
  MapPage({Key key, this.position}) : super(key: key);

  final LatLng position;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  l.Location _locationService = l.Location();
  StreamSubscription _locationChangedListen;

  // 現在位置
  l.LocationData _currentLocation;

  // アプリの位置情報
  LatLng _position;

  final places =
      GoogleMapsPlaces(apiKey: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");

  @override
  void initState() {
    super.initState();

    // 現在位置の取得
    _getLocation();
    _locationChangedListen = _locationService.onLocationChanged
        .listen((l.LocationData result) async {
      setState(() {
        _currentLocation = result;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _locationChangedListen?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // アプリの位置情報の登録がすでにあれば初期値としてセット
    if (_position == null) {
      _position = widget.position;
    }

    return new Scaffold(
      // マップのためナビバーなし

      // Google Map を生成して表示
      body: _makeGoogleMap(),

      // タップしたアプリの位置情報を呼び出し元に返すためのボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectPosition(),
        child: Icon(Icons.check),
      ),
    );
  }

  Widget _makeGoogleMap() {
    if (_currentLocation == null) {
      // 現在位置が取れるまではローディング中
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      // マーカー（アプリの位置情報）を作成
      Set<Marker> markers = Set();
      if (_position != null) {
        markers.add(
            Marker(markerId: MarkerId('OnTapMarker'), position: _position));
      }

      // 現在位置とアプリの位置情報との間の距離を計算して print
      if (_currentLocation != null && _position != null) {
        var distance = haversineDistance(
                LatLng(_currentLocation.latitude, _currentLocation.longitude),
                _position)
            .toString();

        print(distance);
      }

      // Google Map ウィジェットを返す
      return GoogleMap(
//        mapType: MapType.hybrid, // Map のタイプ（航空写真とか）

        // 初期表示される位置情報を現在位置から設定
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentLocation.latitude, _currentLocation.longitude),
          zoom: 18.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },

        // 現在位置にアイコン（青い円形のやつ）を置く
        myLocationEnabled: true,

        // マーカー（アプリの位置情報）をセット
        markers: markers,

        // タップイベント
        onTap: (LatLng value) {
          setState(() {
            // タップイベントは位置情報を引数に持つので、それをアプリの位置情報に登録（画面再描画）
            _position = value;
            search().then((stores) {
              List<SimpleDialogOption> selectors = [
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text("店舗を選択しない"),
                ),
              ];
              stores.forEach((element) {
                selectors.add(
                  SimpleDialogOption(
                    onPressed: () {
                      _position = LatLng(element.geometry.location.lat,
                          element.geometry.location.lng);
                      Navigator.pop(context);
                    },
                    child: Text(element.name),
                  ),
                );
              });

              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text("店舗選択"),
                    children: selectors,
                  );
                },
              );
            });
          });
        },
      );
    }
  }

  Future<List<PlacesSearchResult>> search() async {
    PlacesSearchResponse response = await places.searchNearbyWithRadius(
        Location(_position.latitude, _position.longitude), 10);

    // TODO: 確認用の出力
    response.results.forEach((element) {
      print('名前: ' + element.name);
      print('緯度: ' + (element.geometry.location.lat).toString());
      print('経度: ' + (element.geometry.location.lng).toString());
      print('types: ' + element.types.join(","));
    });

    return response.results;
  }

  /// 現在位置を取得する（非同期）
  void _getLocation() async {
    var location = await _locationService.getLocation();
    _currentLocation = location;
  }

  /// マーカーの位置情報を引数に、呼び出し元画面へ遷移する
  void _selectPosition() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("アプリの位置情報"),
          content: Text("この位置でよろしいですか？"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);

                // ここでアプリの位置情報を渡している
                Navigator.of(context).pop(_position);
              },
            ),
          ],
        );
      },
    );
  }

  double haversineDistance(LatLng mk1, LatLng mk2) {
    // Radius of the Earth in Kilometers
    var R = 6371.0710;

    // 角度（ radians ）に変換
    var latitudeRadians1 = mk1.latitude * (math.pi / 180);
    var latitudeRadians2 = mk2.latitude * (math.pi / 180);

    // 緯度の角度差を求める
    var diffLatitude = latitudeRadians2 - latitudeRadians1;

    // 軽度の角度差を求める
    var diffLongitude = (mk2.longitude - mk1.longitude) * (math.pi / 180);

    // 2点間の距離を計算する
    var d = 2 *
        R *
        math.asin(math.sqrt(
            math.sin(diffLatitude / 2) * math.sin(diffLatitude / 2) +
                math.cos(latitudeRadians1) *
                    math.cos(latitudeRadians2) *
                    math.sin(diffLongitude / 2) *
                    math.sin(diffLongitude / 2)));
    return d;
  }
}
