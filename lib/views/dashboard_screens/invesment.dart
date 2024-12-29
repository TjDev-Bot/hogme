// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:hogme/utils/text_widgets.dart';
import 'package:hogme/views/dashboard_screens/toinvest.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class InvestmentPage extends StatefulWidget {
  const InvestmentPage({super.key});

  @override
  _InvestmentPageState createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  final user = FirebaseAuth.instance.currentUser?.uid;
  late var userid = user!;
  Future<List<Map<String, dynamic>>> fetchInvestments() async {
    List<Map<String, dynamic>> data = [];
    try {
      DatabaseReference dbRef =
          FirebaseDatabase.instance.ref().child('investment');

      DataSnapshot investmentSnapshot = (await dbRef.once()).snapshot;

      Map<dynamic, dynamic>? investmentMap =
          investmentSnapshot.value as Map<dynamic, dynamic>?;
      if (investmentMap != null) {
        investmentMap.forEach((key, value) {
          if (value['userID'] == userid) {
            data.add({
              'date': value['date'],
              'amount': double.parse(value['amount']),
              'userID': value['userID'],
            });
          }
        });
      }
    } catch (error) {
      // Handle errors
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    Query userRef = FirebaseDatabase.instance.ref().child('users');
    Query inRef = FirebaseDatabase.instance.ref().child('totalprofit');

    final user = FirebaseAuth.instance.currentUser?.uid;
    late var userid = user!;
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Investment',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text(
                              "How to get my profit ?",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            content: const SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '1. Investment',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '2. Total Investment',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '3. Sales',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '4. Expenses',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '5. Net Sales',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '6. Share Profit',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                    child: Text(
                                      'Formula and Solution',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Investment/Total Investment = Net Share Profit ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Sales – Expenses = Net Sales',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Net Sales x Net Share Profit = Net Share Profit per Investment',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Okay",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.info_outlined,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 170.5,
                    height: MediaQuery.of(context).size.height / 10.5,
                    child: FirebaseAnimatedList(
                      physics: NeverScrollableScrollPhysics(),
                      query: userRef,
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        Map userProf = snapshot.value as Map;
                        userProf['key'] = snapshot.key;
                        if (userProf['id'] == userid) {
                          return _invesment(userProf);
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 170.5,
                    height: MediaQuery.of(context).size.height / 10.5,
                    child: FirebaseAnimatedList(
                      physics: NeverScrollableScrollPhysics(),
                      query: inRef,
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        Map investment = snapshot.value as Map;
                        investment['key'] = snapshot.key;
                        if (investment['userID'] == userid &&
                            investment['status'] == 'approved') {
                          return _invesmentprof(investment);
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: text24Normal(text: 'Monthly Investment'),
              ),
              FutureBuilder(
                  future: fetchInvestments(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No Investment Data Available');
                    } else {
                      return investmentLineChart(snapshot.data!);
                    }
                  }),
              const SizedBox(height: 150.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: 170.5,
        height: MediaQuery.of(context).size.height / 10.5,
        child: FirebaseAnimatedList(
          physics: NeverScrollableScrollPhysics(),
          query: userRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map userProf = snapshot.value as Map;
            userProf['key'] = snapshot.key;
            if (userProf['id'] == userid) {
              return _proceed(userProf);
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Widget _proceed(Map prof) {
    DateTime currentDate = DateTime.now();
    DateTime dateCreated = DateTime.parse(prof['dateCreated']);
    int differenceInDays = currentDate.difference(dateCreated).inDays;
    bool canInvest = differenceInDays >= 30;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: ElevatedButton(
        onPressed: canInvest
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ToInvestPage(),
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: canInvest ? Colors.green : Colors.grey,
        ),
        child: Text(
          canInvest ? 'Proceed' : 'Wait 1 month to invest',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _invesmentprof(Map prof) {
    String profit;

    if (prof['amount'] == 0) {
      profit = 'Pending';
    } else {
      profit = '₱ ${prof['amount']}';
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Profit',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            profit,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF23B371),
            ),
          ),
        ],
      ),
    );
  }

  Widget _invesment(Map invest) {
    String investment;
    if (invest['balance'] == 0) {
      investment = 'Pending';
    } else {
      investment = '₱ ${invest['balance']}';
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Investment',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            investment,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget investmentLineChart(List<Map<String, dynamic>> investments) {
    List<SplineSeries<Map<String, dynamic>, String>> getLineSeries() {
      return [
        SplineSeries<Map<String, dynamic>, String>(
          color: Colors.green,
          dataSource: investments,
          xValueMapper: (Map<String, dynamic> investment, _) =>
              DateFormat('MMM').format(DateTime.parse(investment['date'])),
          yValueMapper: (Map<String, dynamic> investment, _) =>
              investment['amount'],
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ];
    }

    return Container(
      height: 200.0,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
        series: getLineSeries(),
      ),
    );
  }

  double calculateMaxY(List<Map<String, dynamic>> investments) {
    double maxAmount = 0;

    for (var investment in investments) {
      double amount = investment['amount'];
      if (amount > maxAmount) {
        maxAmount = amount;
      }
    }

    return maxAmount + 10;
  }
}
