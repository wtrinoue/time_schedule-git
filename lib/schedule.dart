import "dart:convert";
import "event.dart";

Map<String, dynamic> defaultData = {
  "scheduleName": "デフォルト",
  "originHour": 10,
  "originMinute": 0,
  "eventsJsonList": [
    {"number": 1, "times": 3, "name": "Alice"},
    {"number": 2, "times": 5, "name": "Bob"},
  ],
};

class ScheduleManager {
  final Map<String, dynamic> scheduleJsonData;
  late String scheduleName;
  late int originHour;
  late int originMinute;
  late List<Event> eventsList;
  ScheduleManager({required this.scheduleJsonData}) {
    scheduleName = scheduleJsonData["scheduleName"];
    originHour = scheduleJsonData["originHour"];
    originMinute = scheduleJsonData["originMinute"];
    eventsList = jsonListToEventsList(scheduleJsonData["eventsJsonList"]);
  }

  void updateScheduleManager(
    String oldScheduleName,
    int oldOriginHour,
    int oldOriginMinute,
    List<Event> oldEventsList,
  ) {
    scheduleName = oldScheduleName;
    originHour = oldOriginHour;
    originMinute = oldOriginMinute;
    eventsList = oldEventsList;
  }

  Map<String, dynamic> outputScheduleJson() {
    Map<String, dynamic> json = {
      "scheduleName": scheduleName,
      "originHour": originHour,
      "originMinute": originMinute,
      "eventsJsonList": eventsListToJsonList(eventsList),
    };

    return json;
  }
}

void test() {
  String jsonString = jsonEncode(defaultData);
  Map<String, dynamic> json = jsonDecode(jsonString);
  ScheduleManager scheduleManager = ScheduleManager(scheduleJsonData: json);
  print(scheduleManager.scheduleName);
  print(scheduleManager.originHour.toString());
  print(scheduleManager.originMinute.toString());
  print(scheduleManager.eventsList.toString());
  print(scheduleManager.outputScheduleJson());
}
