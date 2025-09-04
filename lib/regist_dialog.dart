import 'package:flutter/material.dart';
import 'event_panel.dart';
import 'clock_panel.dart';

class RegistEventDialog extends StatefulWidget {
  final ValueChanged<int> onChangedMinutes;
  final ValueChanged<String> onChangedName;
  final Event? event;
  const RegistEventDialog({
    super.key,
    required this.onChangedMinutes,
    required this.onChangedName,
    this.event,
  });

  @override
  State<RegistEventDialog> createState() => _RegistEventDialogState();
}

class _RegistEventDialogState extends State<RegistEventDialog> {
  List<int> minutesList = [0, 0, 0];
  List<int> firstMinutesList = [0, 0, 0];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      controller.text = widget.event!.name;
      firstMinutesList = <int>[
        widget.event!.times ~/ 60,
        (widget.event!.times % 60) ~/ 10,
        widget.event!.times % 10,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 300,
        width: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectNumberWidget(
                      limitNum: 9,
                      onChanged: (value) {
                        minutesList[0] = value;
                      },
                      firstNum: firstMinutesList[0],
                    ),
                    Text("時間"),
                    SelectNumberWidget(
                      limitNum: 5,
                      onChanged: (value) {
                        minutesList[1] = value;
                      },
                      firstNum: firstMinutesList[1],
                    ),
                    SelectNumberWidget(
                      limitNum: 9,
                      onChanged: (value) {
                        minutesList[2] = value;
                      },
                      firstNum: firstMinutesList[2],
                    ),
                    Text("分"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(child: EventTextField(controller: controller)),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.onChangedName(controller.text);
                          widget.onChangedMinutes(
                            minutesList[0] * 60 +
                                minutesList[1] * 10 +
                                minutesList[2],
                          );
                        });
                        Navigator.pop(context);
                      },
                      child: Text("閉じる"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RegistClockDialog extends StatefulWidget {
  final ValueChanged<int> onChangedHour;
  final ValueChanged<int> onChangedMinute;
  final Clock beforeClock;
  final Clock clock;

  const RegistClockDialog({
    super.key,
    required this.onChangedHour,
    required this.onChangedMinute,
    required this.clock,
    required this.beforeClock,
  });

  @override
  State<RegistClockDialog> createState() => _RegistClockDialogState();
}

class _RegistClockDialogState extends State<RegistClockDialog> {
  List<int> timeList = [];
  List<int> firstTimeList = [];

  @override
  void initState() {
    super.initState();
    timeList = [
      widget.clock.outputEventHour() ~/ 10,
      widget.clock.outputEventHour() % 10,
      widget.clock.outputEventMinute() ~/ 10,
      widget.clock.outputEventMinute() % 10,
    ];
    firstTimeList = timeList;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 250,
        width: 350,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectNumberWidget(
                  limitNum: 2,
                  onChanged: (value) {
                    timeList[0] = value;
                  },
                  firstNum: firstTimeList[0],
                ),
                SelectNumberWidget(
                  limitNum: 9,
                  onChanged: (value) {
                    timeList[1] = value;
                  },
                  firstNum: firstTimeList[1],
                ),
                Text("時"),
                SelectNumberWidget(
                  limitNum: 5,
                  onChanged: (value) {
                    timeList[2] = value;
                  },
                  firstNum: firstTimeList[2],
                ),
                SelectNumberWidget(
                  limitNum: 9,
                  onChanged: (value) {
                    timeList[3] = value;
                  },
                  firstNum: firstTimeList[3],
                ),
                Text("分"),
              ],
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  int newHour = timeList[0] * 10 + timeList[1];
                  int newMinute = timeList[2] * 10 + timeList[3];
                  int newTimes =
                      (newHour * 60 + newMinute) -
                      (widget.beforeClock.outputEventHour() * 60 +
                          widget.beforeClock.outputEventMinute());
                  if (newTimes >= 0) {
                    widget.onChangedHour(newHour);
                    widget.onChangedMinute(newMinute);
                    Navigator.pop(context);
                  } else {}
                },
                child: Text("閉じる"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistOriginTimeDialog extends StatefulWidget {
  final Clock originClock;

  const RegistOriginTimeDialog({super.key, required this.originClock});

  @override
  State<RegistOriginTimeDialog> createState() => _RegistOriginTimeDialogState();
}

class _RegistOriginTimeDialogState extends State<RegistOriginTimeDialog> {
  @override
  Widget build(BuildContext context) {
    return TimePickerDialog(
      initialTime: TimeOfDay(
        hour: widget.originClock.startHour,
        minute: widget.originClock.startMinute,
      ),
    );
  }
}

class SelectNumberWidget extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int limitNum;
  final int? firstNum;

  const SelectNumberWidget({
    super.key,
    required this.limitNum,
    required this.onChanged,
    this.firstNum,
  });

  @override
  State<SelectNumberWidget> createState() => _SelectNumberWidgetState();
}

class _SelectNumberWidgetState extends State<SelectNumberWidget> {
  late int num;

  @override
  void initState() {
    super.initState();
    if (widget.firstNum != null) {
      num = widget.firstNum!;
      widget.onChanged(num);
    } else {
      num = 0;
    }
  }

  void addNum() {
    setState(() {
      if (num < widget.limitNum) {
        num++;
      }
    });
    widget.onChanged(num);
  }

  void subNum() {
    setState(() {
      if (num > 0) {
        num--;
      }
    });
    widget.onChanged(num);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 50,
      child: Column(
        children: [
          ElevatedButton(onPressed: addNum, child: Text("+")),
          SizedBox(
            height: 70,
            child: Center(
              child: Text(style: TextStyle(fontSize: 40), num.toString()),
            ),
          ),
          ElevatedButton(onPressed: subNum, child: Text("-")),
        ],
      ),
    );
  }
}

class EventTextField extends StatefulWidget {
  final TextEditingController controller;
  const EventTextField({super.key, required this.controller});

  @override
  State<EventTextField> createState() => _EventTextFieldState();
}

class _EventTextFieldState extends State<EventTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 200,
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Enter your event name',
          border: OutlineInputBorder(),
        ),
        controller: widget.controller,
      ),
    );
  }
}
