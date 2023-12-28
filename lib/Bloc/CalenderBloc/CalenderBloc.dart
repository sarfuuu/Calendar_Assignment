import 'package:assignment/Bloc/CalenderBloc/CalenderEvent.dart';
import 'package:assignment/Bloc/CalenderBloc/CalenderState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarBloc extends Bloc<CalendarE, CalendarState> {
  dynamic data;

  CalendarBloc() : super((CalendarInitialize())) {
    on<CalendarE>((event, emit) async {
      if (event.isDays) {
        emit(CalendarToggleSwitchToDays({"result": event.isDays}));
      } else {
        DateTime? startDate = event.dates['startDate'];
        DateTime? endDate = event.dates['endDate'];
        List<dynamic> dateRange = [];
        List months = [
          'JAN',
          'FEB',
          'MAR',
          'APR',
          'MAY',
          'JUN',
          'JUL',
          'AG',
          'SEP',
          'OCT',
          'NOV',
          'DEC'
        ];
        if (startDate != null && endDate != null) {
          for (var i = startDate.day; i <= endDate.day; i++) {
            dateRange.add({"date": i,"month":months[startDate.month - 1]});
          }
        }
        emit(CalendarToggleSwitchToWeek({"result": event.isDays,"dateRange":dateRange}));
      }
    });
  }
}
