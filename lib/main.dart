import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:radar_chart_plus/radar_chart_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar Chart Plus',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C63FF),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C63FF),
        brightness: Brightness.dark,
      ),
      home: DemoPage(
        isDark: _isDark,
        onToggleTheme: () => setState(() => _isDark = !_isDark),
      ),
    );
  }
}

// ─── label & color pools ───────────────────────────────────────────────────

const _labels = [
  'AAAA',
  'BBBB',
  'CCCC',
  'DDDD',
  'EEEE',
  'FFFF',
  'GGGG',
  'HHHH',
  'IIII',
  'JJJJ',
  'KKKK',
  'LLLL',
];

const _seriesColors = [
  Color(0xFF6C63FF),
  Color(0xFFFF6B9D),
  Color(0xFF43E8A0),
  Color(0xFFFFA94D),
  Color(0xFF4DBFFF),
];

List<double> makeData(int count, int seed) {
  final r = Random(seed);
  return List.generate(count, (_) {
    double value = r.nextDouble() * (10 - 1) + 1;
    return double.parse(value.toStringAsFixed(2));
  });
}

// ─── Demo Page ─────────────────────────────────────────────────────────────

class DemoPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const DemoPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  double _axes = 6;
  double _series = 2;
  bool _horizontalLabels = false;

  bool enableOntap = true;

  bool textBold = false;
  FontWeight fontWeight = FontWeight.normal;

  Color selectedLablelColor = Colors.white;
  Color selected = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final axesCount = _axes.round();
    final seriesCount = _series.round();

    final labels = _labels.take(axesCount).toList();
    final dataSets = List.generate(seriesCount, (i) {
      final c = _seriesColors[i % _seriesColors.length];
      return RadarDataSet(
        label: 'S${i + 1}',
        data: makeData(axesCount, i + 1),
        borderColor: c,
        fillColor: c.withValues(alpha: 0.2),
        dotColor: c,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Radar Chart Plus',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          // IconButton(
          //   tooltip: widget.isDark ? 'Light mode' : 'Dark mode',
          //   onPressed: widget.onToggleTheme,
          //   icon: Icon(
          //     widget.isDark
          //         ? Icons.light_mode_rounded
          //         : Icons.dark_mode_rounded,
          //   ),
          // ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Chart ──────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: RadarChartPlus(
                  key: ValueKey('$axesCount-$seriesCount'),
                  ticks: const [2, 4, 6, 8, 10],
                  labels: labels,
                  dataSets: dataSets,
                  dotTapEnabled: enableOntap,
                  tooltipStyle: const RadarTooltipStyle(),
                  horizontalLabels: _horizontalLabels,
                  maxWordsPerLine: 1,
                  labelSpacing: 4,
                  labelTextStyle: TextStyle(
                    color: selectedLablelColor,
                    fontSize: 11,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            ),

            // ── Controls ───────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                border: Border(
                  top: BorderSide(color: cs.outlineVariant, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SliderRow(
                    label: 'Axes',
                    value: _axes,
                    min: 3,
                    max: 12,
                    divisions: 9,
                    onChanged: (v) => setState(() => _axes = v),
                    color: _seriesColors[0],
                  ),
                  const SizedBox(height: 16),
                  _SliderRow(
                    label: 'Series',
                    value: _series,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (v) => setState(() => _series = v),
                    color: _seriesColors[1],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    spacing: 10,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              'Horizontal Labels',
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Switch(
                            value: _horizontalLabels,
                            onChanged: (v) =>
                                setState(() => _horizontalLabels = v),
                            activeColor: _seriesColors[2],
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () async {
                              final pickedColor = await openColorPicker(
                                context,
                                selectedLablelColor,
                              );

                              if (pickedColor != null) {
                                setState(() {
                                  selectedLablelColor = pickedColor;
                                });
                              }
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                border: BoxBorder.all(color: Colors.white70),
                                color: selectedLablelColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                fontWeight = fontWeight == FontWeight.bold
                                    ? FontWeight.normal
                                    : FontWeight.bold;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.format_bold,
                                color: selectedLablelColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              'Enable OnTap',
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Switch(
                            value: enableOntap,
                            onChanged: (v) => setState(() => enableOntap = v),
                            activeColor: _seriesColors[2],
                          ),
                          Spacer(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Color?> openColorPicker(
    BuildContext context,
    Color initialColor,
  ) async {
    Color selectedColor = initialColor;

    return await showDialog<Color>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Pick a Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: (color) {
              selectedColor = color; // ❌ no setState needed here
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Done"),
            onPressed: () {
              Navigator.pop(context, selectedColor); // ✅ return color
            },
          ),
        ],
      ),
    );
  }
}

// ─── Slider row component ──────────────────────────────────────────────────

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final Color color;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.12),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              min: min,
              max: max,
              divisions: divisions,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 24,
          child: Text(
            '${value.round()}',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
