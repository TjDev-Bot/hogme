// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hogme/views/dashboard_screens/home1.dart';
import 'package:hogme/views/dashboard_screens/prevrequest.dart';

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  List<String> uniqueBreederValues = [];
  List<String> uniqueMonths = [];
  List<String> uniqueControllNo = [];
  Map<String, dynamic> livestockData = {};

  String? selectedValueBreeder;
  String? selectedValueMonth;
  String? selectedControlNo;
  late TextEditingController desCtrl;

  @override
  void initState() {
    desCtrl = TextEditingController();
    fetchUniqueBreederValues();
    super.initState();
  }

  @override
  void dispose() {
    desCtrl.dispose();
    super.dispose();
  }

  void createRequest() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userID = user.uid;

    if (selectedValueBreeder == null || selectedValueMonth == null) {
      _showErrorDialog('Please Select both breeder and months');
      return;
    }

    // Find livestock key based on selected breeder, month, and control number
    String? livestockKey = await findLivestockKey();
    if (livestockKey == null) {
      _showErrorDialog('Livestock not found');
      return;
    }

    DatabaseReference requestRef =
        FirebaseDatabase.instance.ref('livestocks/$livestockKey/request');
    var newReq = requestRef.push();

    await newReq.set({
      "status": 'pending',
      "lisID": livestockKey,
      "userID": userID,
      "description": desCtrl.text,
      "date": DateTime.now().toUtc().toString(),
    });

    _showSuccessDialog('Request Success');
  }

  Future<String?> findLivestockKey() async {
    String? livestockKey;

    Query dbLive = FirebaseDatabase.instance.ref('livestocks');
    DataSnapshot snapshot = (await dbLive.once()).snapshot;

    if (snapshot.value != null && snapshot.value is Map) {
      livestockData = Map<String, dynamic>.from(snapshot.value! as Map);

      livestockData.forEach((key, livestock) {
        String livestockGender = livestock['gender'];
        DateTime bdate = DateTime.parse(livestock['bdate']);
        DateTime now = DateTime.now();
        int monthsDifference =
            (now.year - bdate.year) * 12 + now.month - bdate.month;

        if (livestock['request'] == '' && livestock['status'] == 'alive') {
          if (livestockGender == selectedValueBreeder &&
              monthsDifference.toString() == selectedValueMonth &&
              livestock['controlnumber'] == selectedControlNo) {
            livestockKey = key;
          }
        }
      });
    }

    return livestockKey;
  }

  String? getKeyForValue(String? value) {
    for (var livestock in livestockData.keys) {
      if (livestockData[livestock]['gender'] == value) {
        return livestock;
      }
    }
    return null;
  }

  void updateMonthsDropdown(String? key) {
    uniqueMonths.clear();
    fetchUniqueMonthsForBreeder(selectedValueBreeder!);
  }

  void updateControllDropdown(String? key) {
    uniqueControllNo.clear();
    fetchUniqueControllNumbersForBreederAndMonth(
        selectedValueBreeder!, selectedValueMonth!);
  }

  void fetchUniqueControllNumbersForBreederAndMonth(
      String breed, String selectedMonth) async {
    Query dbLive = FirebaseDatabase.instance.ref('livestocks');
    DataSnapshot snapshot = (await dbLive.once()).snapshot;

    if (snapshot.value != null && snapshot.value is Map) {
      livestockData = Map<String, dynamic>.from(snapshot.value! as Map);

      livestockData.forEach((key, livestock) {
        String livestockGender = livestock['gender'];
        DateTime bdate = DateTime.parse(livestock['bdate']);
        DateTime now = DateTime.now();
        int monthsDifference =
            (now.year - bdate.year) * 12 + now.month - bdate.month;

        if (livestock['request'] == '' && livestock['status'] == 'alive') {
          if (livestockGender == breed &&
              monthsDifference.toString() == selectedMonth) {
            setState(() {
              selectedControlNo = livestock['controlnumber'];
            });
          }
        }
      });
    }
  }

  void fetchUniqueBreederValues() async {
    Query dbLive = FirebaseDatabase.instance.ref('livestocks');
    DataSnapshot snapshot = (await dbLive.once()).snapshot;

    if (snapshot.value != null && snapshot.value is Map) {
      livestockData = Map<String, dynamic>.from(snapshot.value! as Map);

      livestockData.forEach((key, livestock) {
        String livestockGender = livestock['gender'];

        if (livestock['request'] == '' && livestock['status'] == 'alive') {
          if (!uniqueBreederValues.contains(livestockGender)) {
            uniqueBreederValues.add(livestockGender);
          }
        }
      });

      if (uniqueBreederValues.isNotEmpty && uniqueMonths.isNotEmpty) {
        selectedValueBreeder = uniqueBreederValues[0];
        selectedValueMonth = uniqueMonths[0];
      }
      setState(() {});
    }
  }

  void fetchUniqueMonthsForBreeder(String breed) async {
    Query dbLive = FirebaseDatabase.instance.ref('livestocks');
    DataSnapshot snapshot = (await dbLive.once()).snapshot;

    if (snapshot.value != null && snapshot.value is Map) {
      livestockData = Map<String, dynamic>.from(snapshot.value! as Map);

      livestockData.forEach((key, livestock) {
        String livestockGender = livestock['gender'];
        DateTime bdate = DateTime.parse(livestock['bdate']);
        DateTime now = DateTime.now();
        int monthsDifference =
            (now.year - bdate.year) * 12 + now.month - bdate.month;

        if (livestock['request'] == '' && livestock['status'] == 'alive') {
          if (livestockGender == breed &&
              !uniqueMonths.contains(monthsDifference.toString())) {
            uniqueMonths.add(monthsDifference.toString());
          }
        }
      });

      if (uniqueMonths.isNotEmpty) {
        selectedValueMonth = uniqueMonths[0];
      }
      setState(() {});
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home1(),
                  ),
                );
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.green[900],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        actions: [
          Image.asset(
            'assets/icons/icon_hogme.png',
            height: 30,
            width: 30,
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Hogme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 34, 70, 35)),
            ),
            const SizedBox(height: 30.0),
            _typeDropdown(),
            const SizedBox(height: 30.0),
            _typeDropdownMonth(),
            const SizedBox(height: 30.0),
            _typeDropdownControllNo(),
            const SizedBox(height: 30.0),
            const Text(
              'Additional Details',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 30.0),
            Container(
              height: 150.0,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: TextField(
                controller: desCtrl,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PrevHistory()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 34, 70, 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: const Text(
                    'Previous Request',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0), // Add some spacing between buttons
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => createRequest(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 34, 70, 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: const Text(
                    'Request',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type of Hog',
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        const SizedBox(height: 8.0),
        DropdownButton<String>(
          value: selectedValueBreeder,
          items: uniqueBreederValues.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedValueBreeder = newValue;
              String? key = getKeyForValue(newValue);
              updateMonthsDropdown(key);
            });
          },
          isExpanded: true,
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  // Widget _typeDropdownMonth() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Months',
  //         style: TextStyle(
  //           fontSize: 20.0,
  //         ),
  //       ),
  //       const SizedBox(height: 8.0),
  //       DropdownButton<String>(
  //         value: selectedValueMonth,
  //         items: uniqueMonths.map((String value) {
  //           return DropdownMenuItem<String>(
  //             value: value,
  //             child: Text(value),
  //           );
  //         }).toList(),
  //         onChanged: (String? newValue) {
  //           setState(() {
  //             selectedValueMonth = newValue;
  //           });
  //         },
  //         isExpanded: true,
  //       ),
  //       const SizedBox(height: 8.0),
  //     ],
  //   );
  // }

  Widget _typeDropdownMonth() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Months',
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        const SizedBox(height: 8.0),
        DropdownButton<String>(
          value: selectedValueMonth,
          items: uniqueMonths.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) async {
            setState(() {
              selectedValueMonth = newValue;
            });

            // Fetch and update control numbers based on the selected breeder and month
            updateControllDropdown(getKeyForValue(selectedValueBreeder));
          },
          isExpanded: true,
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _typeDropdownControllNo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Controll Number',
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          selectedControlNo ?? 'Select a month to see control number',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
