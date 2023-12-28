import 'package:assignment/Bloc/CalenderBloc/CalenderBloc.dart';
import 'package:assignment/Calender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {

  final CalendarBloc calendarBloc = CalendarBloc();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<CalendarBloc>(create: (context) => calendarBloc)
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Calendar(),
    );
  }
}


