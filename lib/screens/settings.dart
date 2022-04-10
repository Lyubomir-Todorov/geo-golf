import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../styles/btn_styles.dart';
import '../classes/user.dart' as fb;

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with AutomaticKeepAliveClientMixin<Settings> {

  final _formKey = GlobalKey<FormState>();

  final _nameFieldController = TextEditingController();
  final _emailFieldController = TextEditingController();

  bool _updating = false;

  late Future<DocumentSnapshot> future;


  _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<DocumentSnapshot> _getUserInfo() async {
    DocumentReference users = FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);
    return users.get();
  }

  _startEditing(String? name, String? email) {
    setState(() {
      _updating = true;
      _nameFieldController.text = name!;
      _emailFieldController.text = email!;
    });
  }

  _endEditing() {
    setState(() {
      _updating = false;
    });
  }

  _updateInfo() async {

    FirebaseAuth.instance.currentUser?.updateEmail(_emailFieldController.text).then((value) {
      DocumentReference user = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);

      user.update({
        "name" : _nameFieldController.text,
      }).then((value) => print("Name updated"))
          .catchError((error) => print("Failed to update Name: $error"));
    }).then((value) {
      print("Email updated");
      setState(() {
        _updating = false;
        future = _getUserInfo();
      });
    }).catchError((error) => print("Failed to update Email: $error"));

  }

  @override
  void initState() {
    super.initState();
    future = _getUserInfo();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: future,
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return const Text("Document does not exist");
              }

              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                fb.User user = fb.User.fromJson(data);
                return ListView(
                  children: [
                    const SizedBox(height: 32),

                    Text(
                      'Your information',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const Divider(thickness: 3),

                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: !_updating ? [
                        Text('${user.getFirstName()} ${user.getLastName()}'),
                        Text('${user.getEmail()}'),
                        Text('Member since ${user.joinDate}'),
                      ] : [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.name,
                                textInputAction: TextInputAction.next,
                                controller: _nameFieldController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your full name',
                                  labelText: 'Full name',
                                  border: OutlineInputBorder()
                                ),
                                validator: (value) {
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                controller: _emailFieldController,
                                decoration: const InputDecoration(
                                    hintText: 'Enter your email address',
                                    labelText: 'Email Address',
                                    border: OutlineInputBorder()
                                ),
                                validator: (value) {
                                  return null;
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    _updating ?
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: danger,
                            onPressed: () {_endEditing();},
                            icon: const Icon(Icons.cancel_rounded),
                            label: const Text("Cancel")
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: ElevatedButton.icon(
                              onPressed: () {_updateInfo();},
                              icon: const Icon(Icons.check),
                              label: const Text("Save Changes")
                          ),
                        ),
                      ],
                    ):
                    ElevatedButton.icon(
                      onPressed: () {_startEditing(user.fullName, user.getEmail());},
                      icon: const Icon(Icons.edit),
                      label: const Text("Update Information")
                    ),



                    const SizedBox(height: 32),

                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.headline5,
                    ),

                    const Divider(thickness: 3),

                    const SizedBox(height: 16),

                    const Text('Sign out of your GeoGolf account on this device'),

                    const SizedBox(height: 16),

                    OutlinedButton.icon(
                        onPressed: () {_logout();},
                        icon: const Icon(Icons.logout),
                        label: const Text("Sign out")
                    )
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          )
        ),
      ),
    );
  }
}