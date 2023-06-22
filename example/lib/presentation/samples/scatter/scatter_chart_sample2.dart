import 'package:fl_chart_app/presentation/resources/app_resources.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScatterChartSample2 extends StatefulWidget {
  const ScatterChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => _ScatterChartSample2State();
}

class _ScatterChartSample2State extends State {
  int touchedIndex = -1;

  Color greyColor = Colors.grey;

  List<int> selectedSpots = [];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ScatterChart(
        ScatterChartData(
          scatterSpots: [
            ScatterSpot(
              4,
              4,
              color: selectedSpots.contains(0)
                  ? AppColors.contentColorGreen
                  : AppColors.contentColorWhite.withOpacity(0.5),
            ),
            ScatterSpot(
              2,
              5,
              color: selectedSpots.contains(1)
                  ? AppColors.contentColorYellow
                  : AppColors.contentColorWhite.withOpacity(0.5),
              radius: 12,
            ),
            ScatterSpot(
              4,
              5,
              color: selectedSpots.contains(2)
                  ? AppColors.contentColorPink
                  : AppColors.contentColorWhite.withOpacity(0.5),
              radius: 8,
            ),
            ScatterSpot(
              8,
              6,
              color: selectedSpots.contains(3)
                  ? AppColors.contentColorOrange
                  : AppColors.contentColorWhite.withOpacity(0.5),
              radius: 20,
            ),
            ScatterSpot(
              5,
              7,
              color: selectedSpots.contains(4)
                  ? AppColors.contentColorPurple
                  : AppColors.contentColorWhite.withOpacity(0.5),
              radius: 14,
            ),
            ScatterSpot(
              7,
              2,
              color: selectedSpots.contains(5)
                  ? AppColors.contentColorBlue
                  : AppColors.contentColorWhite.withOpacity(0.5),
              radius: 18,
            ),
            ScatterSpot(
              3,
              2,
              color: selectedSpots.contains(6)
                  ? AppColors.contentColorRed
                  : AppColors.contentColorWhite.withOpacity(0.5),
              radius: 36,
            ),
            ScatterSpot(
              2,
              8,
              color: selectedSpots.contains(7)
                  ? AppColors.contentColorCyan
                  : AppColors.contentColorWhite.withOpacity(0.5),
              radius: 22,
            ),
          ],
          minX: 0,
          maxX: 10,
          minY: 0,
          maxY: 10,
          borderData: FlBorderData(
            show: false,
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            checkToShowHorizontalLine: (value) => true,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AppColors.gridLinesColor,
            ),
            drawVerticalLine: true,
            checkToShowVerticalLine: (value) => true,
            getDrawingVerticalLine: (value) => const FlLine(
              color: AppColors.gridLinesColor,
            ),
          ),
          titlesData: const FlTitlesData(
            show: false,
          ),
          showingTooltipIndicators: selectedSpots,
          scatterTouchData: ScatterTouchData(
            enabled: true,
            handleBuiltInTouches: false,
            mouseCursorResolver:
                (FlTouchEvent touchEvent, ScatterTouchResponse? response) {
              return response == null || response.touchedSpot == null
                  ? MouseCursor.defer
                  : SystemMouseCursors.click;
            },
            touchTooltipData: ScatterTouchTooltipData(
<<<<<<< HEAD
=======
              //   tooltipBgColor: Colors.black,
>>>>>>> f501b62a (feat: Remove old property called tooltipBgColor for Bar,Line and Scatter Charts, Added new method called getTooltipColor for which user can provide their own custom implementation to change backgroud color for each tooltip of given chart, Updated sample charts, Updated test cases, Updated bar_chart.md,line_chart.md and scatter_chart.md files for the brief description about new method, Updated version code in pubspec)
              getTooltipColor: (ScatterSpot touchedBarSpot) {
                Color bgColor = switch ((
                  touchedBarSpot.x.toInt(),
                  touchedBarSpot.y.toInt()
                )) {
                  (4, 4) => AppColors.contentColorPurple.withAlpha(100),
                  (2, 5) => AppColors.contentColorYellow.withAlpha(100),
                  (4, 5) => AppColors.contentColorBlue.withAlpha(100),
                  (8, 6) => AppColors.contentColorOrange.withAlpha(100),
                  (5, 7) => AppColors.contentColorPink.withAlpha(100),
                  (7, 2) => AppColors.contentColorRed.withAlpha(100),
                  (3, 2) => AppColors.contentColorPurple.withAlpha(150),
                  (2, 8) => AppColors.contentColorYellow.withAlpha(100),
                  _ => throw Error(),
                };
                return bgColor;
              },
              getTooltipItems: (ScatterSpot touchedBarSpot) {
                return ScatterTooltipItem(
                  'X: ',
                  textStyle: TextStyle(
                    height: 1.2,
                    color: Colors.grey[100],
                    fontStyle: FontStyle.italic,
                  ),
                  bottomMargin: 10,
                  children: [
                    TextSpan(
                      text: '${touchedBarSpot.x.toInt()} \n',
                      style: const TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Y: ',
                      style: TextStyle(
                        height: 1.2,
                        color: Colors.grey[100],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: touchedBarSpot.y.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
            touchCallback:
                (FlTouchEvent event, ScatterTouchResponse? touchResponse) {
              if (touchResponse == null || touchResponse.touchedSpot == null) {
                return;
              }
              if (event is FlTapUpEvent) {
                final sectionIndex = touchResponse.touchedSpot!.spotIndex;
                setState(() {
                  if (selectedSpots.contains(sectionIndex)) {
                    selectedSpots.remove(sectionIndex);
                  } else {
                    selectedSpots.add(sectionIndex);
                  }
                });
              }
            },
          ),
        ),
      ),
    );
  }
}
