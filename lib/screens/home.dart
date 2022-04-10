import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/user.dart' as fb;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin<Home> {

  Future<DocumentSnapshot> _getUserInfo() async {
    DocumentReference users = FirebaseFirestore.instance.collection('users')
                              .doc(FirebaseAuth.instance.currentUser?.uid);
    return users.get();
  }

  _gotoMatch() async {
    final prefs = await SharedPreferences.getInstance();
    var t = prefs.getBool("showTutorial");

    Navigator.pushNamed(context, (t == true || t == null) ? '/how_to_play' : '/streetview');
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    super.build(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('GeoGolf'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: _getUserInfo(),
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 32),

                        Text(
                          "Hello, ${user.getFirstName()}!",
                          style: Theme.of(context).textTheme.headline1,
                        ),
                        Text(
                          "${user.points} points",
                          style: Theme.of(context).textTheme.headline1,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Level ${user.level}",
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        LinearProgressIndicator(
                          value: data['xp'] / 100,
                          minHeight: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${user.xp} / 100 XP',
                              style: Theme.of(context).textTheme.headline2,
                            )
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {_gotoMatch();},
                        child: const Text(
                          "Start Match",
                        )
                      ),
                    )
                  ],
                );
              }

              return const Center(child: CircularProgressIndicator());
            }
          ),
        ),
      ),
    );
  }
}