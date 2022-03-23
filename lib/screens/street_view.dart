import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

class StreetView extends StatelessWidget {
  StreetViewController? streetViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Street View Init Demo'),
      ),
      body: SafeArea(
        child: FlutterGoogleStreetView(
          initPos: const LatLng(43.187500, -79.852160),
          onStreetViewCreated: (StreetViewController controller) async {
            //save controller for late using
            streetViewController = controller;
            streetViewController?.setUserNavigationEnabled(false);
          }
        ),
      ),
    );
  }
}

