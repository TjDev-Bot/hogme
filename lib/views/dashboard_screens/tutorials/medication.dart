// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_literals_to_create_immutables

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:hogme/utils/text_widgets.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Medication extends StatefulWidget {
  Medication({super.key});

  @override
  State<Medication> createState() => _MedicationState();
}

class _MedicationState extends State<Medication> {
  late GlobalKey<FirebaseAnimatedListState> _listKey;
  Query dbTut = FirebaseDatabase.instance.ref().child('tutorials');

  @override
  void initState() {
    super.initState();
    _listKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
          title: const Center(
            child: Text(
              'Medication',
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16.0),

              // const SizedBox(height: 5),
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.5,
                key: _listKey,
                child: FirebaseAnimatedList(
                  query: dbTut,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    Map tutorial = snapshot.value as Map;
                    tutorial['key'] = snapshot.key;
                    if (tutorial.isNotEmpty &&
                        tutorial['category'] == 'medication') {
                      return _tutorials(tutorial);
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateSearch(String query) {
    Query filteredQuery = FirebaseDatabase.instance
        .ref()
        .child('tutorials')
        .orderByChild('title')
        .startAt(query.toLowerCase())
        .endAt('${query.toLowerCase()}\uf8ff');

    setState(() {
      dbTut = filteredQuery;
      _listKey = GlobalKey();
    });
  }

  Widget _tutorials(Map tutorial) {
    String sourceUrl = tutorial['sourceUrl'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          const SizedBox(width: 8.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.maxFinite,
              height: 200.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(5),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: YoutubePlayer(
                    controller: YoutubePlayerController(
                        initialVideoId:
                            YoutubePlayer.convertUrlToId(sourceUrl)!,
                        flags: const YoutubePlayerFlags(
                          autoPlay: false,
                          mute: false,
                        )),
                    // showVideoProgressIndicator: true,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              text24Bold(
                text: tutorial['title'.toLowerCase()],
              ),
              Text(
                tutorial['description'.toLowerCase()],
                style: const TextStyle(
                  fontSize: 15.0,
                ),
                textAlign: TextAlign.justify,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ],
      ),
    );
  }
}
