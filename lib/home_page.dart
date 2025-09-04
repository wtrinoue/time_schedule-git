import "package:flutter/material.dart";
import 'clock_panel.dart';
import 'event_panel.dart';
import 'regist_dialog.dart';
import 'start_time_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Event> events = [];
  List<Clock> clocks = [];
  Clock originClock = Clock(
    number: 0,
    startHour: 0,
    startMinute: 0,
    minutes: 0,
  );

  void addNewClock() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      TimeOfDay selectedTime = picked;
      setState(() {
        clocks.add(
          Clock(
            number: clocks.length,
            startHour: selectedTime.hour,
            startMinute: selectedTime.minute,
            minutes: 10,
          ),
        );
      });
    }
  }

  void deleteAllClock() {
    setState(() {
      clocks = [];
    });
  }

  void deleteAllEvent() {
    setState(() {
      events = [];
    });
  }

  void eventsToClocks(Clock allStartClock) {
    //イベントごとの時間をもとに時刻を形成
    clocks = [];
    setState(() {
      for (int cnt = 0; cnt < events.length; cnt++) {
        clocks.add(
          Clock(
            number: cnt,
            startHour: allStartClock.startHour,
            startMinute: allStartClock.startMinute,
            minutes: sumOfEventTimesUntil(events, cnt),
          ),
        );
      }
    });
  }

  Future<Clock> changeOriginClock(Clock originClock) async {
    Clock lastOriginStartClock;

    TimeOfDay? picked = await showTimePicker(
      context: context,
      builder: (context, child) {
        return RegistOriginTimeDialog(originClock: originClock);
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

  void addNewEvent() async {
    int lastMinutes = 0;
    String lastEventNameText = "";

    await showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: RegistEventDialog(
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
    events.add(
      Event(number: events.length, times: lastMinutes, name: lastEventNameText),
    );
    setState(() {});
  }

  void changeEventContent(Event event) async {
    int lastMinutes = 0;
    String lastEventNameText = "";

    await showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: RegistEventDialog(
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

    events[event.number] = Event(
      number: event.number,
      times: lastMinutes,
      name: lastEventNameText,
    );

    eventsToClocks(originClock);

    setState(() {});
  }

  void changeClockContent(Clock clock) async {
    if (clock.number == 0) {
    } else {
      int lastHour = 0;
      int lastMinute = 0;

      await showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: RegistClockDialog(
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

      events[clock.number - 1] = Event(
        number: clock.number - 1,
        times: newEventTimes,
        name: events[clock.number - 1].name,
      );

      setState(() {});
    }
  }

  List<Widget> createEventPanels(List<Event> events) {
    List<Widget> eventPanels = [];
    for (var event in events) {
      eventPanels.add(
        GestureDetector(
          child: EventPanel(event: event),
          onTap: () {
            changeEventContent(event);
          },
        ),
      );
    }
    return eventPanels;
  }

  List<Widget> createClockPanels(List<Clock> clocks) {
    List<Widget> clockPanels = [];
    for (var clock in clocks) {
      clockPanels.add(
        GestureDetector(
          child: ClockPanel(clock: clock),
          onTap: () {
            changeClockContent(clock);
          },
        ),
      );
    }
    return clockPanels;
  }

  @override
  Widget build(BuildContext context) {
    eventsToClocks(originClock);
    List<Widget> eventPanels = createEventPanels(events);
    List<Widget> clockPanels = createClockPanels(clocks);

    Widget widget = SizedBox(
      height: 650,
      child: SingleChildScrollView(
        child: Column(
          children:
              <Widget>[
                GestureDetector(
                  child: StartTimePanel(allStartClock: originClock),
                  onTap: () async {
                    originClock = await changeOriginClock(originClock);
                    setState(() {});
                  },
                ),
              ] +
              List.generate(events.length, (index) {
                return Row(children: [clockPanels[index], eventPanels[index]]);
              }),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Center(child: Text("タイムスケジュールアプリ"))),
      body: widget,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: addNewEvent, child: Text("追加")),
          ElevatedButton(onPressed: deleteAllEvent, child: Text("消去")),
        ],
      ),
    );
  }
}

/*
このアプリの目的は開始時間と各イベントのかかる時間をもとに一日のスケジュールを組むことにある。
よって、開始時間と各イベントの時間によって別要素が決まるようにしなければいけない。
つまり。時刻は一日の開始時間と各イベントの時間に縦続する。
パネルは基本的に表示のみにしている。
 */
