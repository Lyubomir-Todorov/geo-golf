import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  FirebaseAuth auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  final _emailFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();

  _signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "1@2.com",
        password: "password"
      );

      // Any code passed this point means login was successful
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);

    } on FirebaseAuthException catch (e) {

      // TODO: Change this to show in app errors, such as a snackbar

      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Final Project')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            child: ListView(
              children: [
                const Text('title goes here'),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  controller: _emailFieldController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    labelText: 'Email Address',
                  ),
                  validator: (value) {
                    return null;
                  },
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
                  validator: (value) {
                    return null;
                  },
                ),
                ElevatedButton(onPressed: () {_signIn();}, child: Text('Login')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Register')
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
