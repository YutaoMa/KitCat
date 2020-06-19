import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kit Cat',
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
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: <Widget>[
                Tab(icon: Icon(Icons.pets)),
                Tab(icon: Icon(Icons.favorite)),
              ],
            ),
            title: Text("KitCat"),
          ),
          body: TabBarView(
            children: <Widget>[
              MyPageView(),
              MyPageView(),
            ],
          )
        )
      ),
    );
  }
}

class Cat {
  final String url;

  Cat({this.url});

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      url: json['url'],
    );
  }
}

class MyPageView extends StatefulWidget {
  MyPageView({Key key}) : super(key: key);

  _MyPageViewState createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  PageController _pageController;
  Future<List<Cat>> cats;

  Future<List<Cat>> _fetchImages() async {
    String url = 'https://api.thecatapi.com/v1/images/search?mime_types=gif&limit=50';
    var response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception("Fetch failed: ${response.statusCode}, ${response.body}");
    } else {
      var responseJson = jsonDecode(response.body);
      List<Map<String, dynamic>> responseJsonList = new List<Map<String, dynamic>>.from(responseJson);
      List<Cat> cats = responseJsonList.map((json) => Cat.fromJson(json)).toList();
      return cats;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    cats = _fetchImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Cat>>(
      future: cats,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.hasData) {
          List<Cat> catList = snapshot.data;
          return PageView(
            scrollDirection: Axis.vertical,
            children: catList.map((cat) => Container(
              color: Colors.black,
              child: Image.network(
                cat.url,
                fit: BoxFit.fitWidth,
              ),
            )).toList(),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
