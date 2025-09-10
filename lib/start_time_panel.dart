import 'package:flutter/material.dart';
import "clock.dart";

class StartTimePanel extends StatefulWidget {
  final Clock allStartClock;
  const StartTimePanel({super.key, required this.allStartClock});

  @override
  State<StartTimePanel> createState() => _StartTimePanelState();
}

class _StartTimePanelState extends State<StartTimePanel> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 50,
        width: 400,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(style: TextStyle(fontSize: 25), "開始時間　"),
            Text(
              style: TextStyle(fontSize: 30),
              "${widget.allStartClock.startHour ~/ 10}${widget.allStartClock.startHour % 10}",
            ),
            Text(style: TextStyle(fontSize: 30), ":"),
            Text(
              style: TextStyle(fontSize: 30),
              "${widget.allStartClock.startMinute ~/ 10}${widget.allStartClock.startMinute % 10}",
            ),
          ],
        ),
      ),
    );
  }
}
