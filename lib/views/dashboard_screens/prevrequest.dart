// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hogme/utils/text_widgets.dart';
import 'package:hogme/views/dashboard_screens/home1.dart';

class PrevHistory extends StatefulWidget {
  const PrevHistory({Key? key});

  @override
  _PrevHistoryState createState() => _PrevHistoryState();
}

class _PrevHistoryState extends State<PrevHistory> {
  Query dbOrders = FirebaseDatabase.instance.ref().child('livestocks');
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Home1(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_sharp),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: text36Bold(
                        text: 'Previous Request',
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(
                // Wrap the Expanded around the FirebaseAnimatedList
                child: FirebaseAnimatedList(
                  query: dbOrders,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    Map inventory = (snapshot.value as Map);
                    var requestValue = inventory['request'];

                    if (requestValue is Map) {
                      Map ordersMap = requestValue;
                      List ordersList = ordersMap.entries
                          .map((entry) => entry.value)
                          .toList();

                      List userOrdersList = ordersList
                          .where((order) =>
                              order is Map && order['userID'] == user.uid)
                          .toList();

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: userOrdersList
                              .map((orders) => _inventoryCard(orders))
                              .toList(),
                        ),
                      );
                    } else {
                      // Handle the case where 'request' is not a Map, e.g., an empty string
                      return const SizedBox();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _inventoryCard(Map orders) {
    print('Test $orders');

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Request ID :  ${orders['lisID'].toString()}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Status : ${orders['status']}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Description :  ${orders['description'].toString()}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrevHistory()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: const Text(
                      'Cancel Request',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
