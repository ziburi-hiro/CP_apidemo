import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:lottie/lottie.dart';
import 'package:weather/weather.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '天気予報'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //現在地取得のための変数
  double _latitude = 0.0;
  double _longitude = 0.0;
  String country = '未取得';
  String administrativeArea = '未取得';
  String locality = '未取得';
  String weather = '未取得';
  String temperature = '未取得';
  String realTemp = '未取得';
  String date = '未取得';

  @override
  Widget build(BuildContext context) {

    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset(
                'assets/images/weather.json',
                errorBuilder: (context, error, stackTrace) {
                  return const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(),
                  );
                }
            ),
            const Text('天気予報APP',style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),),

            const SizedBox(
              height: 20,
            ),

            Visibility(
              visible: (country != '未取得'),
              child: Container(
                height: screenSize.height*0.2,
                width: screenSize.width*0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text('$country $locality',style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        decoration: TextDecoration.underline
                      ),),
                    ),

                    Container(
                      height: 50,
                      width: screenSize.width*0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('☁︎',style: TextStyle(
                            fontSize: 40,
                          ),),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(temperature,style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),)
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text('体感気温：$realTemp',style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text('(取得時間：$date)',style: const TextStyle(
                        fontSize: 12
                      ),),
                    ),

                  ],
                ),
              ),
            ),

            SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: (){
                getWeather();
              },
              child: const Text('現在地の天気を取得',style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),),
            ),

          ],
        ),
      ),
    );
  }
  //位置情報取得のためのメソッド
  //https://zenn.dev/kazutxt/books/flutter_practice_introduction/viewer/23_chapter3_gps

  Future<void> getLocation() async {
    // 権限を取得
    LocationPermission permission = await Geolocator.requestPermission();
    // 権限がない場合は戻る
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('位置情報取得の権限がありません');
      return;
    }
    // 位置情報を取得
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      // 北緯がプラス、南緯がマイナス
      _latitude = position.latitude;
      // 東経がプラス、西経がマイナス
      _longitude = position.longitude;
      print('現在地の緯度は、$_latitude');
      print('現在地の経度は、$_longitude');
    });
    //取得した緯度経度からその地点の地名情報を取得する
    final placeMarks =
    await geoCoding.placemarkFromCoordinates(_latitude, _longitude);
    final placeMark = placeMarks[0];
    print("現在地の国は、${placeMark.country}");
    print("現在地の県は、${placeMark.administrativeArea}");
    print("現在地の市は、${placeMark.locality}");
    setState(() {
      country = placeMark.country!;
      administrativeArea = placeMark.administrativeArea!;
      locality = placeMark.locality!;
    });
  }

  //天気情報を取得するためのメソッド
  //https://qiita.com/YoxMox/items/e29caf6ae8df2e55f0c4
  void getWeather() async {
    // 権限を取得
    LocationPermission permission = await Geolocator.requestPermission();
    // 権限がない場合は戻る
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print('位置情報取得の権限がありません');
      return;
    }
    //エラー処理
    //https://eda-inc.jp/post-5028/#anchor-try-catch
    try {
      await getLocation();
      //https://api.openweathermap.org/data/2.5/weather?q=$location&appid=0651339b01382e4be760cc07ca9d8708
      //自身のAPIキーを入力
      String key = "c056dd90f170f64d8b5c1f5f889a75f3";
      // double lat = 33.5487; //latitude(緯度)
      // double lon = 130.4629; //longitude(経度)
      double lat = _latitude; //latitude(緯度)
      double lon = _longitude; //longitude(経度)
      WeatherFactory wf = new WeatherFactory(key);

      Weather w = await wf.currentWeatherByLocation(lat, lon);

      print('天気情報は$w');
      print('天気は、${w.weatherMain}');
      print('天気(詳細)は、${w.weatherIcon}');
      print('気温は、${w.temperature}');
      print('体感温度は、${w.tempFeelsLike}');
      print('取得時間は、${w.date}');

      setState(() {
        weather = w.weatherMain!;
        temperature = w.temperature!.toString();
        realTemp = w.tempFeelsLike!.toString();
        date = w.date!.toString();
      });

    } catch (e) {
      //exceptionが発生した場合のことをかく
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // addBookToFirebase()のthrowで定義した文章を
            // e.toString()を使って表示している。
            title: const AutoSizeText(
              '位置情報が取得できません！',
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.pinkAccent),
              minFontSize: 10,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
            content: const AutoSizeText(
              '本アプリの位置情報の利用を許可して下さい',
              style: TextStyle(
                fontSize: 12.0,
              ),
              minFontSize: 10,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),

            actions: <Widget>[
              ElevatedButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
