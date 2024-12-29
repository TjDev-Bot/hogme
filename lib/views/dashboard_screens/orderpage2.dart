// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hogme/utils/text_widgets.dart';
import 'package:hogme/views/dashboard_screens/home1.dart';
import 'package:hogme/views/dashboard_screens/orders.dart';

class OrderPage2 extends StatefulWidget {
  const OrderPage2({Key? key});

  @override
  _OrderPage2State createState() => _OrderPage2State();
}

class _OrderPage2State extends State<OrderPage2> {
  Query dbIn = FirebaseDatabase.instance.ref().child('inventory')
    ..keepSynced(true);
  List<Map> inventoryList = [];

  Future<void> _processInventoryData(DataSnapshot dataValues) async {
    Set<String> uniqueKeys = Set<String>();
    List<Map> newInventoryList = [];

    if (dataValues.value != null && dataValues.value is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic> values = dataValues.value as Map<dynamic, dynamic>;

      values.forEach((key, value) {
        if (value != null &&
            value['quantity'] != 0 &&
            uniqueKeys.add(key.toString())) {
          newInventoryList.add(value);
        }
      });
    }

    setState(() {
      inventoryList = newInventoryList;
    });
  }

  @override
  void initState() {
    super.initState();
    dbIn.onValue.listen((event) {
      _processInventoryData(event.snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map> currentInventoryList = List.from(inventoryList);

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
                      text: 'Order Feeds',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: (currentInventoryList.length + 1) ~/
                      2, // Add 1 to handle odd number of items
                  itemBuilder: (BuildContext context, int index) {
                    int leftIndex = index * 2;
                    int rightIndex = leftIndex + 1;

                    return Row(
                      children: [
                        if (leftIndex < currentInventoryList.length)
                          Expanded(
                            child:
                                _inventoryCard(currentInventoryList[leftIndex]),
                          ),
                        if (rightIndex < currentInventoryList.length)
                          const SizedBox(
                              width:
                                  16.0), // Adjust the spacing between columns
                        if (rightIndex < currentInventoryList.length)
                          Expanded(
                            child: _inventoryCard(
                                currentInventoryList[rightIndex]),
                          ),
                        if (index ==
                                (currentInventoryList.length + 1) ~/ 2 - 1 &&
                            currentInventoryList.length % 2 != 0)
                          const SizedBox(
                              width:
                                  16.0), 
                        if (index ==
                                (currentInventoryList.length + 1) ~/ 2 - 1 &&
                            currentInventoryList.length % 2 != 0)
                          Expanded(
                            child:
                                Container(), 
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inventoryCard(Map inven) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200.0,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16.0),
              image: DecorationImage(
                image: NetworkImage(
                  inven['productImage'] ?? ' ',
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  inven['productName'],
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Price: ${inven['price'].toString()}',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'Quantity: ${inven['quantity'].toString()}',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'Kg: ${inven['kg'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'Description: \n${inven['feedsDescription']}',
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderFeedsPage(
                      order: inven,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF6FA16B),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
