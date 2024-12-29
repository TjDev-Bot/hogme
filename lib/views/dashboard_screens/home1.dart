// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hogme/views/dashboard_screens/account.dart';
import 'package:hogme/views/dashboard_screens/home.dart';
import 'package:hogme/views/dashboard_screens/livestock.dart';
import 'package:hogme/views/dashboard_screens/notification.dart';
import 'package:hogme/views/dashboard_screens/orderpage2.dart';
import 'package:hogme/views/dashboard_screens/request.dart';
import 'package:hogme/views/dashboard_screens/schedule.dart';
import 'package:hogme/views/dashboard_screens/tutorial.dart';
import 'package:connectivity/connectivity.dart';

class Home1 extends StatefulWidget {
  const Home1({Key? key});

  @override
  State<Home1> createState() => _Home1State();
}

class _Home1State extends State<Home1> {
  bool hasUnreadNotification = true;
  bool isOffline = false;

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Account(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      bottomNavigationBar: DefaultTabController(
        length: 4,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 35),
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    floating: true,
                    pinned: true,
                    snap: false,
                    backgroundColor: Colors.white,
                    title: Row(
                      children: [
                        Image.asset(
                          'assets/icons/icon_hogme.png',
                          height: 30,
                          width: 30,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Hogme',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 90),
                          child: Expanded(
                            child: SizedBox(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const OrderPage2()));
                                    },
                                    icon: const Icon(Icons.shopping_cart),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Request(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.request_quote,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Notifications(),
                                        ),
                                      );
                                      setState(() {
                                        hasUnreadNotification = false;
                                      });
                                    },
                                    icon: Stack(
                                      children: [
                                        const Icon(Icons.notifications),
                                        if (hasUnreadNotification)
                                          Positioned(
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _showProfile();
                                    },
                                    icon: const Icon(Icons.account_circle),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ];
              },
              body: const TabBarView(
                children: [
                  Home(),
                  TutorialsPage(),
                  SchedulePage(),
                  LivestockPage(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(50.0),
              ),
              child: Container(
                color: const Color.fromARGB(255, 17, 54, 25),
                child: const TabBar(
                  labelColor: Color.fromARGB(255, 54, 185, 87),
                  unselectedLabelColor: Colors.white,
                  labelStyle: TextStyle(fontSize: 10.0),
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(
                        Icons.home,
                        size: 24.0,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.play_circle,
                        size: 24.0,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.calendar_month,
                        size: 24.0,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.pets,
                        size: 24.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
