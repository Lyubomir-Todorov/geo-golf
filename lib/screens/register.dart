import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameFieldController = TextEditingController();
  final _lastNameFieldController = TextEditingController();
  final _emailFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();
  final _passwordConfirmationFieldController = TextEditingController();

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

      users.set({
        'first_name': _firstNameFieldController.text,
        'last_name': _lastNameFieldController.text,
        'points' : 0,
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
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            child: ListView(
              children: [
                const Text('Create a new account'),

                // TODO: Enforce validation on the form

                TextFormField(
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  controller: _firstNameFieldController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your first name',
                    labelText: 'First name',
                  ),
                  autofocus: true,
                  validator: (value) {
                    return null;
                  },
                ),

                TextFormField(
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  controller: _lastNameFieldController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your last name',
                    labelText: 'Last name',
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
                    hintText: 'Enter your email',
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

                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  controller: _passwordConfirmationFieldController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Confirm your password',
                    labelText: 'Confirm password',
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
                ElevatedButton(onPressed: () {_register();}, child: const Text('Submit')),
              ],
            ),
          ),
        ),
      )
    );
  }
}
