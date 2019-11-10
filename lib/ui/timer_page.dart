import 'package:flutter/material.dart';
import 'package:timer_bloc/blocs/timer_bloc.dart';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  TimerBloc _timerBloc;
  TimerState _timerState;

  @override
  void initState() {
    _timerState = TimerState.stopped;
    _timerBloc = TimerBloc();
    _timerBloc.outTimerState.listen((data) {
      setState(() => _timerState = data);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    IconData btnIcon;
    Color btnColor;

    switch (_timerBloc.timerState) {
      case TimerState.stopped:
        borderColor = Colors.blueAccent;
        btnIcon = Icons.play_circle_filled;
        btnColor = Colors.blue[300];
        break;
      case TimerState.paused:
        borderColor = Colors.yellowAccent;
        btnIcon = Icons.play_circle_outline;
        btnColor = Colors.green[300];
        break;
      case TimerState.running:
        borderColor = Colors.greenAccent;
        btnIcon = Icons.pause;
        btnColor = Colors.orange[300];
        break;
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.access_time, size: 80, color: Colors.white38),
                  const SizedBox(width: 20),
                  Text('TIMER',
                      style: Theme.of(context)
                          .textTheme
                          .display3
                          .copyWith(color: Colors.white38)),
                ],
              )),
          Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 8, color: borderColor),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(90),
                    child: TimerClock(_timerBloc),
                  ),
                ),
              )),
          Expanded(flex: 2, child: _timerControls(btnIcon, btnColor)),
        ],
      ),
    );
  }

  Widget _timerControls(IconData icon, Color color) {
    return Stack(
      alignment: const Alignment(-1, 0),
      children: <Widget>[
        Container(
          alignment: const Alignment(0, 0),
          child: IconButton(
            padding: const EdgeInsets.all(0),
            iconSize: 80,
            alignment: const Alignment(0, 0),
            icon: Icon(icon, color: color.withOpacity(0.6)),
            color: color.withOpacity(0.6),
            onPressed: () {
              _timerBloc.onChangeTimerState();
            },
          ),
        ),
        Visibility(
          visible: _timerState != TimerState.stopped,
          child: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: IconButton(
              alignment: const Alignment(0, 0),
              padding: const EdgeInsets.all(0),
              iconSize: 30,
              icon: const Icon(Icons.stop, size: 30),
              color: Colors.redAccent.withOpacity(0.6),
              onPressed: () {
                _timerBloc.resetTimer();
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timerBloc.dispose();
    super.dispose();
  }
}

class TimerClock extends StatelessWidget {
  final TimerBloc _timerBloc;

  const TimerClock(this._timerBloc, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<String>(
        stream: _timerBloc.outTimerText,
        initialData: '',
        builder: (context, snapshot) {
          return Text(
            snapshot.data,
            style: Theme.of(context).textTheme.display2,
          );
        },
      ),
    );
  }
}
