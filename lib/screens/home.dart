import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  _gotoMatch() {
    Navigator.pushNamed(context, '/country');
  }
  _gotoSV() {
    Navigator.pushNamedAndRemoveUntil(context, '/streetview', (route) => false);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    super.build(context);

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Final Project'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hello, ${data['first_name']}!"),
                        Text("Points: ${data['points']}"),
                      ],
                    ),


                    ElevatedButton(onPressed: () {_gotoSV();}, child: const Text("Street view test")),
                    ElevatedButton(onPressed: () {_gotoMatch();}, child: const Text("Start Match"))
                  ],
                );
              }

              return const CircularProgressIndicator();
            }
          ),
        ),
      ),
    );
  }
}