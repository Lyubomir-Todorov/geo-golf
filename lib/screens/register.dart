import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';

import '../classes/toast.dart';
import '../enum/distance.dart';


class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final _nameFieldController = TextEditingController();
  final _emailFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();

  _register() async {
    try {

      // Create user

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailFieldController.text,
        password: _passwordFieldController.text
      );

      // Everything past this point indicates successful user creation
      // Now, lets add that personal info to the users collection
      // With the document being that user's id for easy reference

      var userID = userCredential.user!.uid;
      DocumentReference users = FirebaseFirestore.instance.collection('users').doc(userID);

      DateTime now = DateTime.now();
      users.set({
        'name': _nameFieldController.text,
        'points' : 0,
        'level' : 1,
        'xp' : 0,
        'member_since' : DateFormat('MMMM dd, y').format(now),
        'unit' : Distance.metric.index,
      }).catchError((e) => Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, "Error registering!"));


      // Everything has been done correctly, lets go to the main screen
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch(e.code) {
        case('weak-password'): errorMessage = "The password provided is too weak"; break;
        case('email-already-in-use'): errorMessage = "An account with this email already exists"; break;
        default: errorMessage = e.toString();
      }
      Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Image.asset('images/splash_register.png'),

                  const SizedBox(height: 32),
                  Text(
                    'Sign up',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    controller: _nameFieldController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      labelText: 'Full name',
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: "Name is required"),
                      PatternValidator(r"^([a-zA-Z]{2,}\s[a-zA-Z]{1,}'?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)", errorText: "Invalid name")
                    ]),
                  ),

                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: _emailFieldController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email address',
                      labelText: 'Email address',
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: "Email is required"),
                      EmailValidator(errorText: "Invalid email")
                    ])
                  ),

                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    controller: _passwordFieldController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                      labelText: 'Password',
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Password is required'),
                      MinLengthValidator(8, errorText: 'Password must be at least 8 digits long'),
                      MaxLengthValidator(32, errorText: 'Password must be less than 32 digits long'),
                      PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'Password must have at least one special character')
                    ])
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _register();
                      }
                    },
                    child: const Text('Sign up')
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
