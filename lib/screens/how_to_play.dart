import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  static const markerColors = [Colors.green, Colors.yellow, Colors.orange, Colors.red];
  static const markerRange = ["< 10 KM", "< 250 KM", "< 500 KM", "> 500 KM"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to GeoGolf!'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const SizedBox(height: 32),

              const Text(
                'You are about to be dropped in a random location on planet Earth; it is up to you to figure out where the heck you are!'
              ),

              const SizedBox(height: 16),

              Card(
                margin: EdgeInsets.zero,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You have 5 attempts!',
                              style: Theme.of(context).textTheme.headline1
                            ),
                            Text(
                              'Get as close as possible',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ],
                        ),
                      ),
                      const Flexible(
                        child: FaIcon(
                          FontAwesomeIcons.locationDot,
                          size: 72, color:
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text('Use the map to place a marker where you think you are, then press "Guess"!'),

              const SizedBox(height: 16),

              Card(
                margin: EdgeInsets.zero,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).primaryColor, width: 4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The marker you drop will be a different color based on how far away your guess is.',
                        style: Theme.of(context).textTheme.headline6?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(markerColors.length, (index) {
                          return Column(
                            children: [
                              const SizedBox(height: 16.0),
                              FaIcon(
                                FontAwesomeIcons.locationDot,
                                size: 32, color:
                                markerColors[index],
                              ),
                              const SizedBox(height: 8.0),
                              Text(markerRange[index]),
                            ],
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _dontShowAgain,
                    onChanged: (bool? newValue) {
                      _toggleDontShow(newValue!);
                    },
                  ),
                  const Text('Don\'t show this page again'),
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
