// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DatabaseReference dbReleasing =
      FirebaseDatabase.instance.ref().child('livestocks')..keepSynced(true);
  DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users')
    ..keepSynced(true)
    ..keepSynced(true);
  // List<String> schedules = [
  //   'Releasing og hogs',
  //   'Releasing og hogs',
  //   'Releasing og hogs',
  //   'Releasing og hogs',
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: dbReleasing.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Text("No Data Available");
                }

                Map<dynamic, dynamic> livestockData =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                // if (livestockData == null) {
                //   return const Text("No data available");
                // }
                return TableCalendar(
                  rowHeight: MediaQuery.of(context).size.height / 7,
                  firstDay:
                      DateTime.utc(_focusedDay.year, _focusedDay.month, 1),
                  lastDay: DateTime.utc(2040, 10, 20),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  eventLoader: (day) {
                    List<String> releaseDates = [];

                    for (var livestockKey in livestockData.keys) {
                      var livestock = livestockData[livestockKey];

                      if (livestock != null && livestock['releasing'] is Map) {
                        Map<dynamic, dynamic> releasingData =
                            livestock['releasing'] as Map<dynamic, dynamic>;

                        for (var releaseKey in releasingData.keys) {
                          var release = releasingData[releaseKey];

                          // Check if 'releasedDate' exists and is a String
                          if (release != null &&
                              release['releasedDate'] is String) {
                            DateTime releaseDate =
                                DateTime.parse(release['releasedDate']);

                            if (_dateFormat(releaseDate) == _dateFormat(day)) {
                              releaseDates.add(
                                  '${livestock['controlnumber']} - ${livestock['type']}');
                            }
                          }
                        }
                      }
                    }

                    return releaseDates;
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _showReleaseModal(selectedDay, livestockData);
                      });
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReleaseModal(
      DateTime selectedDay, Map<dynamic, dynamic> livestockData) async {
    List<String> names = [];

    DataSnapshot usersSnapshot = (await userRef.once()).snapshot;
    Map<dynamic, dynamic> usersData = usersSnapshot.value as Map;

    if (usersSnapshot.value == null) {
      return;
    }

    for (var livestockKey in livestockData.keys) {
      var livestock = livestockData[livestockKey];

      if (livestock != null && livestock['releasing'] is Map) {
        Map<dynamic, dynamic> releasingData =
            livestock['releasing'] as Map<dynamic, dynamic>;

        for (var releaseKey in releasingData.keys) {
          var release = releasingData[releaseKey];

          if (release != null &&
              release['releasedDate'] is String &&
              release['userid'] != null) {
            DateTime releaseDate = DateTime.parse(release['releasedDate']);
            if (_dateFormat(releaseDate) == _dateFormat(selectedDay)) {
              var userId = release['userid'];
              if (userId != null && usersData.containsKey(userId)) {
                var userData = usersData[userId];
                var userName =
                    userData['firstname'] + ' ' + userData['lastname'];
                if (userName != null) {
                  names.add(userName);
                }
              }
            }
          }
        }
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          width: double.maxFinite,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Members who received livestock',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Text(
                _dateFormat(selectedDay),
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              for (var name in names)
                SizedBox(
                  height: MediaQuery.of(context).size.height / 15,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB9F6CA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>> fetchReleaseDates() async {
    DataSnapshot releasingSnapshot = (await dbReleasing.once()).snapshot;
    Map<dynamic, dynamic>? releasingData =
        releasingSnapshot.value as Map<dynamic, dynamic>;

    List<String> releaseDates = releasingData.keys.whereType<String>().toList();
    return releaseDates;
  }

  String _dateFormat(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
