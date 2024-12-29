import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UpdateLive extends StatefulWidget {
  const UpdateLive(
      {super.key, required this.upLive, required this.releasingId});

  final Map upLive;
  final Map releasingId;

  @override
  State<UpdateLive> createState() => _UpdateLiveState();
}

class _UpdateLiveState extends State<UpdateLive> {
  late TextEditingController reasonCtrl;
  late final live = widget.upLive;
  late final idrelease = widget.releasingId;
  bool isLoading = false;

  String? selectedStatus;
  File? selectedImg;

  @override
  void initState() {
    super.initState();
    reasonCtrl = TextEditingController();
  }

  @override
  void dispose() {
    reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImg() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedImg = File(result.files.first.path!);
      });
    }
  }

  Future<void> updateLive() async {
    try {
      setState(() {
        isLoading = true;
      });
      final user = FirebaseAuth.instance.currentUser!;
      final userID = user.uid;

      DatabaseReference ref = FirebaseDatabase.instance.ref().child(
          'livestocks/${live['liveID']}/updateStatus');

      DatabaseReference newRef = ref.push();

      final storage = FirebaseStorage.instance;
      var fileName =
          'HogImg/${selectedImg != null ? selectedImg!.path.split('/').last : 'default-file.jpg'}';
      var uploadTask = storage.ref(fileName).putFile(selectedImg!);
      await Future.wait([uploadTask]);
      String fileUrl = await storage.ref(fileName).getDownloadURL();

      await newRef.set({
        'userid': userID,
        'proofImg': fileUrl,
        'status': selectedStatus,
        'reasons': reasonCtrl.text,
        'controlnumber': live['controlnumber'],
        'liveID': live['liveID'],
      });
      _showSuccessDialog('Status Update Successfully');
    } catch (e) {
      print('Error updating live: $e');
      _showErrorDialog('Status Update Unsuccessful');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const Home1(),
                //   ),
                // );
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
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    // hint: Text('Select status'),
                    items: <String>['alive', 'deceased'].map((String value1) {
                      return DropdownMenuItem<String>(
                        value: value1,
                        child: Text(value1),
                      );
                    }).toList(),
                    onChanged: (String? newValue1) {
                      selectedStatus = newValue1!;
                    },
                    isExpanded: true,
                  ),
                ),
                // Text(livestocksid),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: GestureDetector(
                    onTap: () => pickImg(),
                    child: TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: selectedImg != null
                            ? selectedImg!.path.split('/').last.split('.').first
                            : 'Image',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey.withOpacity(0.1),
                        filled: true,
                        suffixIcon: const Icon(Icons.vrpano_outlined),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: TextField(
                    controller: reasonCtrl,
                    decoration: InputDecoration(
                      hintText: "Reason",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none),
                      fillColor: Colors.grey.withOpacity(0.1),
                      filled: true,
                      suffixIcon: const Icon(Icons.mode_comment_outlined),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 50, 30, 10),
                  child: GestureDetector(
                    onTap: () {
                      updateLive();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'UPDATE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
