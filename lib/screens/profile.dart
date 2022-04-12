import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../classes/toast.dart';
import '../enum/distance.dart';
import '../styles/btn_styles.dart';
import '../classes/user.dart' as fb;


class Profile extends StatefulWidget {
  final VoidCallback onProfileUpdated;
  final VoidCallback onDistanceUpdated;
  cancelChanges() => createState()._endEditing();
  const Profile({Key? key, required this.onProfileUpdated, required this.onDistanceUpdated}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with AutomaticKeepAliveClientMixin {

  bool shouldKeepAlive = true;

  final _formKey = GlobalKey<FormState>();

  final _nameFieldController = TextEditingController();
  final _emailFieldController = TextEditingController();

  bool _updating = false;

  late Future<DocumentSnapshot> _future;
  late fb.User _user;

  _logout() {
    FirebaseAuth.instance.signOut().then((value) {
      Toast.display(context, FontAwesomeIcons.solidCircleCheck, Colors.white, Colors.green, "Successfully signed out!");
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }).catchError((e) => Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, "Error signing out!"));

  }

  Future<DocumentSnapshot> _getUserInfo() async {
    DocumentReference users = FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);
    return users.get();
  }

  setUser(Future<DocumentSnapshot> d) {
    d.then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      setState(() {
        _user = fb.User.fromJson(data);
      });
    });
  }

  _startEditing(String? name, String? email) {
    setState(() {
      _updating = true;
      _nameFieldController.text = name!;
      _emailFieldController.text = email!;
    });
    shouldKeepAlive = false;
    updateKeepAlive();
  }

  _endEditing() {
    setState(() {
      _updating = false;
    });
    shouldKeepAlive = true;
    updateKeepAlive();
  }

  _updateInfo() async {

    FocusManager.instance.primaryFocus?.unfocus();

    FirebaseAuth.instance.currentUser?.updateEmail(_emailFieldController.text).then((value) {
      DocumentReference user = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);

      user.update({
        "name" : _nameFieldController.text,
      }).then((value) {
        widget.onProfileUpdated();
      }).catchError((e) => Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, "Failed to update name!"));
    }).then((value) {
      Toast.display(context, FontAwesomeIcons.solidCircleCheck, Colors.white, Colors.green, "Profile successfully updated!");
      setState(() {
        _updating = false;
        _future = _getUserInfo();
      });
    }).catchError((e) => Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, "Error updating info!"));
  }

  _updateUnit() {
    DocumentReference user = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);
    user.update({
      "unit" : _user.unit.index
    }).then((value) {
      print("Unit updated");
      widget.onDistanceUpdated();
    }).catchError((e) => Toast.display(context, FontAwesomeIcons.solidCircleXmark, Colors.white, Colors.red, "Error updating preferences!"));
  }

  @override
  void initState() {
    super.initState();
    _future = _getUserInfo();
    setUser(_future);
  }

  @override
  bool get wantKeepAlive => shouldKeepAlive;

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
            future: _future,
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong"));
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return const Center(child: Text("Document does not exist"));
              }

              if (snapshot.connectionState == ConnectionState.done) {
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
                        Text('${_user.getFirstName()} ${_user.getLastName()}'),
                        Text('${_user.getEmail()}'),
                        Text('Member since ${_user.joinDate}'),
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
                                validator: MultiValidator([
                                  RequiredValidator(errorText: "Name is required"),
                                  PatternValidator(r"^([a-zA-Z]{2,}\s[a-zA-Z]{1,}'?-?[a-zA-Z]{2,}\s?([a-zA-Z]{1,})?)", errorText: "Invalid name")
                                ]),
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
                                validator: MultiValidator([
                                  RequiredValidator(errorText: "Email is required"),
                                  EmailValidator(errorText: "Invalid email")
                                ])
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
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _updateInfo();
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: const Text("Save Changes")
                          ),
                        ),
                      ],
                    ):
                    ElevatedButton.icon(
                        onPressed: () {_startEditing(_user.fullName, _user.getEmail());},
                        icon: const Icon(Icons.edit),
                        label: const Text("Update Information")
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Unit Preferences',
                      style: Theme.of(context).textTheme.headline5,
                    ),

                    const Divider(thickness: 3),

                    const SizedBox(height: 16),

                    ListTile(
                      leading: Radio<Distance>(
                        value: Distance.metric,
                        groupValue: _user.unit,
                        onChanged: (Distance ? value) {
                          setState(() {
                            _user.unit = value!;
                            _updateUnit();
                          });
                        },
                      ),
                      title: const Text('Metric'),
                      subtitle: const Text('Kilometers, meters'),
                    ),

                    ListTile(
                      leading: Radio<Distance>(
                        value: Distance.imperial,
                        groupValue: _user.unit,
                        onChanged: (Distance ? value) {
                          setState(() {
                            _user.unit = Distance.imperial;
                            _updateUnit();
                          });
                        },
                      ),
                      title: const Text('Imperial'),
                      subtitle: const Text('Miles, yards'),
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