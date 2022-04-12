import 'package:final_project/classes/match_history.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../enum/distance.dart';

// Chart documentation here
// https://github.com/imaNNeoFighT/fl_chart/blob/master/repo_files/documentations/line_chart.md#sample-1-source-code

class ChartPerformance extends StatefulWidget {
  final List<MatchHistory> data;
  final Distance unit;

  const ChartPerformance({Key? key, required this.data, required this.unit}) : super(key: key);
  @override
  _ChartPerformanceState createState() => _ChartPerformanceState();
}

class _ChartPerformanceState extends State<ChartPerformance> {

  final List<FlSpot> _plots = [];

  double _maxY = 0;
  final _marginY = 1.25;

  final List<Color> gradientColors = [
    const Color(0xff13ff84),
    const Color(0xff13ff84),
  ];

  final List<Color> belowAreaColors = [
    const Color(0xff13ff84).withOpacity(0.2),
    const Color(0xff13ff84).withOpacity(0.4),
  ];

  final Color background = const Color(0xff3b315e);
  final Color accent = const Color(0xff423b5a);

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white60,
      fontWeight: FontWeight.bold,
    );

    String text;
    String prefix = widget.unit == Distance.imperial ? "mi" : "km";

    if (value >= 0) {
      text = "${value.toInt()} $prefix";
    } else {
      return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
  
  _convertMatchHistoryToFlData() {
    _plots.clear();
    double index = 0;
    for (var element in widget.data) {
      double dist = widget.unit == Distance.imperial ?
        (element.bestDistance * DistanceConversion.kmToMi): element.bestDistance;

      _plots.add(FlSpot(index++, dist));

      // Shows a straight line if there's only 1 plot rather than empty graph
      if (widget.data.length == 1) _plots.add(FlSpot(index++, dist));

    }
    if (_plots.isNotEmpty) {
      _maxY = _plots.reduce((value, element) => value.y > element.y ? value : element).y;
      _maxY = (_maxY - (_maxY % 1000)) + 1000;
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
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(18),
          ),
          color: Color(0xff3b315e)
        ),
        child: _plots.isEmpty ? const SizedBox.expand(
          child: Center(
            child: Text(
              'no match data to show here...',
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ),
        ):
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Best guess per match',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    fontSize: 16,
                    color: Colors.white
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 32.0,
                    bottom: 16.0,
                    left: 16.0,
                    right: 8.0
                ),
                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: accent, width: 3)
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Theme.of(context).primaryColor,
                        tooltipRoundedRadius: 8.0,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            var distanceFormatted =
                            widget.unit == Distance.imperial ?
                            barSpot.y.toStringAsFixed(0) + " mi":
                            DistanceConversion.getDistanceAsMetric(barSpot.y, 0);

                            return LineTooltipItem(
                              distanceFormatted,
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            );
                          }).toList();
                        }
                      ),
                    ),

                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: leftTitleWidgets,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: accent,
                          strokeWidth: 3,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: accent,
                          strokeWidth: 3,
                        );
                      },
                    ),
                    minY: -_maxY/8,
                    maxY: _maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _plots,
                        isCurved: true,
                        preventCurveOverShooting: true,
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        barWidth: 5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: belowAreaColors,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
