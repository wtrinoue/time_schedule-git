import 'dart:convert';

import "package:flutter/material.dart";
import 'package:time_schedule/schedule.dart';
import 'package:sqflite/sqflite.dart';
import 'clock.dart';
import 'event.dart';
import 'regist_dialog.dart';
import 'start_time_panel.dart';
import 'schedule.dart';
import 'sql.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Database db;
  late ScheduleManager scheduleManager;
  late List<Event> events;
  late List<Clock> clocks;
  late Clock originClock;

  @override
  void initState() {
    super.initState();
    // events = [];
    // clocks = [];
    // originClock = Clock(number: 0, startHour: 0, startMinute: 0, minutes: 0);
    initSetUp();
  }

  Future<void> initSetUp() async {
    db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      "schedules",
      where: "id = 1",
    );
    Map<String, dynamic> scheduleJson = jsonDecode(result[0]["content"]);
    scheduleManager = ScheduleManager(scheduleJsonData: scheduleJson);
    events = scheduleManager.eventsList;
    clocks = [];
    originClock = Clock(
      number: 0,
      startHour: scheduleManager.originHour,
      startMinute: scheduleManager.originMinute,
      minutes: 0,
    );
    setState(() {});
  }

  Future<void> changeDatabase() async {
    scheduleManager.updateScheduleManager(
      "a",
      originClock.startHour,
      originClock.startMinute,
      events,
    );
    print(jsonEncode(scheduleManager.outputScheduleJson()));
    updateDatabase(db, 1, jsonEncode(scheduleManager.outputScheduleJson()));
  }

  List<Clock> returnNullClocks() {
    setState(() {});
    return <Clock>[];
  }

  List<Event> returnNullEvents() {
    setState(() {});
    return <Event>[];
  }

  List<Clock> eventsMakeClocks(Clock originClock, List<Event> events) {
    //イベントごとの時間をもとに時刻を形成
    List<Clock> newClocks = [];
    setState(() {
      for (int cnt = 0; cnt < events.length + 1; cnt++) {
        newClocks.add(
          Clock(
            number: cnt,
            startHour: originClock.startHour,
            startMinute: originClock.startMinute,
            minutes: sumOfEventTimesUntil(events, cnt),
          ),
        );
      }
    });
    return newClocks;
  }

  Future<Clock> changeOriginClock(Clock originClock) async {
    Clock lastOriginStartClock;

    TimeOfDay? picked = await showTimePicker(
      context: context,
      builder: (context, child) {
        return RegistOriginTimeDialogNo1(originClock: originClock);
      },
      initialTime: TimeOfDay(
        hour: originClock.startHour,
        minute: originClock.startMinute,
      ),
    );
    if (picked != null) {
      lastOriginStartClock = Clock(
        number: 0,
        startHour: picked.hour,
        startMinute: picked.minute,
        minutes: 0,
      );
    } else {
      lastOriginStartClock = originClock;
    }

    return lastOriginStartClock;
  }

  Future<List<Event>> addNewEvent(int addNumber, List<Event> events) async {
    int lastMinutes = 0;
    String lastEventNameText = "";

    await showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: RegistEventDialogNo1(
            onChangedMinutes: (minutesList) {
              lastMinutes = minutesList;
            },
            onChangedName: (eventNameText) {
              lastEventNameText = eventNameText;
            },
          ),
        );
      },
    );

    // List<Event> newEvents =
    //     events.sublist(0, addNumber - 1) +
    //     [Event(number: 0, times: lastMinutes, name: lastEventNameText)] +
    //     events.sublist(addNumber, events.length - 1);

    List<Event> newEvents = [];

    for (int cnt = 0; cnt < addNumber; cnt++) {
      newEvents.add(events[cnt]);
    }
    newEvents.add(
      Event(number: 0, times: lastMinutes, name: lastEventNameText),
    );
    for (int cnt = addNumber; cnt < events.length; cnt++) {
      newEvents.add(events[cnt]);
    }

    for (int cnt = 0; cnt < newEvents.length; cnt++) {
      newEvents[cnt].number = cnt;
    }

    return newEvents;
  }

  Future<Event> changeEventContent(Event event) async {
    int lastMinutes = 0;
    String lastEventNameText = "";

    await showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: RegistEventDialogNo1(
            onChangedMinutes: (minutesList) {
              lastMinutes = minutesList;
            },
            onChangedName: (eventNameText) {
              lastEventNameText = eventNameText;
            },
            event: event,
          ),
        );
      },
    );

    setState(() {});
    return Event(
      number: event.number,
      times: lastMinutes,
      name: lastEventNameText,
    );
  }

  Future<int> changeClockReturnEventTimes(
    Clock clock,
    List<Clock> clocks,
  ) async {
    if (clock.number == 0) {
      return 0;
    } else {
      int lastHour = 0;
      int lastMinute = 0;

      await showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: RegistClockDialogNo1(
              onChangedHour: (hour) {
                lastHour = hour;
              },
              onChangedMinute: (minute) {
                lastMinute = minute;
              },
              clock: clock,
              beforeClock: clocks[clock.number - 1],
            ),
          );
        },
      );

      int newEventTimes =
          (lastHour - clocks[clock.number - 1].outputEventHour()) * 60 +
          (lastMinute - clocks[clock.number - 1].outputEventMinute());

      setState(() {});
      return newEventTimes;
    }
  }

  List<Widget> eventsToEventPanels(List<Event> events) {
    List<Widget> eventPanels = [];
    for (var event in events) {
      eventPanels.add(
        GestureDetector(
          child: EventPanel(event: event),
          onTap: () async {
            events[event.number] = await changeEventContent(event);
          },
        ),
      );
    }
    return eventPanels;
  }

  List<Widget> clocksToClockPanels(List<Clock> oneClocks) {
    List<Widget> clockPanels = [];
    for (var clock in oneClocks) {
      clockPanels.add(
        GestureDetector(
          child: ClockPanel(clock: clock),
          onTap: () async {
            if (clock.number != 0) {
              events[clock.number - 1]
                  .times = await changeClockReturnEventTimes(clock, oneClocks);
            }
          },
        ),
      );
    }
    return clockPanels;
  }

  @override
  Widget build(BuildContext context) {
    clocks = eventsMakeClocks(originClock, events);
    //理ロード時に上のコードを呼び出すことによってちゃんと動作する。
    List<Widget> eventPanels = eventsToEventPanels(events);
    List<Widget> clockPanels = clocksToClockPanels(clocks);

    List<Widget> widgets = List.generate(events.length, (index) {
      return Column(
        children: [
          Row(
            children: [
              clockPanels[index],
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    events = await addNewEvent(index, events);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: SizedBox(
                    height: 20,
                    width: 50,
                    child: Center(
                      child: Text(style: TextStyle(color: Colors.white), "追加"),
                    ),
                  ),
                ),
              ),
            ],
          ),
          eventPanels[index],
        ],
      );
    });

    Widget widget = Column(
      children: [
        GestureDetector(
          child: StartTimePanel(allStartClock: originClock),
          onTap: () async {
            originClock = await changeOriginClock(originClock);
            setState(() {});
          },
        ),
        SizedBox(
          height: 600,
          child: SingleChildScrollView(
            child: Column(
              children:
                  widgets +
                  <Widget>[
                    Row(
                      children: [
                        clockPanels[events.length],
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () async {
                              events = await addNewEvent(events.length, events);
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: SizedBox(
                              height: 20,
                              width: 50,
                              child: Center(
                                child: Text(
                                  style: TextStyle(color: Colors.white),
                                  "追加",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Center(child: Text("タイムスケジュールアプリ"))),
      body: widget,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              events = returnNullEvents();
            },
            child: Text("消去"),
          ),
          ElevatedButton(
            onPressed: () {
              changeDatabase();
            },
            child: Text("保存"),
          ),
        ],
      ),
    );
  }
}

/*
「これからの希望」
このアプリの目的は開始時間と各イベントのかかる時間をもとに一日のスケジュールを組むことにある。
よって、開始時間と各イベントの時間によって別要素が決まるようにしなければいけない。
つまり。時刻は一日の開始時間と各イベントの時間に縦続する。
消去できるようにする。

「仕様について」
パネルは基本的に表示のみにしている。
関数はできるだけグローバル変数をいじくる形にしないようにしている。
開始時間とイベント間の時間で決まっている。


 */

//以下の形式にする
String a() {
  Map<String, List<Map<String, dynamic>>> data = {
    "schedulesJsonList": [
      {
        "scheduleName": "一日目",
        "originHour": 19,
        "originMinute": 10,
        "eventsJsonList": [
          {"number": 1, "times": 3, "name": "Alice"},
          {"number": 2, "times": 5, "name": "Bob"},
        ],
      },
      {
        "scheduleName": "二日目",
        "originHour": 19,
        "originMinute": 10,
        "eventsJsonList": [
          {"number": 1, "times": 3, "name": "Alice"},
          {"number": 2, "times": 5, "name": "Bob"},
        ],
      },
    ],
  };

  return jsonEncode(data);
}
