import 'dart:async';

import 'package:bloc_streams/CounterEvent.dart';

class CounterBLoC {
  int _counter = 0;

  /////////////////////////////
  // public stuff
  CounterBLoC() {
    _counterEventController.stream.listen(_count);
  }

  // used by UI to receive model updates
  Stream<int> get streamCounter => _counterStreamController.stream;

  // used by button to send events
  Sink<CounterEvent> get counterEventSink => _counterEventController.sink;

  ////////////////////////////
  //  private stuff
  _count(CounterEvent event) => _counterStreamController.sink.add(++_counter);

  final _counterStreamController = StreamController<int>();
  final _counterEventController = StreamController<CounterEvent>();

  dispose() {
    _counterEventController.close();
    _counterStreamController.close();
  }
}
