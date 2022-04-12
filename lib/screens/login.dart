import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../classes/toast.dart';

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
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailFieldController.text,
        password: _passwordFieldController.text
      );

      // Any code passed this point means login was successful
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch(e.code) {
        case('too-many-requests'): errorMessage = "Too many requests, try again later"; break;
        case('user-not-found'): errorMessage = "No user found"; break;
        case('wrong-password'): errorMessage = "Incorrect password"; break;
        case('user-disabled'): errorMessage = "This account is currently disabled"; break;
        default: errorMessage = e.toString();
      }
      Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, errorMessage);
    }
  }

  _gotoRegistration() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'GeoGolf',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    Text(
                      'Login to continue',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      controller: _emailFieldController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email address',
                        labelText: 'Email Address',
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
                        RequiredValidator(errorText: "Password is required"),
                      ])
                    ),

                    const SizedBox(height: 16.0),

                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _signIn();
                        }
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),

                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: "Sign up",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {_gotoRegistration();}
                        ),
                      ]
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
