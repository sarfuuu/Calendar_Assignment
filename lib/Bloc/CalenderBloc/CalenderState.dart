import 'package:flutter/material.dart';

@immutable
abstract class CalendarState{}

class  CalendarInitialize extends CalendarState{}


class  CalendarToggleSwitchToWeek extends CalendarState{
  dynamic response;
   CalendarToggleSwitchToWeek(this.response);
}

class  CalendarToggleSwitchToDays extends CalendarState{
  dynamic response;
   CalendarToggleSwitchToDays(this.response);
}

class  CalendarLoaded extends CalendarState{
  final dynamic response;
   CalendarLoaded(this.response);
}

class  CalendarError extends CalendarState{
  final dynamic error;
   CalendarError(this.error);
}