import 'package:bloc_streams/CounterBloc.dart';
import 'package:bloc_streams/CounterEvent.dart';
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
      body: StreamBuilder(
        stream: _bloc.streamCounter,
        initialData: 0,
        builder: (context, snapshot) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  snapshot.data.toString(),
                  style: Theme.of(context).textTheme.display1,
                ),
              ],
            ),
          );
//
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bloc.counterEventSink.add(IncrementEvent()),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
}
