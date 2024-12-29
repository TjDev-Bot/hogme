// ignore_for_file: use_build_context_synchronously, empty_catches, non_constant_identifier_names

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hogme/utils/app_theme.dart';
import 'package:hogme/utils/custom_buttons.dart';
import 'package:hogme/views/authentication_screens/login_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _acceptedTerms = false;
  bool _acceptedMoa = false;

  bool _isChecked = false;
  bool _moaChecked = false;
  bool _isPasswordVisible = true;
  bool _loading = false;

  final _formKey = GlobalKey<FormState>();

  String error = '';

  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  late TextEditingController contactNumberController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmpasswordController;

  File? selectedFacilityFile;
  File? selectedValidIDFile;
  // File? selectedFile;

  @override
  void initState() {
    super.initState();
    firstnameController = TextEditingController();
    lastnameController = TextEditingController();
    contactNumberController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmpasswordController = TextEditingController();
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    contactNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }

  Future<void> pickFacilityFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFacilityFile = File(result.files.first.path!);
      });
    }
  }

  Future<void> pickValidIDFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedValidIDFile = File(result.files.first.path!);
      });
    }
  }

  // Future<void> pickFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //   );

  //   if (result != null && result.files.isNotEmpty) {
  //     setState(() {
  //       selectedFile = File(result.files.first.path!);
  //     });
  //   }
  // }

  void showErrorMessageSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future registerUser() async {
    setState(() {
      _loading = true;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // User? user = FirebaseAuth.instance.currentUser;
      // await user?.sendEmailVerification();

      setState(() async {
        await createUser();
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            duration: Duration(seconds: 3),
          ),
        );
        error = "";
      });
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (e.code == 'email-already-in-use') {
          showErrorMessageSnackBar('Email address is already in use');
          Navigator.pop(context);

          setState(() {
            error = "Email address is already in use";
          });
        } else if (e.code == 'phone-number-already-in-use') {
          showErrorMessageSnackBar('Contact number is already in use');
          Navigator.pop(context);

          setState(() {
            error = "Contact number is already in use";
          });
        } else {
          showErrorMessageSnackBar('Error: $e');
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);

      setState(() {
        error = "An error occurred during registration.";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future showTermsAndConditionsDialog(BuildContext context) async {
    if (!_acceptedTerms) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Terms and Conditions"),
            content: const SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '1. Acceptance of Terms By using the Tago Surigao del Sur Livestock and Poultry Associations Inc. Management System (referred to as "the System"), you agree to abide by these terms and conditions. If you do not agree with any part of these terms, you may not use the System.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '2. Scope of ServicesThe System is designed to assist in managing Tago Surigao del Sur Livestock and Poultry Associations Inc. Users can access information, submit data, and utilize various features provided by the System.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '3. User Accounts and Security a. To access the System, users must create an account and are responsible for maintaining the confidentiality of their account credentials. b. Users are required to promptly inform System administrators of any unauthorized use or suspected security breaches. c. The System reserves the right to suspend or terminate accounts if there is evidence of unauthorized access or any other security concerns.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '4. Use of the System a. Users agree to use the System in compliance with applicable laws and regulations. b. Users are solely responsible for the content they submit through the System. c. The System reserves the right to monitor, review, and remove content that violates these terms.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '5. Data Privacy a. The System collects and processes personal information in accordance with its Privacy Policy. b. Users consent to the collection, processing, and storage of their personal information as described in the Privacy Policy.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '6. Intellectual Property a. The System and its content are protected by intellectual property laws. Users may not reproduce, distribute, or create derivative works without permission. b. Users retain ownership of the content they submit to the System. By submitting content, users grant the System a non-exclusive, royalty-free license to use, reproduce, and distribute the content within the System.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '7. Limitation of Liability a. The System is provided "as is" and "as available." The System makes no warranties, express or implied, regarding the accuracy, reliability, or availability of its services. b. The System is not liable for any direct, indirect, incidental, special, or consequential damages resulting from the use of or inability to use the System. c. The System is not implemented for cancellation of order. Once the order is confirmed, cancellations may not be possible.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '8. Modifications to Terms The System reserves the right to modify these terms and conditions at any time. Users will be notified of changes, and continued use of the System after modifications constitutes acceptance of the revised terms.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '9. Termination The System may terminate or suspend access to the System, with or without cause, at any time.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '10. Governing Law These terms and conditions are governed by and construed in accordance with the laws of the jurisdiction where Tago Surigao del Sur Livestock and Poultry Associations Inc. is registered. By using the System, you acknowledge that you have read, understood, and agree to be bound by these terms and conditions.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
                        content:
                            Text("You must accept the terms and conditions."),
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
          content: Text("You have already accepted the terms and conditions."),
        ),
      );
    }
  }

  Future showMOADialog(BuildContext context) async {
    if (!_acceptedMoa) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Memorandum of Agreement"),
            content: const SingleChildScrollView(
              child: Column(
                children: [
                  Image(
                    image: AssetImage('assets/images/moa1.jpg'),
                  ),
                  Image(
                    image: AssetImage('assets/images/moa2.jpg'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _acceptedMoa = true;
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
                    _acceptedMoa = false;
                    _isChecked = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "You must accept the Memorandum of Agreement."),
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
          content:
              Text("You have already accepted the Memorandum of Agreement."),
        ),
      );
    }
  }

  Future<void> createUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userID = user.uid;
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('users');
      var newUserRef = ref.child(userID);

      final storage = FirebaseStorage.instance;
      var fileName =
          'RegistrationImageUploads/${selectedFacilityFile != null ? selectedFacilityFile!.path.split('/').last : 'default-facility-file.jpg'}';
      var fileName1 =
          'RegistrationImageUploads/${selectedValidIDFile != null ? selectedValidIDFile!.path.split('/').last : 'default-valid-id-file.jpg'}';

      // var fileName2 =
      //     'RegistrationImageUploads/${selectedFile != null ? selectedFile!.path.split('/').last : 'default-valid-id-file.jpg'}';

      var uploadTask = storage.ref(fileName).putFile(selectedFacilityFile!);
      var uploadTask1 = storage.ref(fileName1).putFile(selectedValidIDFile!);
      // var uploadTask2 = storage.ref(fileName2).putFile(selectedFile!);

      await Future.wait([uploadTask, uploadTask1]);

      String fileUrl = await storage.ref(fileName).getDownloadURL();
      String fileUrl1 = await storage.ref(fileName1).getDownloadURL();
      // String fileUrl2 = await storage.ref(fileName2).getDownloadURL();

      Map<String, dynamic> userData = {
        'id': newUserRef.key,
        'firstname': firstnameController.text,
        'lastname': lastnameController.text,
        'contactnumber': contactNumberController.text,
        'password': passwordController.text,
        'email': emailController.text,
        'profilepicture': "",
        'status': "pending",
        'role': "farmer",
        'balance': 0,
        'comment': '',
        'dateCreated': DateTime.now().toUtc().toString(),
      };

      if (selectedFacilityFile != null) {
        userData['facilitypicture'] = fileUrl;
      }

      if (selectedValidIDFile != null) {
        userData['valididpicture'] = fileUrl1;
      }

      // if (selectedFile != null) {
      //   userData['form'] = fileUrl2;
      // }

      await newUserRef.set(userData);
    } catch (e) {}
  }

  void handleSubmit() {
    if (_isChecked) {
      if (_formKey.currentState!.validate()) {
        try {
          registerUser();
        } catch (error) {
          setState(() {
            _loading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration failed. Please try again."),
            ),
          );
        }
      }
    } else {
      showTermsAndConditionsDialog(context);
      showMOADialog(context);
    }
  }

  void updatePasswordStrength(String password) {
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[\W_]'));
    bool hasMinLength = password.length >= 8;

    if (hasLowerCase &&
        hasUpperCase &&
        hasDigit &&
        hasSpecialChar &&
        hasMinLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check,
                color: Colors.white,
              ),
              Text("Strong password!"),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!hasLowerCase) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Missing lowercase letter"),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (!hasUpperCase) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Missing uppercase letter"),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (!hasDigit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Missing digit"),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (!hasSpecialChar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Missing special character"),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (!hasMinLength) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Password should have a minimum length of 8 characters"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
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
                              'Your Livestock Management Companion',
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              controller: firstnameController,
                              decoration: InputDecoration(
                                  hintText: "First Name",
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
                              controller: lastnameController,
                              decoration: InputDecoration(
                                  hintText: "Last Name",
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
                            IntlPhoneField(
                              keyboardType: TextInputType.phone,
                              initialCountryCode: 'PH',
                              onChanged: (phone) {
                                setState(() {
                                  contactNumberController.text =
                                      phone.completeNumber;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Contact Number",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: Colors.grey.withOpacity(0.1),
                                filled: true,
                                suffix: const Icon(
                                  Icons.contact_emergency_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            GestureDetector(
                              onTap: () => pickValidIDFile(),
                              child: TextFormField(
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText: selectedValidIDFile != null
                                      ? selectedValidIDFile!.path
                                          .split('/')
                                          .last
                                          .split('.')
                                          .first
                                      : 'Valid ID',
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
                            const SizedBox(
                              height: 15,
                            ),
                            GestureDetector(
                              onTap: () => pickFacilityFile(),
                              child: TextFormField(
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText: selectedFacilityFile != null
                                      ? selectedFacilityFile!.path
                                          .split('/')
                                          .last
                                          .split('.')
                                          .first
                                      : 'Facility ID',
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
                            const SizedBox(
                              height: 15,
                            ),
                            // GestureDetector(
                            //   onTap: () => pickFile(),
                            //   child: TextFormField(
                            //     enabled: false,
                            //     decoration: InputDecoration(
                            //       hintText: selectedFile != null
                            //           ? selectedFile!.path
                            //               .split('/')
                            //               .last
                            //               .split('.')
                            //               .first
                            //           : 'Form',
                            //       border: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(10),
                            //         borderSide: BorderSide.none,
                            //       ),
                            //       fillColor: Colors.grey.withOpacity(0.1),
                            //       filled: true,
                            //       suffixIcon: const Icon(Icons.vrpano_outlined),
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                  hintText: "Email",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  fillColor: Colors.grey.withOpacity(0.1),
                                  filled: true,
                                  suffixIcon: const Icon(Icons.email_outlined)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                if (!RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              obscureText: _isPasswordVisible,
                              controller: passwordController,
                              decoration: InputDecoration(
                                hintText: "Password",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                                fillColor: Colors.grey.withOpacity(0.1),
                                filled: true,
                                suffixIcon: IconButton(
                                  onPressed: togglePasswordVisibility,
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.lock_outline_rounded
                                        : Icons.lock_open_rounded,
                                  ),
                                ),
                              ),
                              onEditingComplete: () {
                                updatePasswordStrength(passwordController.text);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Too Short.\n At least one lowercase letter (a-z) \n At least one uppercase letter (A-Z) \n Atleast one digit (1) \n Atleast one special character (@) \n Atleast minimum length of 8 characters.';
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              obscureText: _isPasswordVisible,
                              controller: confirmpasswordController,
                              decoration: InputDecoration(
                                hintText: "Confirm Password",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                                fillColor: Colors.grey.withOpacity(0.1),
                                filled: true,
                                suffixIcon: IconButton(
                                  onPressed: togglePasswordVisibility,
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.lock_outline_rounded
                                        : Icons.lock_open_rounded,
                                  ),
                                ),
                              ),
                              onEditingComplete: () {
                                updatePasswordStrength(
                                  confirmpasswordController.text,
                                );
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Too Short.\n At least one lowercase letter (a-z) \n At least one uppercase letter (A-Z) \n Atleast one digit (1) \n Atleast one special character (@) \n Atleast minimum length of 8 characters.';
                                } else {
                                  return null;
                                }
                              },
                            ),
                            TermsAndCondition(),
                            memorandumOfAgreementCheckbox(),
                            CustomButtons(
                              onPressed: _loading ? null : () => handleSubmit(),
                              text: "Sign Up",
                              textColor: Colors.white,
                              buttonColor: _isChecked
                                  ? AppTheme.primaryButtons
                                  : Colors.grey, // Adjust color accordingly
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already a memeber?'),
                                const SizedBox(
                                  width: 4,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign in',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                )
                              ],
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

  Widget TermsAndCondition() => Row(
        children: [
          Checkbox(
            value: _isChecked,
            activeColor: const Color(0xFF2C74B3),
            onChanged: (value) {
              setState(() {
                _isChecked = value ?? false;
                if (_isChecked) {
                  showTermsAndConditionsDialog(context);
                }
              });
            },
          ),
          const Expanded(
            child: Row(
              children: [
                Text(
                  'By checking the box you agree to our',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 9.5,
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                Text(
                  'Terms',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 9.5,
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                Text(
                  'and',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 9.5,
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                Text(
                  'Condations.',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget memorandumOfAgreementCheckbox() => Row(
        children: [
          Checkbox(
            value: _moaChecked,
            activeColor: const Color(0xFF2C74B3),
            onChanged: (value) {
              setState(() {
                _moaChecked = value ?? false;
                if (_moaChecked) {
                  showMOADialog(context);
                }
              });
            },
          ),
          const Expanded(
            child: Text(
              'I agree to the Memorandum of Agreement',
              style: TextStyle(
                color: Colors.black38,
                fontSize: 9.5,
              ),
            ),
          ),
        ],
      );

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
