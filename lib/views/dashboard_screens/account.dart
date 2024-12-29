// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hogme/utils/text_widgets.dart';
import 'package:hogme/views/authentication_screens/login_screen.dart';
import 'package:hogme/views/dashboard_screens/invesment.dart';
import 'package:hogme/views/dashboard_screens/orderhistory.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  File? selectedProfile;

  Future<void> pickProfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedProfile = File(result.files.first.path!);
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userID = user.uid;
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('users');
      var newUserRef = ref.child(userID);

      final storage = FirebaseStorage.instance;
      var fileName =
          'profile/${selectedProfile != null ? selectedProfile!.path.split('/').last : 'default-facility-file.jpg'}';

      var uploadTask = storage.ref(fileName).putFile(selectedProfile!);
      await Future.wait([uploadTask]);
      String fileUrl = await storage.ref(fileName).getDownloadURL();

      await newUserRef.update({
        "profilepicture": fileUrl,
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Query userRef = FirebaseDatabase.instance.ref().child('users');
    final user = FirebaseAuth.instance.currentUser?.uid;
    late var userid = user!;
    return SafeArea(
        child: Container(
      color: Colors.grey[300],
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height / 2,
            child: FirebaseAnimatedList(
              query: userRef,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                Map userProf = snapshot.value as Map;
                userProf['key'] = snapshot.key;
                if (userProf['id'] == userid) {
                  return _userProfile(userProf);
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    ));
  }

  ImageProvider<Object> getImageWidget(Map<dynamic, dynamic> user) {
    String imageUrl = user['profilepicture'];

    if (imageUrl.isNotEmpty) {
      return NetworkImage(imageUrl);
    } else {
      return const AssetImage('assets/images/no-profile.png');
    }
  }

  Widget imgExist() => selectedProfile != null
      ? Image.file(
          selectedProfile!,
          fit: BoxFit.cover,
        )
      : const SizedBox();

  Widget imgNotExist() => const Center(
        child: SizedBox(),
      );

  Widget _userProfile(userprof) {
    String fullname = userprof['firstname'] + ' ' + userprof['lastname'];
    bool hasImage = userprof['profilepicture'].isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(100),
              ),
              image: DecorationImage(
                image: hasImage
                    ? getImageWidget(userprof)
                    : const AssetImage('assets/images/no-profile.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(100)),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        _showModal(context);
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )),
          ),
        ),
        // Stack(
        //   children: [
        //     Positioned(
        //         top: 0,
        //         child: IconButton(
        //           onPressed: () {},
        //           icon: Icon(
        //             Icons.edit,
        //             color: Colors.blue,
        //           ),
        //         )),
        //   ],
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     if (!hasImage)

        //     if (!hasImage)
        //       IconButton(
        //         onPressed: () {
        //           updateProfile();
        //         },
        //         icon: const Icon(
        //           Icons.check_circle_sharp,
        //           size: 20,
        //           color: Colors.green,
        //         ),
        //       ),
        //   ],
        // ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          // ignore: unnecessary_string_interpolations
          child: text24Bold(text: fullname),
        ),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: text20Normal(text: userprof['contactnumber'])),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.energy_savings_leaf_sharp),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: text20Normal(text: userprof['role'])),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvestmentPage(),
                ),
              );
            },
            child: Container(
              width: 130,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2.0,
                  color: Colors.black,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: const Center(child: Text('Investment')),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderHistory(),
                ),
              );
            },
            child: Container(
              width: 130,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2.0,
                  color: Colors.black,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: const Center(child: Text('Your Orders')),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 35),
          child: TextButton(
            onPressed: () {
              signOut();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showModal(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Profile Picture'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => pickProfile(),
                  child: Container(
                    width: 130,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.0,
                        color: Colors.black,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: const Center(child: Text('Select Profile')),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => updateProfile(),
                  child: Container(
                    width: 130,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2.0,
                        color: Colors.black,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: const Center(child: Text('Submit')),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
