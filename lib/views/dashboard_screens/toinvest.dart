// ignore_for_file: library_private_types_in_public_api, unnecessary_string_interpolations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:hogme/views/dashboard_screens/home1.dart';

class ToInvestPage extends StatefulWidget {
  const ToInvestPage({super.key});

  @override
  _ToInvestPageState createState() => _ToInvestPageState();
}

class _ToInvestPageState extends State<ToInvestPage> {
  String selectedModeOfDeposit = 'Cash';
  late TextEditingController payCtrl;

  @override
  void initState() {
    payCtrl = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    payCtrl.dispose();
    super.dispose();
  }

  int investment = 0;
  void invest() async {
    final user = FirebaseAuth.instance.currentUser?.uid;
    late var userid = user!;
    DatabaseReference ref = FirebaseDatabase.instance.ref('investment');
    var newOrder = ref.push();

    if (payCtrl.text.isEmpty) {
      _showErrorDialog('Please input an amount!');
      return;
    }

    int enteredAmount = int.tryParse(payCtrl.text) ?? 0;

    if (enteredAmount > 2000) {
      _showErrorDialog('Investment amount cannot exceed ₱2,000.');
      return;
    }

    await newOrder.set({
      "modeofdeposit": selectedModeOfDeposit,
      "amount": payCtrl.text,
      "userID": userid,
      "date": DateTime.now().toUtc().toString(),
      "historyamount": payCtrl.text,
      "status": "pending",
    });
    _showSuccessDialog('Your Investment is being processed...');
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
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
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Query userRef = FirebaseDatabase.instance.ref().child('users');
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
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Investment',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height / 6,
              child: FirebaseAnimatedList(
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
            const SizedBox(height: 16.0),
            const Text(
              'Amount',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: payCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter amount',
              ),
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 8.0),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Mode of Deposit',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 200, 0),
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Cash Only',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 15,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton.icon(
          onPressed: () {
            invest();
          },
          icon: const Icon(
            Icons.attach_money,
            color: Colors.white,
          ),
          label: const Text(
            'Invest Now',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            backgroundColor: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _invesment(Map invest) {
    String investment;
    if (invest['balance'] == "") {
      investment = 'Pending';
    } else {
      investment = '₱${invest['balance']}';
    }
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green[800],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Investment',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '$investment',
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
