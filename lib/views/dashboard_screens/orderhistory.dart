// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hogme/utils/text_widgets.dart';
import 'package:hogme/views/dashboard_screens/home1.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({Key? key});

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  Query dbOrders = FirebaseDatabase.instance.ref().child('inventory');
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
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: text36Bold(
                      text: 'Order History',
                    ),
                  ),
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
                    if (inventory.containsKey('orders')) {
                      Map ordersMap = (inventory['orders'] as Map);
                      List ordersList = ordersMap.entries
                          .map((entry) => entry.value)
                          .toList();

                      List userOrdersList = ordersList
                          .where((order) => order['userID'] == user.uid)
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
                  orders['productName'].toString(),
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Total Price: ${orders['totalprice'].toString()}',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'Quantity: ${orders['quantity']}',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'Payment Method: ${orders['paymentmethod']}',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'Status: ${orders['status'].toString()}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
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
