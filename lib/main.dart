import 'package:bloc_streams/CounterBloc.dart';
import 'package:bloc_streams/CounterEvent.dart';
import 'package:bloc_streams/GlowingButton.dart';
import 'package:flutter/material.dart';

// example from https://medium.com/flutter-community/flutter-bloc-with-streams-6ed8d0a63bb8

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Colors.indigo[800],
//        primaryTextTheme:
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  final _bloc = CounterBLoC();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: GlowingButton(
          MediaQuery.of(context).size,
//          Text("What"),
          FlutterLogo(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
