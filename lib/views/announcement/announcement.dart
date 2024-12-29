import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:hogme/utils/text_widgets.dart';
import 'package:intl/intl.dart';

class Announcement extends StatefulWidget {
  const Announcement({super.key});

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  @override
  Widget build(BuildContext context) {
    Query dbAnn = FirebaseDatabase.instance.ref('announcements');

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: text24Bold(text: 'Announcement'),
                ),
                Container(
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
              ],
            ),
            Container(
              height: 600,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: FirebaseAnimatedList(
                  query: dbAnn,
                  reverse: true,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    Map announcements = snapshot.value as Map;

                    announcements['key'] = snapshot.key;

                    if (announcements.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: allAnn(announcements),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget allAnn(ann) {
    String dateString = ann['date'];
    DateTime date = DateTime.parse(dateString);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text24Bold(text: ann['title']),
            text16Normal(text: ann['content']),
            text14Normal(text: DateFormat('MMMM d, y').format(date)),
          ],
        ),
      ),
    );
  }
}
