import 'package:flutter/material.dart';

class EventPanel extends StatelessWidget {
  const EventPanel({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue, width: 2),
      ),
      child: Container(
        height: 100,
        width: 400,
        child: Row(
          children: [
            SizedBox(width: 20),
            Container(
              width: 60,
              child: Text(style: TextStyle(fontSize: 30), "${event.times}"),
            ),
            SizedBox(width: 5),
            Container(
              width: 150,
              child: Text(style: TextStyle(fontSize: 20), event.name),
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  Event({required this.number, required this.times, required this.name});

  int number;
  int times;
  String name;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "number": number,
      "times": times,
      "name": name,
    };
    return data;
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      number: json["number"],
      times: json["times"],
      name: json["name"],
    );
  }
}

int sumOfEventTimesUntil(List<Event> events, int number) {
  int minutes = 0;
  int num = number;
  for (int i = 0; i < num; i++) {
    minutes = minutes + events[i].times;
  }
  return minutes;
}

void change(Event event) {
  event.number = 0;
}
