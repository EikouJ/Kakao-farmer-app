import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kakao_farmer/widgets/line_chart_widget.dart';
//import 'package:fl_chart/fl_chart.dart';

class StatisticsScreenTab extends StatefulWidget {
  const StatisticsScreenTab({super.key});

  @override
  State<StatisticsScreenTab> createState() => _StatisticsScreenTabState();
}

class _StatisticsScreenTabState extends State<StatisticsScreenTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LineChartWidget(isShowingMainData: true));
  }
}
