// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, use_super_parameters

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hogme/utils/app_theme.dart';
import 'package:hogme/utils/custom_buttons.dart';
import 'package:hogme/views/authentication_screens/register_screen.dart';
import 'package:hogme/views/dashboard_screens/home1.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = true;
  bool _loading = false;

  Future<void> signIn() async {
// Initialize loginSuccess as false

    if (formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          if (user.emailVerified) {
            await route(user.uid);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please verify your account before logging in.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } on FirebaseAuthException {
        // Handle FirebaseAuthException
      } finally {
        setState(() {
          _loading = false;
        });

        // if (loginSuccess) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text('Account Successfully login.'),
        //       duration: Duration(seconds: 3),
        //     ),
        //   );
        // }
      }
    }
  }

  Future<void> route(String userID) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users/$userID');
    DataSnapshot snapshot = (await userRef.once()).snapshot;

    if (snapshot.value != null) {
      Map? userData = snapshot.value as Map?;
      if (userData != null) {
        String? status = userData['status'];
        String? role = userData['role'];
        if (status == "inactive") {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Text("Concern"),
                content: const SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'You have been inactive user lately. Kindly reach out to the administrator to proceed with the login process',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
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
                    },
                    child: const Text(
                      "Okay",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              );
            },
          );
        } else if (status == "blocklisted") {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Text("Concern"),
                content: const SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'You have been blocklisted lately. Kindly reach out to the administrator to proceed with the login process',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
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
                    },
                    child: const Text(
                      "Okay",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          if (role == "farmer") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Home1(),
              ),
            );
          } else
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Your role is not Farmer.'),
                  duration: Duration(seconds: 3),
                ),
              );
            };
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Null value'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 6,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 140),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logohogme.jpg',
                      height: 80,
                      width: 80,
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
                const SizedBox(
                  width: 285,
                  child: Text(
                    'TAGO SURIGAO DEL SUR LIVESTOCK AND POULTY RAISERS ASSOCIATION, INCORPORATED ',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 80),
                Container(
                  height: 480,
                  width: 325,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
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
                                  return 'Please enter your registered email';
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Too Short.\n At least one lowercase letter (a-z) \n At least one uppercase letter (A-Z) \n Atleast one digit (1) \n Atleast one special character (@) \n Atleast minimum length of 8 characters.';
                                } else {
                                  return null;
                                }
                              },
                            )
                            // CustomTextfield(
                            //   controller: passwordController,
                            //   hintText: 'Password',
                            //   obscureText: true,
                            //   suffixIcon: IconButton(onPressed: (){},)
                            //   validator: (value) {
                            //     if (value == null || value.isEmpty) {
                            //       return 'Please enter your password';
                            //     }
                            //     return null;
                            //   },
                            // ),
                          ],
                        ),
                      ),
                      // const Padding(
                      //   padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [Text('Forgot password?')],
                      //   ),
                      // ),
                      const SizedBox(height: 120),

                      CustomButtons(
                        onPressed: _loading ? null : signIn,
                        text: "Log in",
                        textColor: Colors.white,
                        buttonColor: AppTheme.primaryButtons,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'New Member?',
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Register now',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
