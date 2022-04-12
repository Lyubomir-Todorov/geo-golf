import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:final_project/screens/home.dart';
import 'package:final_project/screens/profile.dart';
import 'package:final_project/screens/stats.dart';

// This will be our widget that holds the bottom navigator
// Think of it as embedding the corresponding widget depending on the index we choose

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {

  late int _selectedPageIndex;
  late PageController _pageController;

  late Future<DocumentSnapshot> futureUser;

  Future<DocumentSnapshot> _getUserInfo() async {
    DocumentReference users = FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);
    return users.get();
  }

  late List<Widget> _children;

  _createPages() {

    _children.add(Stats(key: UniqueKey()));

    _children.add(Home(future: futureUser, key: UniqueKey()));

    _children.add(Profile(key: UniqueKey(),
      onProfileUpdated: () {
        setState(() {
          futureUser = _getUserInfo();
          _children.removeAt(1);
          _children.insert(1, Home(future: futureUser, key: UniqueKey()));
        });
      },
      onDistanceUpdated: () {
        setState(() {
          _children.removeAt(0);
          _children.insert(0, Stats(key: UniqueKey()));
        });
      },
    ));

    _selectedPageIndex = 1;

    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void initState() {
    super.initState();

    _children = [];

    futureUser = _getUserInfo();
    _createPages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List<Widget>.of(_children),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidChartBar),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.houseChimney),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidUser),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedPageIndex,
        onTap: (selectedPageIndex) {
          setState(() {
            _selectedPageIndex = selectedPageIndex;
            _pageController.jumpToPage(selectedPageIndex);
           //(_children[2] as Profile).cancelChanges();
          });
        },
      ),
    );
  }
}