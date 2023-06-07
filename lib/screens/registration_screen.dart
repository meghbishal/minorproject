// ignore_for_file: use_build_context_synchronously
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_passwordField.dart';
import '../widgets/custom_textbutton.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/loading_animation.dart';
import '../widgets/snackbar.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const String route = "/registration_screen";

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  var fullnameController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  var confirmPasswordController = TextEditingController();

  Future registerUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: ((context) =>  LoadingAnimation()),
    );
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final User user = userCredential.user;

      if (user != null) {
        
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.route, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showSnackBar(e.message.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                
                Column(
                  children: [
                    const SizedBox(
                  height: 150,
                  
              
          
                 ),
                    CustomTextField(
                      emailController: fullnameController,
                      hintText: "Full Name",
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomTextField(
                      emailController: emailController,
                      hintText: "Email",
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomPasswordField(
                        passwordController: passwordController,
                        passwordVisible: true,
                        title: "Password"),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomPasswordField(
                        passwordController: confirmPasswordController,
                        passwordVisible: true,
                        title: "Confirm Password"),
                    const SizedBox(
                      height: 35,
                    ),
                    CustomTextButton(
                      size: size,
                      title: "Sign Up",
                      onPressed: () async {
                        //checking connectivity to network. funtion needs to be async
                        var connectivityResult =
                            await Connectivity().checkConnectivity();
                        if (connectivityResult != ConnectivityResult.mobile &&
                            connectivityResult != ConnectivityResult.wifi) {
                          showSnackBar("No internet connection!", context);
                          return;
                        }
                
                        if (fullnameController.text.length <= 3) {
                          showSnackBar("Please enter a valid name!", context);
                          return;
                        }
                
                        if (!emailController.text.contains('@')) {
                          showSnackBar("Please enter a valid email!", context);
                          return;
                        }
                
                        if (passwordController.text.length <= 6) {
                          showSnackBar("Password must be more than 6 characters!",
                              context);
                          return;
                        }
                
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          showSnackBar("Password doesnot match", context);
                          return;
                        }
                
                        registerUser();
                      },
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    Container(
                      height: 1,
                      color: Theme.of(context).primaryColor,
                      width: size.width * 0.6,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontFamily: "Roboto",
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, LoginScreen.route, (route) => false);
                            },
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontFamily: "Roboto",
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ))
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}