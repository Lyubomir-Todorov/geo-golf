import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Stats extends StatefulWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> with AutomaticKeepAliveClientMixin<Stats> {

  Future<DocumentSnapshot> _getUserInfo() async {
    DocumentReference users = FirebaseFirestore.instance.collection('users')
                              .doc(FirebaseAuth.instance.currentUser?.uid);
    return users.get();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    super.build(context);

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Your stats'))),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Whatever saved data you have will appear here"),
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