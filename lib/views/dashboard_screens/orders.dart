// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hogme/views/dashboard_screens/home1.dart';

class OrderFeedsPage extends StatefulWidget {
  const OrderFeedsPage({super.key, required this.order});

  final Map order;
  @override
  _OrderFeedsPageState createState() => _OrderFeedsPageState();
}

class _OrderFeedsPageState extends State<OrderFeedsPage> {
  String? selectedWeight;
  late TextEditingController desCtrl;
  late TextEditingController payCtrl;
  bool _acceptedTerms = false;
  bool _isChecked = false;

  late Map order = widget.order;
  double quantity = 1;
  double totalPrice = 0.0;

  @override
  void initState() {
    desCtrl = TextEditingController();
    // payCtrl = TextEditingController();
    updateTotalPrice();
    super.initState();
  }

  @override
  void dispose() {
    desCtrl.dispose();
    // payCtrl.dispose();
    super.dispose();
  }

  void updateTotalPrice() {
    setState(() {
      totalPrice = quantity * order['price'];
    });
  }

  void createOrder() async {
    String paymentmethod = "cash";
    final user = FirebaseAuth.instance.currentUser?.uid;
    late var userid = user!;
    String key = order['productID'];
    print('key');
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('inventory/$key/orders/');
    DatabaseReference inRef = FirebaseDatabase.instance.ref('inventory/$key');
    var newOrder = ref.push();
    // DateTime currentTime = DateTime.now();

    // if (payCtrl.text.isEmpty) {
    //   _showErrorDialog('Please provide a valid address');
    //   return;
    // }

    if (quantity > order['quantity']) {
      _showErrorDialog('${order['quantity']} Quantity Available');
      return;
    }

    await newOrder.set({
      "kilo": selectedWeight,
      "quantity": quantity.toStringAsFixed(0),
      "totalprice": totalPrice.toStringAsFixed(2),
      "productID": newOrder.key,
      "productName": order['productName'],
      "userID": userid,
      "description": desCtrl.text,
      "status": 'pending',
      // "address": payCtrl.text,
      "paymentmethod": paymentmethod,
      "date": DateTime.now().toUtc().toString(),
    });

    await inRef.update({
      "quantity": ServerValue.increment(-quantity),
    });
    _showSuccessDialog('Order Success');
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

  void handleSubmit() {
    if (_isChecked) {
      createOrder();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Registration failed. Please try again."),
      //   ),
      // );
    } else {
      showOrderPolicy(context);
    }
  }

  Future showOrderPolicy(BuildContext context) async {
    if (!_acceptedTerms) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Order Policy"),
            content: const SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Please visit our office to collect your order and kindly bring the payment in cash',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '(Purok Mangga 2, Soong, Purisima, Tago, Surigao del Sur)',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _acceptedTerms = true;
                    _isChecked = true;
                  });
                },
                child: const Text(
                  "Accept",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _acceptedTerms = false;
                    _isChecked = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("You must accept the order policy."),
                      ),
                    );
                  });
                },
                child: const Text(
                  "Decline",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You have already accepted the order policy."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    updateTotalPrice();
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
              'Order Feeds',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 21, 114, 49),
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(13.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 248, 248, 248),
                borderRadius: BorderRadius.circular(16.0),
                image: DecorationImage(
                  image: NetworkImage(order['productImage'] ?? ' '),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // const Text(
            //   'Kilo',
            //   style: TextStyle(
            //     fontSize: 20.0,
            //   ),
            // ),
            // DropdownButton<String>(
            //   value: selectedWeight,
            //   items: <String>[
            //     '20 kg',
            //     '50 kg',
            //   ].map((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       selectedWeight = newValue!;
            //     });
            //   },
            //   isExpanded: true,
            // ),
            const Text(
              'Quantity ',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                      updateTotalPrice();
                    }
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.circleMinus,
                    color: Colors.green,
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                        style: BorderStyle.solid),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      quantity.toStringAsFixed(0),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                    updateTotalPrice();
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.circlePlus,
                    color: Colors.green,
                  ),
                )
              ],
            ),
            const Text(
              'Price',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            Container(
              height: 40,
              width: 80,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black, width: 2.0, style: BorderStyle.solid),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  totalPrice.toStringAsFixed(2),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            // const Text(
            //   'Address',
            //   style: TextStyle(
            //     fontSize: 20.0,
            //   ),
            // ),
            // TextField(
            //   controller: payCtrl,
            //   keyboardType: TextInputType.multiline,
            //   decoration: const InputDecoration(
            //     hintText: 'Input your address here',
            //     // border: InputBorder.none,
            //   ),
            // ),
            const SizedBox(height: 10.0),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            Container(
              height: 110.0,
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                order['feedsDescription'],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
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
                child: const Center(
                  child: Row(
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
            ),
            const SizedBox(height: 16.0),
            _note(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isChecked ? () => handleSubmit() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                child: const Text(
                  'Order',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _note() => Row(
        children: [
          Checkbox(
            value: _isChecked,
            activeColor: Colors.green,
            onChanged: (value) {
              setState(() {
                _isChecked = value ?? false;
                if (_isChecked) {
                  showOrderPolicy(context);
                }
              });
            },
          ),
          const Expanded(
            child: Row(
              children: [
                Text(
                  'Order Policy',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                // Text(
                //   'Terms',
                //   style: TextStyle(
                //     color: Colors.green,
                //     fontSize: 9.5,
                //   ),
                // ),
                // SizedBox(
                //   width: 3,
                // ),
                // Text(
                //   'and',
                //   style: TextStyle(
                //     color: Colors.black38,
                //     fontSize: 9.5,
                //   ),
                // ),
                // SizedBox(
                //   width: 3,
                // ),
                // Text(
                //   'Condations.',
                //   style: TextStyle(
                //     color: Colors.green,
                //     fontSize: 9.5,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      );

  Widget buildWeightButton(String weight) {
    return SizedBox(
      width: 80.0,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedWeight = weight;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedWeight == weight ? Colors.green : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        child: Text(
          weight,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
