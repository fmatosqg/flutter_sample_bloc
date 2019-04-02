import 'dart:async';

import 'package:bloc_streams/CounterEvent.dart';

class CounterBLoC {
  int _counter = 0;

  CounterBLoC() {
    _counterEventController.stream.listen(_count);
  }

  _count(CounterEvent event) => counterSink.add(++_counter);

  final _counterStreamController = StreamController<int>();

  StreamSink<int> get counterSink => _counterStreamController.sink;

  Stream<int> get streamCounter => _counterStreamController.stream;

  final _counterEventController = StreamController<CounterEvent>();

  Sink<CounterEvent> get counterEventSink => _counterEventController.sink;

  dispose() {
    _counterEventController.close();
    _counterStreamController.close();
  }
}
