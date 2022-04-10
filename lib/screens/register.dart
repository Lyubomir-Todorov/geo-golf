import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


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

      // TODO -> Enforce security roles in firebase console
      // Only create this document if points is 0
      DateTime now = DateTime.now();
      users.set({
        'name': _nameFieldController.text,
        'points' : 0,
        'level' : 1,
        'xp' : 0,
        'member_since' : DateFormat('MMMM dd, y').format(now),
      }).then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));


      // Everything has been done correctly, lets go to the main screen
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
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
                  // TODO -> Enforce validation on the form
                  TextFormField(
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    controller: _nameFieldController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      labelText: 'Full name',
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),

                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: _emailFieldController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email address',
                      labelText: 'Email address',
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),

                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    controller: _passwordFieldController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(onPressed: () {_register();}, child: const Text('Sign up')),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
