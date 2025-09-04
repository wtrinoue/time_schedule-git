import 'package:flutter/material.dart';

class ClockPanel extends StatelessWidget {
  const ClockPanel({super.key, required this.clock});

  final Clock clock;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: SizedBox(
        height: 100,
        width: 100,
        child: Center(
          child: Text(
            style: TextStyle(fontSize: 30),
            "${clock.outputEventHour()}:${clock.outputEventMinute() ~/ 10}${clock.outputEventMinute() % 10}",
          ),
        ),
      ),
    );
  }
}

class Clock {
  const Clock({
    required this.number,
    required this.startHour,
    required this.startMinute,
    required this.minutes,
  });

  final int number;
  final int startHour;
  final int startMinute;
  final int minutes;

  int outputEventHour() {
    int sumOfAllMinutes = (startHour * 60 + startMinute + minutes) % 1440;
    return sumOfAllMinutes ~/ 60;
  }

  int outputEventMinute() {
    int sumOfAllMinutes = (startHour * 60 + startMinute + minutes) % 1440;
    return sumOfAllMinutes % 60;
  }
}
