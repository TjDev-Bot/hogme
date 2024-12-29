// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:hogme/utils/text_widgets.dart';
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  Query dbInt = FirebaseDatabase.instance.ref().child('investment')
    ..keepSynced(true);
  Query dbTory = FirebaseDatabase.instance.ref().child('inventory')
    ..keepSynced(true);
  Query dbLive = FirebaseDatabase.instance.ref().child('livestocks')
    ..keepSynced(true);

  final user = FirebaseAuth.instance.currentUser?.uid;
  late var userid = user!;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
          title: const Center(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 34, 70, 35),
              ),
            ),
          ),
          actions: [],
        ),
        backgroundColor: Colors.grey[300],
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                child: FirebaseAnimatedList(
                  scrollDirection: Axis.horizontal,
                  query: dbInt,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    Map notif = snapshot.value as Map;
                    notif['key'] = snapshot.key;
                    if (notif.isNotEmpty &&
                        notif['status'] == 'approved' &&
                        notif['userID'] == userid) {
                      return _notifInvest(notif);
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                child: FirebaseAnimatedList(
                  scrollDirection: Axis.horizontal,
                  query: dbTory,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    Map notifOrder = snapshot.value as Map;
                    notifOrder['key'] = snapshot.key;

                    Widget orderWidget = const SizedBox();

                    if (notifOrder['orders'] is Map) {
                      Map ordersMap = notifOrder['orders'];
                      ordersMap.forEach((orderKey, orderData) {
                        if (orderData != null &&
                            orderData['status'] == 'completed' &&
                            orderData['userID'] == userid) {
                          orderWidget = _notifOrder(orderData);
                        }
                      });
                    }

                    return orderWidget;
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                child: FirebaseAnimatedList(
                  scrollDirection: Axis.horizontal,
                  query: dbLive,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    Map notifLive = snapshot.value as Map;
                    notifLive['key'] = snapshot.key;

                    Widget requestWidget = const SizedBox();

                    if (notifLive.isNotEmpty && notifLive['request'] is Map) {
                      Map requestMap = notifLive['request'];
                      requestMap.forEach((requestKey, requestData) {
                        if (requestData != null &&
                            requestData['status'] == 'approved' &&
                            requestData['userID'] == userid) {
                          requestWidget = _notifRequest(requestData);
                        }
                      });
                    }

                    return requestWidget;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notifRequest(requestData) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM dd, yyyy').format(now);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 300,
        height: 150.0,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text24Bold(text: 'Request Approved'),
              text16Normal(
                  text:
                      'Your livestock request has been approved; Please proceed with the necessary steps to complete the process.'),
              text16Bold(
                text: formattedDate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notifInvest(ann) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM dd, yyyy').format(now);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 300.0, // Set a specific width here
        height: 150.0,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            // Wrap the content in a Column
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text24Bold(text: 'Investment'),
              text16Normal(
                  text:
                      'Your investment has already been approved; just wait for one month for it to reflect in your profit.'),
              text16Bold(
                text: formattedDate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notifOrder(orderData) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MMMM dd, yyyy').format(now);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 300,
        height: 150.0,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            // Wrap the content in a Column
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text24Bold(text: 'Order'),
              text16Normal(
                  text:
                      'Your order has already been approved; Please visit our office to collect your order and kindly bring the payment in cash. \n(Purok Mangga 2, Soong, Purisima, Tago, Surigao del Sur) '),
              text16Bold(
                text: formattedDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
