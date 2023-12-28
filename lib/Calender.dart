import 'package:assignment/Bloc/CalenderBloc/CalenderBloc.dart';
import 'package:assignment/Bloc/CalenderBloc/CalenderEvent.dart';
import 'package:assignment/Bloc/CalenderBloc/CalenderState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with TickerProviderStateMixin {
  final DateRangePickerController _controller = DateRangePickerController();
  final scaffoldState = GlobalKey<ScaffoldState>();
  late TabController tabController;
  late TabController tabControllerforDays;
  String title = "My Calendar";
  bool isDaySheetOpen = false;
  bool isWeekSheetOpen = false;
  List<dynamic> dataWeek = [];
  bool isSameDate(DateTime? date1, DateTime? date2) {
    if (date2 == date1) {
      return true;
    }
    if (date1 == null || date2 == null) {
      return false;
    }
    return date1.month == date2.month &&
        date1.year == date2.year &&
        date1.day == date2.day;
  }

  void _onSelectionWeekChanged(DateRangePickerSelectionChangedArgs args) {
    int firstDayOfWeek = DateTime.sunday % 7;
    int endDayOfWeek = (firstDayOfWeek - 1) % 7;
    endDayOfWeek = endDayOfWeek < 0 ? 7 + endDayOfWeek : endDayOfWeek;
    PickerDateRange ranges = args.value;
    DateTime date1 = ranges.startDate!;
    DateTime date2 = (ranges.endDate ?? ranges.startDate)!;
    if (date1.isAfter(date2)) {
      var date = date1;
      date1 = date2;
      date2 = date;
    }
    int day1 = date1.weekday % 7;
    int day2 = date2.weekday % 7;

    DateTime dat1 = date1.add(Duration(days: (firstDayOfWeek - day1)));
    DateTime dat2 = date2.add(Duration(days: (endDayOfWeek - day2)));

    if (!isSameDate(dat1, ranges.startDate) ||
        !isSameDate(dat2, ranges.endDate)) {
      isWeekSheetOpen = true;
      _controller.selectedRange = PickerDateRange(dat1, dat2);
      BlocProvider.of<CalendarBloc>(context).add(CalendarE(false, {
        "startDate": _controller.selectedRange!.startDate,
        "endDate": _controller.selectedRange!.endDate
      }));
      scaffoldState.currentState!.showBottomSheet(
        (context) => weekBottomDialog(),
        constraints: const BoxConstraints(maxHeight: 520),
      );
    }
  }

  Future<void> launchPhoneNumber(String phoneNumber) async {
    String url = 'tel:' + phoneNumber;

    if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }else {
      throw 'Could not launch $phoneNumber';
    }
}


  void _onSelectionDayChanged(DateRangePickerSelectionChangedArgs args) {
    isDaySheetOpen = true;
    scaffoldState.currentState!.showBottomSheet(
      (context) => daysBottomDialog(),
      constraints: const BoxConstraints(maxHeight: 520),
    );
  }

  @override
  void initState() {
    BlocProvider.of<CalendarBloc>(context).add(CalendarE(true, null));
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: 4,
      vsync: this,
    );
    tabControllerforDays = TabController(
      initialIndex: 0,
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    tabControllerforDays.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ToggleSwitch(
              minWidth: 60,
              cornerRadius: 6,
              borderWidth: 2,
              radiusStyle: false,
              inactiveBgColor: Colors.white,
              borderColor: const [Colors.blue],
              initialLabelIndex: 0,
              totalSwitches: 2,
              labels: const ['Day', 'Week'],
              onToggle: (index) {
                if (isDaySheetOpen) {
                  Navigator.popUntil(
                      context, ModalRoute.withName(Navigator.defaultRouteName));
                  isDaySheetOpen = false;
                }
                if (isWeekSheetOpen) {
                  Navigator.popUntil(
                      context, ModalRoute.withName(Navigator.defaultRouteName));
                  isWeekSheetOpen = false;
                }
                if (index == 0) {
                  BlocProvider.of<CalendarBloc>(context)
                      .add(CalendarE(true, null));
                } else {
                  BlocProvider.of<CalendarBloc>(context).add(CalendarE(false, {
                    "startDate": _controller.selectedRange?.startDate,
                    "endDate": _controller.selectedRange?.endDate
                  }));
                }
              },
            ),
          ),
        ],
        title:
            BlocBuilder<CalendarBloc, CalendarState>(builder: (context, state) {
          if (state is CalendarToggleSwitchToDays) {
            return const Text(
              "My Calendar",
              style: TextStyle(color: Colors.black),
            );
          } else if (state is CalendarToggleSwitchToWeek) {
            return const Text(
              "In App Calendar",
              style: TextStyle(color: Colors.black),
            );
          } else {
            return Container();
          }
        }),
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) {
          if (state is CalendarToggleSwitchToWeek) {
            dataWeek = state.response['dateRange'];
            return SfDateRangePicker(
              controller: _controller,
              view: DateRangePickerView.month,
              monthViewSettings: const DateRangePickerMonthViewSettings(),
              onSelectionChanged: _onSelectionWeekChanged,
              selectionMode: DateRangePickerSelectionMode.range,
            );
          } else if (state is CalendarToggleSwitchToDays) {
            return SfDateRangePicker(
              controller: _controller,
              view: DateRangePickerView.month,
              monthViewSettings: const DateRangePickerMonthViewSettings(),
              onSelectionChanged: _onSelectionDayChanged,
              selectionMode: DateRangePickerSelectionMode.single,
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  weekBottomDialog() {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 6.0)]),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(6))),
                  height: 4,
                  width: 60,
                )
              ],
            ),
          ),
          DefaultTabController(
            length: 4,
            child: TabBar(
              controller: tabController,
              padding: EdgeInsets.zero,
              labelColor: Colors.black,
              indicatorColor: Colors.black54,
              tabs: [
                Tab(
                  text: "All(170)",
                ),
                Tab(
                  text: "HRD(17)",
                ),
                Tab(
                  text: "Tech 1(24)",
                ),
                Tab(
                  text: "Follow up 1(29)",
                ),
              ],
            ),
          ),
          Expanded(
              child: TabBarView(
            controller: tabController,
            children: [
              Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.03),
                  child: BlocBuilder<CalendarBloc, CalendarState>(
                    builder: (context, state) {
                      if (state is CalendarToggleSwitchToWeek) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: dataWeek.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int i) {
                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                margin: EdgeInsets.only(
                                    bottom: i == 6 ? 10 : 0,
                                    left: 6,
                                    right: 6,
                                    top: 13),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(6)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        blurRadius: 4.0,
                                      ),
                                    ]),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 44,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          dataWeek[i]['month'],
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          dataWeek[i]['date'].toString(),
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 18,
                                    ),
                                    Expanded(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.black38,
                                                      width: 0.8),
                                                  shape: BoxShape.circle),
                                              child: const Center(
                                                child: Text(
                                                  "03",
                                                  style: TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: const Text(
                                                "HRD",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black45,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.black38,
                                                      width: 0.8),
                                                  shape: BoxShape.circle),
                                              child: const Center(
                                                child: Text(
                                                  "02",
                                                  style: TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: const Text(
                                                "Tech 1",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black45,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.black38,
                                                      width: 0.8),
                                                  shape: BoxShape.circle),
                                              child: const Center(
                                                child: Text(
                                                  "05",
                                                  style: TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: const Text(
                                                "Floow up",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black45,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  border: Border.all(
                                                      color: Colors.black38,
                                                      width: 0.8),
                                                  shape: BoxShape.circle),
                                              child: const Center(
                                                child: Text(
                                                  "10",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: const Text(
                                                "Total",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black45,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )),
                                    const SizedBox(
                                      width: 18,
                                    ),
                                  ],
                                ),
                              );
                            });
                      } else {
                        return Container();
                      }
                    },
                  )),
              Container(
                child: Center(
                  child: Text(
                    "HRD",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                ),
              ),
              Container(
                child: Center(
                  child: Text(
                    "Tech 1",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                ),
              ),
              Container(
                child: Center(
                  child: Text(
                    "Follow up",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  daysBottomDialog() {
    isDaySheetOpen = true;
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(14),topRight: Radius.circular(14)),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 6.0)]),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(6))),
                  height: 4,
                  width: 60,
                )
              ],
            ),
          ),
          DefaultTabController(
            length: 4,
            child: TabBar(
              controller: tabControllerforDays,
              padding: EdgeInsets.zero,
              labelColor: Colors.black,
              indicatorColor: Colors.black54,
              tabs: const [
                Tab(
                  text: "All(170)",
                ),
                Tab(
                  text: "HRD(17)",
                ),
                Tab(
                  text: "Tech 1(24)",
                ),
                Tab(
                  text: "Follow up 1(29)",
                ),
              ],
            ),
          ),
          Expanded(
              child: TabBarView(
                controller: tabControllerforDays,
                children: [
                  Container(
            padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03),
            child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int i) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        margin: EdgeInsets.only(
                            bottom: i == 3 ? 10 : 0, left: 6, right: 6, top: 13),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 4.0,
                              ),
                            ]),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context).size.width * 0.04
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Balram Naidu",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: const Text(
                                          "ID LOREM122432YGG",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: const Text(
                                              "Offered: ",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: const Text(
                                              "₹X,XX,XXX",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(top: 3),
                                            child: const Text(
                                              "Current: ",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(top: 3),
                                            child: const Text(
                                              "₹X,XX,XXX",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 9,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(top: 3),
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: i == 0 || i == 2 ? Colors.orange: i == 1 ? Colors.red : Colors.black),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.only(top: 3),
                                            child: Text(
                                              i == 0 || i == 2 ? "Medium Priority" : i == 1 ? "High Priority" : "Medium Priority",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: i == 0 || i == 2 ? Colors.orange: i == 1 ? Colors.red : Colors.orange,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 9,
                                      ),
                                      
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                    right: 12,top: 12
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.7), blurRadius: 4.0)]
                                  ),
                                  child: InkWell(
                                    onTap: (){
                                      launchPhoneNumber("+91 9999999999");
                                    },
                                    child: const Icon(Icons.call_outlined,color: Colors.blue,)),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12
                              ),
                              height: 0.7,
                              color: Colors.grey.withOpacity(0.7),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.height * 0.01,
                                horizontal: MediaQuery.of(context).size.width * 0.04
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Due Date",
                                      style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                              fontWeight: FontWeight.w500),),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text("05 Jun 23",
                                      style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600),)
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Due Date",
                                      style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                              fontWeight: FontWeight.w500),),
                                              SizedBox(
                                        height: 3,
                                      ),
                                      Text("05 Jun 23",
                                      style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600),)
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Due Date",
                                      style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                              fontWeight: FontWeight.w500),),
                                              SizedBox(
                                        height: 3,
                                      ),
                                      Text("05 Jun 23",
                                      style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600),)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
          ),
                  Container(
                child: Center(
                  child: Text(
                    "HRD",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                ),
              ),
              Container(
                child: Center(
                  child: Text(
                    "Tech 1",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                ),
              ),
              Container(
                child: Center(
                  child: Text(
                    "Follow up",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                ),
              ),
            
                ],
              )),
        ],
      ),
    );
  }
}
