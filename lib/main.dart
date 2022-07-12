/* Create by : Denis Bogoslovskiy*/
import 'package:flutter/material.dart';
import 'Paint/floodfill_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paint Image App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Paint Image App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? title;
  const MyHomePage({Key? key, this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color _fillColor = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title!),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloodFillImage(
                  imageProvider: const AssetImage("assets/car1.jpg"),
                  fillColor: _fillColor,
                  avoidColor: [Colors.transparent, Colors.black],
                  tolerance: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _fillColor = Colors.brown;
                        });
                      },
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.brown)),
                      child:  const Text("Brown",style: TextStyle(color: Colors.black),),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _fillColor = Colors.amber;
                        });
                      },
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.amber)),
                      child: const Text("Amber",style: TextStyle(color: Colors.black),),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _fillColor = Colors.cyan;
                        });
                      },
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.cyan)),
                      child: const Text("Cyan",style: TextStyle(color: Colors.black),),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _fillColor = Colors.white;
                        });
                      },
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.white , side: BorderSide(color: Colors.black54)),
                      child:  Text("White",style: TextStyle(color: Colors.black),),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _fillColor = Colors.red;
                        });
                      },
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.red , side: BorderSide(color: Colors.black54)),
                      child:  Text("White",style: TextStyle(color: Colors.black),),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
