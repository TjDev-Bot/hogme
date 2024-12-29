// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:hogme/utils/app_theme.dart';
import 'package:hogme/utils/custom_buttons.dart';
import 'package:hogme/views/dashboard_screens/home1.dart';
import 'package:intl/intl.dart';

class ReturnLive extends StatefulWidget {
  const ReturnLive({super.key});

  @override
  State<ReturnLive> createState() => _ReturnLiveState();
}

class _ReturnLiveState extends State<ReturnLive> {
  bool _loading = false;

  String error = '';

  late TextEditingController _dateController;
  DateTime? _selectedDate;

  late TextEditingController _typeController;
  late TextEditingController _genderController;
  late TextEditingController _kgController;
  File? selectedFacilityFile;
  File? selectedValidIDFile;
  // File? selectedFile;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController();
    _genderController = TextEditingController();
    _kgController = TextEditingController();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _typeController.dispose();
    _kgController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void showErrorMessageSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> returnInt() async {
    setState(() {
      _loading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userID = user.uid;
      DatabaseReference ref =
          FirebaseDatabase.instance.ref('return-investment');
      var newRef = ref.push();

      await newRef.set({
        'type': _typeController.text,
        'gender': _genderController.text,
        'bdate': _dateController.text,
        'kg': _kgController.text,
        'userID': userID,
      });
      _showSuccessDialog('Return Investment Success');
    } catch (e) {
      print(e);
    }
    setState(() {
      _loading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 50,
                          ),
                          Image.asset(
                            'assets/icons/icon_hogme.png',
                            height: 40,
                            width: 40,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Hogme',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w900,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 325,
                        child: Column(
                          children: [
                            const Text(
                              'Return Investment',
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              controller: _typeController,
                              decoration: InputDecoration(
                                  hintText: "Type",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  fillColor: Colors.grey.withOpacity(0.1),
                                  filled: true,
                                  suffixIcon:
                                      const Icon(Icons.person_2_outlined)),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: _genderController,
                              decoration: InputDecoration(
                                  hintText: "Gender",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  fillColor: Colors.grey.withOpacity(0.1),
                                  filled: true,
                                  suffixIcon:
                                      const Icon(Icons.person_2_outlined)),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: _dateController,
                              onTap: () => _selectDate(context),
                              readOnly: true,
                              decoration: InputDecoration(
                                  hintText: "Birth Date",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  fillColor: Colors.grey.withOpacity(0.1),
                                  filled: true,
                                  suffixIcon:
                                      const Icon(Icons.person_2_outlined)),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: _kgController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: "Kilo Gram (kg)",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  fillColor: Colors.grey.withOpacity(0.1),
                                  filled: true,
                                  suffixIcon:
                                      const Icon(Icons.person_2_outlined)),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            CustomButtons(
                                onPressed: _loading ? null : () => returnInt(),
                                text: "Submit",
                                textColor: Colors.white,
                                buttonColor: AppTheme
                                    .primaryButtons // Adjust color accordingly
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget imgExistFacility() => selectedFacilityFile != null
      ? Image.file(
          selectedFacilityFile!,
          width: 150,
          height: 150,
          fit: BoxFit.fitWidth,
        )
      : imgNotExist();

  Widget imgExistValidId() => selectedValidIDFile != null
      ? Image.file(
          selectedValidIDFile!,
          width: 150,
          height: 150,
          fit: BoxFit.fitWidth,
        )
      : imgNotExist();

  Widget imgNotExist() => const Center(
        child: Icon(
          Icons.no_accounts,
          size: 150,
          color: Colors.white,
        ),
      );
}
