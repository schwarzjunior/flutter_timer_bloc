import 'dart:async';

class TimerBloc {
  static final DateTime _refDateTime = DateTime(0);

  final _timerStateController = StreamController<TimerState>();
  final _timerTextController = StreamController<String>();

  Stream<TimerState> get outTimerState => _timerStateController.stream;

  Stream<String> get outTimerText => _timerTextController.stream;

  TimerState get timerState => _timerState;
  TimerState _timerState;

  int get timerValue => _timerValue;
  int _timerValue;

  TimerBloc()
      : _timerState = TimerState.stopped,
        _timerValue = 0 {
    _sendTimerText();
  }

  void _sendTimerState() => _timerStateController.sink.add(_timerState);

  void _sendTimerText() => _timerTextController.sink.add(_timerText);

  void onChangeTimerState() {
    switch (_timerState) {
      case TimerState.stopped:
        _timerState = TimerState.running;
        _startTimer();
        break;
      case TimerState.paused:
        _timerState = TimerState.running;
        _startTimer();
        break;
      case TimerState.running:
        _timerState = TimerState.paused;
        break;
    }
    _sendTimerState();
  }

  void _startTimer({int initialValue}) {
    _timerValue = initialValue ?? _timerValue;
    _timerTickerStream(_timerValue).listen((data) {
      _timerValue = data;
      _sendTimerText();
    });
  }

  void resetTimer() {
    _timerState = TimerState.stopped;
    _sendTimerState();
    _timerValue = 0;
    _sendTimerText();
  }

  Stream<int> _timerTickerStream(int start) async* {
    int tickValue = start;
    yield tickValue;
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      if (_timerState != TimerState.running) break;
      tickValue++;
      yield tickValue;
    }
  }

  String get _timerText {
    final DateTime dt = _refDateTime.add(Duration(seconds: _timerValue)..abs());
    return '${_padZeros(dt.hour)}:${_padZeros(dt.minute)}:${_padZeros(dt.second)}';
  }

  static String _padZeros(int value) => value.toString().padLeft(2, '0');

  void dispose() {
    _timerStateController.close();
    _timerTextController.close();
  }
}

enum TimerState { stopped, paused, running }
