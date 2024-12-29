import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:hogme/utils/text_widgets.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final user = FirebaseAuth.instance.currentUser?.uid;
  late var userid = user!;

  @override
  Widget build(BuildContext context) {
    Query dbAnn = FirebaseDatabase.instance.ref('return-livestock');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Scaffold(
          backgroundColor: Colors.grey[300],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text36Bold(text: 'History Return Livestocks'),
                const SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 3,
                      child: FirebaseAnimatedList(
                        query: dbAnn.orderByChild('date').limitToLast(1),
                        itemBuilder: (BuildContext context,
                            DataSnapshot snapshot,
                            Animation<double> animation,
                            int index) {
                          Map history = snapshot.value as Map;
                          history['key'] = snapshot.key;
                          if (history.isNotEmpty &&
                              history['userID'] == userid) {
                            return _history(history);
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _history(Map ann) {
    String dateString = ann['bdate'];
    DateTime date = DateTime.parse(dateString);
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 190.0,
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
                      child: SizedBox(
                          width: 300,
                          child: text14Normal(text: 'Type: ${ann['type']}')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                          width: 300,
                          child:
                              text14Normal(text: 'Gender: ${ann['gender']}')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                          width: 300,
                          child: text14Normal(text: 'Kilogram: ${ann['kg']}')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: text14Normal(
                          text:
                              'Birth Date: ${DateFormat('MMMM d, y').format(date)}'),
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
}
