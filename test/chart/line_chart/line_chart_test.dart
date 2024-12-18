import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_scaffold_widget.dart';
import 'package:fl_chart/src/chart/base/axis_chart/scale_axis.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_data.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_renderer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget({
    required LineChart chart,
  }) {
    return MaterialApp(
      home: chart,
    );
  }

  group('LineChart', () {
    testWidgets('has correct default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chart: LineChart(
            LineChartData(),
          ),
        ),
      );

      final lineChart = tester.widget<LineChart>(find.byType(LineChart));
      expect(lineChart.scaleAxis, FlScaleAxis.none);
      expect(lineChart.trackpadScrollCausesScale, false);
      expect(lineChart.maxScale, 2.5);
      expect(lineChart.minScale, 1);
      expect(lineChart.transformationController, isNull);
    });

    testWidgets('passes interaction parameters to AxisChartScaffoldWidget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chart: LineChart(
            LineChartData(),
          ),
        ),
      );

      final axisChartScaffoldWidget = tester.widget<AxisChartScaffoldWidget>(
        find.byType(AxisChartScaffoldWidget),
      );

      expect(axisChartScaffoldWidget.maxScale, 2.5);
      expect(axisChartScaffoldWidget.minScale, 1);
      expect(axisChartScaffoldWidget.scaleAxis, FlScaleAxis.none);
      expect(axisChartScaffoldWidget.trackpadScrollCausesScale, false);

      await tester.pumpAndSettle();

      final transformationController = TransformationController();
      await tester.pumpWidget(
        createTestWidget(
          chart: LineChart(
            LineChartData(),
            scaleAxis: FlScaleAxis.free,
            trackpadScrollCausesScale: true,
            maxScale: 10,
            minScale: 1.5,
            transformationController: transformationController,
          ),
        ),
      );

      final axisChartScaffoldWidget1 = tester.widget<AxisChartScaffoldWidget>(
        find.byType(AxisChartScaffoldWidget),
      );

      expect(axisChartScaffoldWidget1.maxScale, 10);
      expect(axisChartScaffoldWidget1.minScale, 1.5);
      expect(axisChartScaffoldWidget1.scaleAxis, FlScaleAxis.free);
      expect(axisChartScaffoldWidget1.trackpadScrollCausesScale, true);
      expect(
        axisChartScaffoldWidget1.transformationController,
        transformationController,
      );
    });

    for (final scaleAxis in FlScaleAxis.scalingEnabledAxis) {
      testWidgets('passes canBeScaled true for $scaleAxis',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            chart: LineChart(
              LineChartData(),
              scaleAxis: scaleAxis,
            ),
          ),
        );

        final lineChartLeaf = tester.widget<LineChartLeaf>(
          find.byType(LineChartLeaf),
        );
        expect(lineChartLeaf.canBeScaled, true);
      });
    }

    testWidgets('passes canBeScaled false for FlScaleAxis.none',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          chart: LineChart(
            LineChartData(),
            // ignore: avoid_redundant_argument_values
            scaleAxis: FlScaleAxis.none,
          ),
        ),
      );

      final lineChartLeaf = tester.widget<LineChartLeaf>(
        find.byType(LineChartLeaf),
      );
      expect(lineChartLeaf.canBeScaled, false);
    });

    group('touch gesture', () {
      testWidgets('does not scale with FlScaleAxis.none',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            chart: LineChart(
              LineChartData(),
            ),
          ),
        );

        final lineChartCenterOffset = tester.getCenter(
          find.byType(LineChartLeaf),
        );
        final scaleStart1 = lineChartCenterOffset;
        final scaleStart2 = lineChartCenterOffset;
        final scaleEnd1 = lineChartCenterOffset + const Offset(100, 100);
        final scaleEnd2 = lineChartCenterOffset - const Offset(100, 100);

        final gesture1 = await tester.startGesture(scaleStart1);
        final gesture2 = await tester.startGesture(scaleStart2);
        await tester.pump();
        await gesture1.moveTo(scaleEnd1);
        await gesture2.moveTo(scaleEnd2);
        await tester.pump();
        await gesture1.up();
        await gesture2.up();
        await tester.pumpAndSettle();

        final lineChartLeaf = tester.widget<LineChartLeaf>(
          find.byType(LineChartLeaf),
        );

        expect(lineChartLeaf.chartVirtualRect, isNull);
      });

      testWidgets('scales freely with FlScaleAxis.free',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            chart: LineChart(
              LineChartData(),
              scaleAxis: FlScaleAxis.free,
            ),
          ),
        );

        final lineChartCenterOffset = tester.getCenter(
          find.byType(LineChartLeaf),
        );
        final scaleStart1 = lineChartCenterOffset;
        final scaleStart2 = lineChartCenterOffset;
        final scaleEnd1 = lineChartCenterOffset + const Offset(100, 100);
        final scaleEnd2 = lineChartCenterOffset - const Offset(100, 100);

        final gesture1 = await tester.startGesture(scaleStart1);
        final gesture2 = await tester.startGesture(scaleStart2);
        await tester.pump();
        await gesture1.moveTo(scaleEnd1);
        await gesture2.moveTo(scaleEnd2);
        await tester.pump();
        await gesture1.up();
        await gesture2.up();
        await tester.pumpAndSettle();

        final lineChartLeaf = tester.widget<LineChartLeaf>(
          find.byType(LineChartLeaf),
        );
        final renderBox = tester.renderObject<RenderBox>(
          find.byType(LineChartLeaf),
        );
        final chartVirtualRect = lineChartLeaf.chartVirtualRect!;

        expect(chartVirtualRect.size, greaterThan(renderBox.size));
        expect(chartVirtualRect.left, isNegative);
        expect(chartVirtualRect.top, isNegative);
      });

      testWidgets('scales horizontally with FlScaleAxis.horizontal',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            chart: LineChart(
              LineChartData(),
              scaleAxis: FlScaleAxis.horizontal,
            ),
          ),
        );

        final chartCenterOffset = tester.getCenter(find.byType(LineChartLeaf));
        final scaleStart1 = chartCenterOffset;
        final scaleStart2 = chartCenterOffset;
        final scaleEnd1 = chartCenterOffset + const Offset(100, 100);
        final scaleEnd2 = chartCenterOffset - const Offset(100, 100);

        final gesture1 = await tester.startGesture(scaleStart1);
        final gesture2 = await tester.startGesture(scaleStart2);
        await tester.pump();
        await gesture1.moveTo(scaleEnd1);
        await gesture2.moveTo(scaleEnd2);
        await tester.pump();
        await gesture1.up();
        await gesture2.up();
        await tester.pumpAndSettle();

        final lineChartLeaf = tester.widget<LineChartLeaf>(
          find.byType(LineChartLeaf),
        );
        final renderBox = tester.renderObject<RenderBox>(
          find.byType(LineChartLeaf),
        );
        final chartVirtualRect = lineChartLeaf.chartVirtualRect!;

        expect(chartVirtualRect.size.height, renderBox.size.height);
        expect(chartVirtualRect.size.width, greaterThan(renderBox.size.width));
        expect(chartVirtualRect.left, isNegative);
        expect(chartVirtualRect.top, 0);
      });

      testWidgets('scales vertically with FlScaleAxis.vertical',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            chart: LineChart(
              LineChartData(),
              scaleAxis: FlScaleAxis.vertical,
            ),
          ),
        );

        final chartCenterOffset = tester.getCenter(find.byType(LineChartLeaf));
        final scaleStart1 = chartCenterOffset;
        final scaleStart2 = chartCenterOffset;
        final scaleEnd1 = chartCenterOffset + const Offset(100, 100);
        final scaleEnd2 = chartCenterOffset - const Offset(100, 100);

        final gesture1 = await tester.startGesture(scaleStart1);
        final gesture2 = await tester.startGesture(scaleStart2);
        await tester.pump();
        await gesture1.moveTo(scaleEnd1);
        await gesture2.moveTo(scaleEnd2);
        await tester.pump();
        await gesture1.up();
        await gesture2.up();
        await tester.pumpAndSettle();

        final lineChartLeaf = tester.widget<LineChartLeaf>(
          find.byType(LineChartLeaf),
        );
        final renderBox = tester.renderObject<RenderBox>(
          find.byType(LineChartLeaf),
        );
        final chartVirtualRect = lineChartLeaf.chartVirtualRect!;

        expect(
          chartVirtualRect.size.height,
          greaterThan(renderBox.size.height),
        );
        expect(chartVirtualRect.size.width, renderBox.size.width);
        expect(chartVirtualRect.left, 0);
        expect(chartVirtualRect.top, isNegative);
      });

      group('pans', () {
        testWidgets('only horizontally with FlScaleAxis.horizontal',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            createTestWidget(
              chart: LineChart(
                LineChartData(),
                scaleAxis: FlScaleAxis.horizontal,
              ),
            ),
          );

          final chartCenterOffset = tester.getCenter(
            find.byType(LineChartLeaf),
          );
          final scaleStart1 = chartCenterOffset;
          final scaleStart2 = chartCenterOffset;
          final scaleEnd1 = chartCenterOffset + const Offset(100, 100);
          final scaleEnd2 = chartCenterOffset - const Offset(100, 100);

          final gesture1 = await tester.startGesture(scaleStart1);
          final gesture2 = await tester.startGesture(scaleStart2);
          await gesture1.moveTo(scaleEnd1);
          await gesture2.moveTo(scaleEnd2);
          await gesture1.up();
          await gesture2.up();
          await tester.pumpAndSettle();

          final lineChartLeafBeforePan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );
          final chartVirtualRectBeforePan =
              lineChartLeafBeforePan.chartVirtualRect!;
          expect(chartVirtualRectBeforePan.top, 0);

          const panOffset = Offset(100, 100);
          await tester.dragFrom(chartCenterOffset, panOffset);
          await tester.pumpAndSettle();

          final lineChartLeafAfterPan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );
          final chartVirtualRectAfterPan =
              lineChartLeafAfterPan.chartVirtualRect!;

          expect(chartVirtualRectBeforePan.size, chartVirtualRectAfterPan.size);
          expect(
            chartVirtualRectAfterPan.left,
            greaterThan(chartVirtualRectBeforePan.left),
          );
          expect(chartVirtualRectAfterPan.top, 0);
        });

        testWidgets('only vertically with FlScaleAxis.vertical',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            createTestWidget(
              chart: LineChart(
                LineChartData(),
                scaleAxis: FlScaleAxis.vertical,
              ),
            ),
          );

          final chartCenterOffset = tester.getCenter(
            find.byType(LineChartLeaf),
          );
          final scaleStart1 = chartCenterOffset;
          final scaleStart2 = chartCenterOffset;
          final scaleEnd1 = chartCenterOffset + const Offset(100, 100);
          final scaleEnd2 = chartCenterOffset - const Offset(100, 100);

          final gesture1 = await tester.startGesture(scaleStart1);
          final gesture2 = await tester.startGesture(scaleStart2);
          await gesture1.moveTo(scaleEnd1);
          await gesture2.moveTo(scaleEnd2);
          await gesture1.up();
          await gesture2.up();
          await tester.pumpAndSettle();

          final lineChartLeafBeforePan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );
          final chartVirtualRectBeforePan =
              lineChartLeafBeforePan.chartVirtualRect!;
          expect(chartVirtualRectBeforePan.left, 0);

          const panOffset = Offset(100, 100);
          await tester.dragFrom(chartCenterOffset, panOffset);
          await tester.pumpAndSettle();

          final lineChartLeafAfterPan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );
          final chartVirtualRectAfterPan =
              lineChartLeafAfterPan.chartVirtualRect!;

          expect(chartVirtualRectAfterPan.left, 0);
          expect(
            chartVirtualRectAfterPan.top,
            greaterThan(chartVirtualRectBeforePan.top),
          );
        });

        testWidgets('freely with FlScaleAxis.free',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            createTestWidget(
              chart: LineChart(
                LineChartData(),
                scaleAxis: FlScaleAxis.free,
              ),
            ),
          );

          final chartCenterOffset = tester.getCenter(
            find.byType(LineChartLeaf),
          );
          final scaleStart1 = chartCenterOffset;
          final scaleStart2 = chartCenterOffset;
          final scaleEnd1 = chartCenterOffset + const Offset(100, 100);
          final scaleEnd2 = chartCenterOffset - const Offset(100, 100);

          final gesture1 = await tester.startGesture(scaleStart1);
          final gesture2 = await tester.startGesture(scaleStart2);
          await gesture1.moveTo(scaleEnd1);
          await gesture2.moveTo(scaleEnd2);
          await gesture1.up();
          await gesture2.up();
          await tester.pumpAndSettle();

          final lineChartLeafBeforePan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );
          final chartVirtualRectBeforePan =
              lineChartLeafBeforePan.chartVirtualRect!;
          expect(chartVirtualRectBeforePan.left, isNegative);
          expect(chartVirtualRectBeforePan.top, isNegative);

          const panOffset = Offset(100, 100);
          await tester.dragFrom(chartCenterOffset, panOffset);
          await tester.pumpAndSettle();

          final lineChartLeafAfterPan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );
          final chartVirtualRectAfterPan =
              lineChartLeafAfterPan.chartVirtualRect!;

          expect(
            chartVirtualRectAfterPan.left,
            greaterThan(chartVirtualRectBeforePan.left),
          );
          expect(
            chartVirtualRectAfterPan.top,
            greaterThan(chartVirtualRectBeforePan.top),
          );
        });
      });
    });

    group('trackpad scroll', () {
      group('pans', () {
        testWidgets('only horizontally with FlScaleAxis.horizontal',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            createTestWidget(
              chart: LineChart(
                LineChartData(),
                scaleAxis: FlScaleAxis.horizontal,
              ),
            ),
          );

          final chartCenterOffset = tester.getCenter(
            find.byType(LineChartLeaf),
          );
          final scaleStart1 = chartCenterOffset;
          final scaleStart2 = chartCenterOffset;
          final scaleEnd1 = chartCenterOffset + const Offset(100, 100);
          final scaleEnd2 = chartCenterOffset - const Offset(100, 100);

          final gesture1 = await tester.startGesture(scaleStart1);
          final gesture2 = await tester.startGesture(scaleStart2);
          await tester.pump();
          await gesture1.moveTo(scaleEnd1);
          await gesture2.moveTo(scaleEnd2);
          await tester.pump();
          await gesture1.up();
          await gesture2.up();
          await tester.pumpAndSettle();

          final lineChartLeafBeforePan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );

          final chartVirtualRectBeforePan =
              lineChartLeafBeforePan.chartVirtualRect!;
          expect(chartVirtualRectBeforePan.top, 0);

          final pointer = TestPointer(1, PointerDeviceKind.trackpad);
          const leftAndUp = Offset(-100, -100);
          await tester.sendEventToBinding(pointer.hover(chartCenterOffset));
          await tester.pump();
          await tester.sendEventToBinding(pointer.scroll(leftAndUp));
          await tester.pump();

          final lineChartLeafAfterPan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );
          final chartVirtualRectAfterPan =
              lineChartLeafAfterPan.chartVirtualRect!;

          expect(
            chartVirtualRectAfterPan.left,
            greaterThan(chartVirtualRectBeforePan.left),
          );
          expect(chartVirtualRectAfterPan.top, 0);
        });

        testWidgets('vertically with FlScaleAxis.vertical',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            createTestWidget(
              chart: LineChart(
                LineChartData(),
                scaleAxis: FlScaleAxis.vertical,
              ),
            ),
          );

          final chartCenterOffset = tester.getCenter(
            find.byType(LineChartLeaf),
          );
          final scaleStart1 = chartCenterOffset;
          final scaleStart2 = chartCenterOffset;
          final scaleEnd1 = chartCenterOffset + const Offset(100, 100);
          final scaleEnd2 = chartCenterOffset - const Offset(100, 100);

          final gesture1 = await tester.startGesture(scaleStart1);
          final gesture2 = await tester.startGesture(scaleStart2);
          await tester.pump();
          await gesture1.moveTo(scaleEnd1);
          await gesture2.moveTo(scaleEnd2);
          await tester.pump();
          await gesture1.up();
          await gesture2.up();
          await tester.pumpAndSettle();

          final lineChartLeafBeforePan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );

          final chartVirtualRectBeforePan =
              lineChartLeafBeforePan.chartVirtualRect!;
          expect(chartVirtualRectBeforePan.left, 0);

          final pointer = TestPointer(1, PointerDeviceKind.trackpad);
          const leftAndUp = Offset(-100, -100);
          await tester.sendEventToBinding(pointer.hover(chartCenterOffset));
          await tester.pump();
          await tester.sendEventToBinding(pointer.scroll(leftAndUp));
          await tester.pump();

          final lineChartLeafAfterPan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );
          final chartVirtualRectAfterPan =
              lineChartLeafAfterPan.chartVirtualRect!;

          expect(chartVirtualRectAfterPan.left, 0);
          expect(
            chartVirtualRectAfterPan.top,
            greaterThan(chartVirtualRectBeforePan.top),
          );
        });

        testWidgets('freely with FlScaleAxis.free',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            createTestWidget(
              chart: LineChart(
                LineChartData(),
                scaleAxis: FlScaleAxis.free,
              ),
            ),
          );

          final chartCenterOffset = tester.getCenter(
            find.byType(LineChartLeaf),
          );
          final scaleStart1 = chartCenterOffset;
          final scaleStart2 = chartCenterOffset;
          final scaleEnd1 = chartCenterOffset + const Offset(100, 100);
          final scaleEnd2 = chartCenterOffset - const Offset(100, 100);

          final gesture1 = await tester.startGesture(scaleStart1);
          final gesture2 = await tester.startGesture(scaleStart2);
          await tester.pump();
          await gesture1.moveTo(scaleEnd1);
          await gesture2.moveTo(scaleEnd2);
          await tester.pump();
          await gesture1.up();
          await gesture2.up();
          await tester.pumpAndSettle();

          final lineChartLeafBeforePan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );

          final chartVirtualRectBeforePan =
              lineChartLeafBeforePan.chartVirtualRect!;

          final pointer = TestPointer(1, PointerDeviceKind.trackpad);
          const leftAndUp = Offset(-100, -100);
          await tester.sendEventToBinding(pointer.hover(chartCenterOffset));
          await tester.pump();
          await tester.sendEventToBinding(pointer.scroll(leftAndUp));
          await tester.pump();

          final lineChartLeafAfterPan = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );
          final chartVirtualRectAfterPan =
              lineChartLeafAfterPan.chartVirtualRect!;

          expect(
            chartVirtualRectAfterPan.left,
            greaterThan(chartVirtualRectBeforePan.left),
          );
          expect(
            chartVirtualRectAfterPan.top,
            greaterThan(chartVirtualRectBeforePan.top),
          );
        });
      });

      testWidgets(
        'does not scale with FlScaleAxis.none when '
        'trackpadScrollCausesScale is true',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            createTestWidget(
              chart: LineChart(
                LineChartData(),
                // ignore: avoid_redundant_argument_values
                scaleAxis: FlScaleAxis.none,
                trackpadScrollCausesScale: true,
              ),
            ),
          );

          final pointer = TestPointer(1, PointerDeviceKind.trackpad);
          final chartCenterOffset = tester.getCenter(
            find.byType(LineChartLeaf),
          );
          const scrollAmount = Offset(0, -100);

          await tester.sendEventToBinding(pointer.hover(chartCenterOffset));
          await tester.pump();
          await tester.sendEventToBinding(pointer.scroll(scrollAmount));
          await tester.pump();

          final lineChartLeaf = tester.widget<LineChartLeaf>(
            find.byType(LineChartLeaf),
          );
          expect(lineChartLeaf.chartVirtualRect, null);
        },
      );

      for (final scaleAxis in FlScaleAxis.scalingEnabledAxis) {
        testWidgets(
          'does not scale when trackpadScrollCausesScale is false '
          'for $scaleAxis',
          (WidgetTester tester) async {
            await tester.pumpWidget(
              createTestWidget(
                chart: LineChart(
                  LineChartData(),
                  scaleAxis: scaleAxis,
                  // ignore: avoid_redundant_argument_values
                  trackpadScrollCausesScale: false,
                ),
              ),
            );

            final pointer = TestPointer(1, PointerDeviceKind.trackpad);
            final chartCenterOffset = tester.getCenter(
              find.byType(LineChartLeaf),
            );
            const scrollAmount = Offset(0, -100);

            await tester.sendEventToBinding(pointer.hover(chartCenterOffset));
            await tester.pump();
            await tester.sendEventToBinding(pointer.scroll(scrollAmount));
            await tester.pump();

            final lineChartLeaf = tester.widget<LineChartLeaf>(
              find.byType(LineChartLeaf),
            );
            expect(lineChartLeaf.chartVirtualRect, null);
          },
        );
      }

      testWidgets('scales horizontally with FlScaleAxis.horizontal',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            chart: LineChart(
              LineChartData(),
              scaleAxis: FlScaleAxis.horizontal,
              trackpadScrollCausesScale: true,
            ),
          ),
        );

        final pointer = TestPointer(1, PointerDeviceKind.trackpad);
        final chartCenterOffset = tester.getCenter(find.byType(LineChartLeaf));
        const scrollAmount = Offset(0, -100);

        await tester.sendEventToBinding(pointer.hover(chartCenterOffset));
        await tester.pump();
        await tester.sendEventToBinding(pointer.scroll(scrollAmount));
        await tester.pump();

        final lineChartLeaf = tester.widget<LineChartLeaf>(
          find.byType(LineChartLeaf),
        );
        final renderBox = tester.renderObject<RenderBox>(
          find.byType(LineChartLeaf),
        );
        final chartVirtualRect = lineChartLeaf.chartVirtualRect!;

        expect(chartVirtualRect.size.height, renderBox.size.height);
        expect(chartVirtualRect.size.width, greaterThan(renderBox.size.width));
        expect(chartVirtualRect.left, isNegative);
        expect(chartVirtualRect.top, 0);
      });

      testWidgets('scales vertically with FlScaleAxis.vertical',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            chart: LineChart(
              LineChartData(),
              scaleAxis: FlScaleAxis.vertical,
              trackpadScrollCausesScale: true,
            ),
          ),
        );

        final pointer = TestPointer(1, PointerDeviceKind.trackpad);
        final chartCenterOffset = tester.getCenter(find.byType(LineChartLeaf));
        const scrollAmount = Offset(0, -100);

        await tester.sendEventToBinding(pointer.hover(chartCenterOffset));
        await tester.pump();
        await tester.sendEventToBinding(pointer.scroll(scrollAmount));
        await tester.pump();

        final lineChartLeaf = tester.widget<LineChartLeaf>(
          find.byType(LineChartLeaf),
        );
        final renderBox = tester.renderObject<RenderBox>(
          find.byType(LineChartLeaf),
        );
        final chartVirtualRect = lineChartLeaf.chartVirtualRect!;

        expect(
          chartVirtualRect.size.height,
          greaterThan(renderBox.size.height),
        );
        expect(chartVirtualRect.size.width, renderBox.size.width);
        expect(chartVirtualRect.left, 0);
        expect(chartVirtualRect.top, isNegative);
      });

      testWidgets('scales freely with FlScaleAxis.free',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            chart: LineChart(
              LineChartData(),
              scaleAxis: FlScaleAxis.free,
              trackpadScrollCausesScale: true,
            ),
          ),
        );

        final pointer = TestPointer(1, PointerDeviceKind.trackpad);
        final chartCenterOffset = tester.getCenter(find.byType(LineChartLeaf));
        const scrollAmount = Offset(0, -100);

        await tester.sendEventToBinding(pointer.hover(chartCenterOffset));
        await tester.pump();
        await tester.sendEventToBinding(pointer.scroll(scrollAmount));
        await tester.pump();

        final lineChartLeaf =
            tester.widget<LineChartLeaf>(find.byType(LineChartLeaf));
        final renderBox = tester.renderObject<RenderBox>(
          find.byType(LineChartLeaf),
        );
        final chartVirtualRect = lineChartLeaf.chartVirtualRect!;

        expect(chartVirtualRect.size, greaterThan(renderBox.size));
        expect(chartVirtualRect.left, isNegative);
        expect(chartVirtualRect.top, isNegative);
      });
    });
  });
}
