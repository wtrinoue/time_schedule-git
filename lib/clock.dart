import 'package:flutter/material.dart';

class ClockPanel extends StatelessWidget {
  const ClockPanel({super.key, required this.clock});

  final Clock clock;
  @override
  Widget build(BuildContext context) {
    Color clockColor = switch (clock.number) {
      0 => Colors.yellow,
      _ => Colors.white,
    };
    return Card(
      color: clockColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: SizedBox(
        height: 40,
        width: 100,
        child: Center(
          child: Text(
            style: TextStyle(fontSize: 20),
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
