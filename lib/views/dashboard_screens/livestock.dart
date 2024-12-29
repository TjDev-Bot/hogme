// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hogme/utils/custom_buttons.dart';
import 'package:hogme/views/dashboard_screens/history.dart';
import 'package:hogme/views/dashboard_screens/return.dart';
import 'package:hogme/views/dashboard_screens/updatelive.dart';

class LivestockPage extends StatefulWidget {
  const LivestockPage({super.key});

  @override
  State<LivestockPage> createState() => _LivestockPageState();
}

class _LivestockPageState extends State<LivestockPage> {
  int totalLivestocks = 1;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final userID = user.uid;
    Future<Map<String, dynamic>> fetchLive() async {
      Map<String, dynamic> result = {'data': [], 'total': 0};
      try {
        DatabaseReference dbRef = FirebaseDatabase.instance
            .ref()
            .child('livestocks')
          ..keepSynced(true);
        DataSnapshot expSnapshot = (await dbRef.once()).snapshot;

        Map<dynamic, dynamic>? expMap =
            expSnapshot.value as Map<dynamic, dynamic>?;
        if (expMap != null) {
          expMap.forEach((key, value) {
            dynamic releasing = value['releasing'];

            if (releasing is Map<dynamic, dynamic>) {
              bool userReleased = releasing.values.any((userMap) {
                return userMap['userid'].toString().toLowerCase() ==
                    userID.toLowerCase();
              });

              if (userReleased) {
                result['data'].add({
                  'bdate': value['bdate'],
                  'controlnumber': value['controlnumber'],
                  'gender': value['gender'],
                  'releasedto': value['releasedto'],
                  'status': value['status'],
                  'type': value['type'],
                  'releasing': value['releasing'],
                  'liveID': key,
                });
              }
            }
          });

          result['total'] = result['data'].length;
        }
      } catch (error) {
        if (mounted) {}
      }
      return result;
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Livestock',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: SingleChildScrollView(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: fetchLive(),
                  builder: (BuildContext context,
                      AsyncSnapshot<Map<String, dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error Snapshot : ${snapshot.error}');
                    } else if (!snapshot.hasData ||
                        snapshot.data!['total'] == 0) {
                      return const Text('No Data Available');
                    } else {
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 150.0,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Total Livestock',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  '${snapshot.data!['total']}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w500),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Image.asset(
                                      'assets/icons/icon_hogme.png',
                                      height: 50.0,
                                      width: 50.0,
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 180,
                                child: CustomButtons(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ReturnLive(),
                                      ),
                                    );
                                  },
                                  text: "Return Livestocks",
                                  textColor: Colors.white,
                                  buttonColor: Colors.green,
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: CustomButtons(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const History(),
                                      ),
                                    );
                                  },
                                  text: "History Livestocks",
                                  textColor: Colors.white,
                                  buttonColor: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                dataRowColor: MaterialStateProperty.resolveWith(
                                    (Set<MaterialState> states) {
                                  return Colors.white;
                                }),
                                headingRowColor:
                                    MaterialStateProperty.resolveWith(
                                        (Set<MaterialState> states) {
                                  return const Color.fromARGB(255, 17, 54, 25);
                                }),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Control No',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Type',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Gender',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Status',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Age',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Action',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                                rows: snapshot.data!['data'].isEmpty
                                    ? []
                                    : _livestocksList(snapshot.data!['data']),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _livestocksList(List<dynamic> liveData) {
    final user = FirebaseAuth.instance.currentUser?.uid;
    late var userid = user!;
    List<DataRow> rows = [];

    for (var live in liveData) {
      String? controlNo = live['controlnumber'].toString();
      String date = live['bdate'];

      DateTime bdate = DateTime.parse(date);
      Duration duration;
      duration = DateTime.now().difference(bdate);
      int Age = duration.inDays ~/ 365;
      Map<dynamic, dynamic>? releasingId;

      var usersMap = live['releasing'];

      bool hasPendingStatus = false;

      if (usersMap is Map) {
        for (var entry in usersMap.entries) {
          var releasingData = entry.value;
          if (releasingData is Map &&
              releasingData['userid'].toString().toLowerCase() ==
                  userid.toLowerCase()) {
            releasingId = {'releasingid': releasingData['releasingid']};
            // if (releasingData['status'].toString().toLowerCase() == 'approved') {
            //   hasPendingStatus = true;
            // }
            // break;
          }
        }
      }

      // if (!hasPendingStatus) {
      //   continue; // Skip the entry if status is not pending
      // }

      rows.add(DataRow(
        cells: [
          DataCell(
            Text(
              controlNo,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          DataCell(
            Text(
              live['type'].toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          DataCell(
            Text(
              live['gender'].toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          DataCell(
            Text(
              live['status'].toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          DataCell(
            Text(
              '$Age',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
          DataCell(
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => UpdateLive(
                    upLive: live,
                    releasingId: releasingId ?? {},
                  ),
                );
              },
              child: Container(
                width: 80,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ));
    }

    return rows;
  }
}
