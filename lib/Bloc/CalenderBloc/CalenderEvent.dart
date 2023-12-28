import 'package:flutter/material.dart';

@immutable
abstract class CalendarEvent{}

class CalendarE extends CalendarEvent{
  bool isDays;
  dynamic dates;
 
  CalendarE(this.isDays,this.dates);
}