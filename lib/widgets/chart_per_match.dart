import 'package:final_project/classes/guess.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../classes/match_history.dart';
import '../enum/distance.dart';
import 'indicator.dart';

class ChartPerMatch extends StatefulWidget {
  final List<MatchHistory> data;
  final Distance unit;
  const ChartPerMatch({Key? key, required this.data, required this.unit}) : super(key: key);

  @override
  _ChartPerMatchState createState() => _ChartPerMatchState();
}

class _ChartPerMatchState extends State<ChartPerMatch> {

  final List<PieChartSectionData> _plots = [];

  final List<Color> sectionColors = const[
    Color(0xff43aa8b),
    Color(0xfff9c74f),
    Color(0xfff3722c),
    Color(0xfff94144),
  ];

  final Color background = const Color(0xff373F47);
  final Color accent = const Color(0xff423b5a);

  _convertMatchHistoryToFlData() {
    _plots.clear();
    int totalMatches = widget.data.isNotEmpty ? widget.data.length : 1;
    List<int> matchTypes = [0,0,0,0];

    for (var element in widget.data) {
      matchTypes[GuessQuality.getRank(element.bestDistance, unit: widget.unit).index] ++;
    }
    for(var i = 0; i < matchTypes.length; i ++) {
      var val = ((matchTypes[i]/totalMatches)*360);
      var valper =((matchTypes[i]/totalMatches)*100);
      _plots.add(
        PieChartSectionData(
          radius: 64,
          //title: GuessQuality.getRankAsDescriptor(GuessRank.values[i]),
          value: val,
          title: valper.toStringAsFixed(1) + "%",
          color: sectionColors[i],
          titleStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        )
      );
    }

  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _convertMatchHistoryToFlData();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(18),
          ),
          color: background
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: widget.data.isEmpty ?
          const Center(
            child: Text(
              'no match data to show here...',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ):
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Overall match rankings',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  fontSize: 16,
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: double.infinity,
                          sectionsSpace: 4,
                          sections: _plots
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                        List.generate(GuessRank.values.length, (index) {
                          return Indicator(
                            color: sectionColors[index],
                            title: GuessQuality.getRankAsDescriptor(GuessRank.values[index]),
                            subtitle: GuessQuality.getRankAsRangeDescriptor(GuessRank.values[index], unit: widget.unit),
                            isSquare: false,
                            size: 16,
                            textColor: Colors.grey,
                          );
                        }).toList()
                    )
                  ],
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
