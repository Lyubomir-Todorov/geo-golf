import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HowToPlay extends StatefulWidget {
  const HowToPlay({Key? key}) : super(key: key);

  @override
  State<HowToPlay> createState() => _HowToPlayState();
}

class _HowToPlayState extends State<HowToPlay> {

  bool _dontShowAgain = false;

  _gotoStreetView() {
    // popAndPushNamed is used so that player returns home rather than
    // this screen if they decide to leave the match
    Navigator.popAndPushNamed(context, '/streetview');
  }

  _toggleDontShow(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dontShowAgain = newValue;
      prefs.setBool("showTutorial", !_dontShowAgain);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('This will be our tutorial page'),
              const Text('Explain the game\'s objective (You have 5 attempts, get as close as you can)'),
              const Text('Explain how the colour coding works'),
              const Text('Explain the best distance mechanic'),


              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _dontShowAgain,
                    onChanged: (bool? newValue) {
                      _toggleDontShow(newValue!);
                    },
                  ),
                  const Text('Don\'t show this again'),
                ],
              ),

              ElevatedButton(onPressed: () {_gotoStreetView();}, child: const Text('Let\'s Go!'))
            ],
          ),
        ),
      ),
    );
  }
}
