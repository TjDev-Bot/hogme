import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hogme/utils/text_widgets.dart';
import 'package:hogme/views/announcement/announcement.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final AnnouncementController _announcementController =
  //     Get.put(AnnouncementController());
  // final box = GetStorage();  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _messagesRef =
      FirebaseDatabase.instance.ref().child('messages')..keepSynced(true);
  DatabaseReference dbUser = FirebaseDatabase.instance.ref().child('users')
    ..keepSynced(true);
  Query dbExp = FirebaseDatabase.instance.ref().child('expenses')
    ..keepSynced(true);
  Query dbInt = FirebaseDatabase.instance.ref().child('investment')
    ..keepSynced(true);

  final TextEditingController _messageController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser?.uid;
  late var userid = user!;
  Future<List<Map<String, dynamic>>> fetchData() async {
    DataSnapshot messageSnapshot = (await _messagesRef.once()).snapshot;
    DataSnapshot userSnapshot = (await dbUser.once()).snapshot;

    Map<dynamic, dynamic>? messagesMap =
        messageSnapshot.value as Map<dynamic, dynamic>?;
    Map<dynamic, dynamic>? usersMap =
        userSnapshot.value as Map<dynamic, dynamic>?;

    if (messagesMap == null || usersMap == null) {
      return [];
    }

    List<Map<String, dynamic>> combinedData = [];

    messagesMap.forEach((messageKey, messageItem) {
      var matchingUserID = usersMap[messageItem['senderID']];
      if (matchingUserID != null) {
        if ((messageItem['senderID'] == userid &&
                messageItem['recepientID'] == 'w6TrzBF4umeR4oISsa5Q8hHmh2b2') ||
            (messageItem['senderID'] == 'w6TrzBF4umeR4oISsa5Q8hHmh2b2' &&
                messageItem['recepientID'] == userid)) {
          Map<String, dynamic> combinedItem = {
            'messages': Map<String, dynamic>.from(messageItem),
            'users': Map<String, dynamic>.from(matchingUserID),
          };
          combinedData.add(combinedItem);
        }
      }
    });

    return combinedData;
  }

  Future<List<Map<String, dynamic>>> fetchExp() async {
    List<Map<String, dynamic>> data = [];
    try {
      DatabaseReference dbRef =
          FirebaseDatabase.instance.ref().child('expenses');

      DataSnapshot expSnapshot = (await dbRef.once()).snapshot;

      Map<dynamic, dynamic>? expMap =
          expSnapshot.value as Map<dynamic, dynamic>?;
      if (expMap != null) {
        expMap.forEach((key, value) {
          data.add({
            'date': value['date'],
            'materials': value['materials'],
            'weight': value['weight'],
            'actualprice': value['actualprice'],
            'price': value['price'],
          });
        });
      }
    } catch (error) {
      if (mounted) {}
    }
    return data;
  }

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
    Query dbAnn = FirebaseDatabase.instance.ref('announcements');
    // Query dbLive = FirebaseDatabase.instance.ref('livestocks');

    void showChatBox() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            List<Map<String, dynamic>>? combinedData =
                                snapshot.data;

                            return combinedData != null &&
                                    combinedData.isNotEmpty
                                ? FirebaseAnimatedList(
                                    scrollDirection: Axis.vertical,
                                    query: _messagesRef,
                                    itemBuilder: (
                                      BuildContext context,
                                      DataSnapshot snapshot,
                                      Animation<double> animation,
                                      int index,
                                    ) {
                                      Map? messageData = snapshot.value as Map?;
                                      messageData ??= {};
                                      messageData['key'] = snapshot.key;

                                      if (messageData.isNotEmpty) {
                                        // Check if the message is for the current user or admin

                                        Map? correspondingMessage = combinedData
                                            .firstWhereOrNull((item) =>
                                                item['messages']['senderID'] ==
                                                messageData?['senderID']);

                                        return correspondingMessage != null
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: message(messageData,
                                                    correspondingMessage),
                                              )
                                            : Container();
                                      }

                                      return const SizedBox();
                                    },
                                  )
                                : Container();
                          }
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none),
                            fillColor: const Color(0xFF235B9E).withOpacity(0.1),
                            filled: true,
                            prefixIcon: const Icon(Icons.email),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          _messagesRef.push().set({
                            'content': _messageController.text,
                            'senderID': userid,
                            //Admin ID
                            'recepientID': 'w6TrzBF4umeR4oISsa5Q8hHmh2b2',
                            'dateSent': DateTime.now().toUtc().toString(),
                          });

                          _messageController.clear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Scaffold(
          backgroundColor: Colors.grey[300],
          floatingActionButton: FloatingActionButton(
            onPressed: () => showChatBox(),
            backgroundColor: const Color.fromARGB(255, 17, 54, 25),
            child: const Icon(
              Icons.message,
              color: Colors.white,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text36Bold(text: 'Dashboard'),
                const SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 250,
                      child: FirebaseAnimatedList(
                        query: dbAnn.orderByChild('date').limitToLast(1),
                        itemBuilder: (BuildContext context,
                            DataSnapshot snapshot,
                            Animation<double> animation,
                            int index) {
                          Map announcements = snapshot.value as Map;
                          announcements['key'] = snapshot.key;
                          if (announcements.isNotEmpty) {
                            return _buildAnnouncement(announcements);
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: text24Normal(text: 'Expenses'),
                ),
                const SizedBox(height: 32.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: FutureBuilder(
                      future: fetchExp(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Map>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error Snapshot : ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('No Data Available');
                        } else {
                          return ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
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
                                    'Date',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Materials',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Weight(kg)',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Actual Price',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Price(/kg)',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                              rows: snapshot.data!.map((expenses) {
                                return _expenses(expenses);
                              }).toList(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _expenses(expen) {
    return DataRow(
      cells: [
        DataCell(
          Text(expen['date'] ?? ''),
        ),
        DataCell(
          Text(expen['materials'] ?? ''),
        ),
        DataCell(
          Text(expen['weight'] ?? ''),
        ),
        DataCell(
          Text(expen['actualprice'].toString()),
        ),
        DataCell(
          Text(expen['price'].toString()),
        ),
      ],
    );
  }

  Widget _buildAnnouncement(Map ann) {
    String dateString = ann['date'];
    DateTime date = DateTime.parse(dateString);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: text24Normal(text: 'Announcement'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Announcement(),
                  ),
                );
              },
              child: Container(
                width: 24.0,
                height: 24.0,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
                child: const Icon(
                  Icons.arrow_outward_sharp,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        Container(
          width: double.infinity,
          height: 150.0,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            children: [
              // Green Left Border
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: text16Bold(text: ann['title']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                          width: 300,
                          child: text14Normal(text: ann['content'])),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: text14Normal(
                            text: DateFormat('MMMM d, y').format(date)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget message(message, user) {
    return Column(
      crossAxisAlignment: message['senderID'] == userid
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message['content'],
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Text(
          (user['users'] ?? {})['firstname'],
        ),
      ],
    );
  }

  Widget investmentLineChart(List<Map<String, dynamic>> investments) {
    List<SplineSeries<Map<String, dynamic>, String>> getLineSeries() {
      return [
        SplineSeries<Map<String, dynamic>, String>(
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
