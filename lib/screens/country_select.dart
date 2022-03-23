import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import '../data/country_data.dart';

class CountrySelection extends StatefulWidget {
  const CountrySelection({Key? key}) : super(key: key);

  @override
  _CountrySelectionState createState() => _CountrySelectionState();
}

class _CountrySelectionState extends State<CountrySelection> {
  late MapShapeSource _selectionMapSource;
  late MapZoomPanBehavior _zoomPanBehavior;
  int _selectedIndex = -1;

  _switchCountries(int index) {
    setState(() {
      _selectedIndex = (index == _selectedIndex) ? -1 : index;
    });
  }

  @override
  void initState() {
    _zoomPanBehavior = MapZoomPanBehavior();
    _selectionMapSource = MapShapeSource.asset(
      'assets/world_map.json',
      shapeDataField: 'name',
      dataCount: countries.length,
      primaryValueMapper: (int index) => countries[index].name,
    );

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      appBar: AppBar(title: const Center(child: Text(''))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SfMaps(
                layers: [
                  MapShapeLayer(
                    loadingBuilder: (BuildContext context) {
                      return const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    source: _selectionMapSource,
                    selectedIndex: _selectedIndex,
                    color: Colors.green[300],
                    selectionSettings: const MapSelectionSettings(
                      color: Colors.orange,
                    ),
                    onSelectionChanged: (int index) {
                      _switchCountries(index);
                    },
                    zoomPanBehavior: _zoomPanBehavior,
                  ),
                ],
              ),
            ),

            (_selectedIndex != -1) ?
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(countries[_selectedIndex].name),
                  ElevatedButton(onPressed: () {}, child: const Text("Guess!"))
                ],
              ),
            ):
            const Text('')


          ],
        ),
      ),
    );
  }
}
