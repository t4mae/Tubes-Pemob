import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/growth.dart';
import '../models/who.dart';

class GrowthCharts extends StatelessWidget {
  final List<Growth> growths;
  final List<WhoData> whoWeight;
  final List<WhoData> whoHeight;
  final List<WhoData> whoHead;
  final int index;
  final String childName;
  final DateTime birthDate;

  const GrowthCharts({
    super.key,
    required this.index,
    required this.growths,
    required this.whoWeight,
    required this.whoHeight,
    required this.whoHead,
    required this.childName,
    required this.birthDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        [
          _buildSingleChart("Berat Badan (kg)", growths, whoWeight, "weight"),
          _buildSingleChart("Panjang Badan (cm)", growths, whoHeight, "height"),
          _buildSingleChart("Lingkar Kepala (cm)", growths, whoHead, "head"),
        ][index],
        const SizedBox(height: 16),
        _buildLegend(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem("Data Anak", Colors.green.shade600),
        const SizedBox(width: 20),
        _legendItem("Standar WHO", Colors.red.shade400),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSingleChart(
    String title,
    List<Growth> growths,
    List<WhoData> whoData,
    String type,
  ) {
    final sortedGrowth = [...growths]..sort((a, b) => a.date.compareTo(b.date));

    String statusMessage = "";
    Color statusColor = Colors.black87;

    if (sortedGrowth.isNotEmpty && whoData.isNotEmpty) {
      final latest = sortedGrowth.last;
      // Calculate age in months at time of measurement
      int ageInMonths = ((latest.date.year - birthDate.year) * 12 + latest.date.month - birthDate.month);
      ageInMonths = ageInMonths.clamp(0, 60);

      final who = whoData.firstWhere((w) => w.month == ageInMonths, orElse: () => whoData.last);
      final median = who.m;

      double val = 0;
      double diff = 0;
      String label = "";

      switch (type) {
        case "weight":
          val = latest.weight;
          diff = 3.0;
          label = "Berat Badan";
          break;
        case "height":
          val = latest.height;
          diff = 6.0;
          label = "Tinggi Badan";
          break;
        case "head":
          val = latest.headCirc;
          diff = 2.5;
          label = "Lingkar Kepala";
          break;
      }

      final low = median - diff;
      final high = median + diff;

      if (val < low) {
        statusMessage = "$label \"$childName\" adalah di bawah normal.";
        statusColor = Colors.red.shade700;
      } else if (val > high) {
        statusMessage = "$label \"$childName\" adalah di atas normal.";
        statusColor = Colors.orange.shade800;
      } else {
        statusMessage = "$label \"$childName\" adalah Normal.";
        statusColor = Colors.green.shade700;
      }
    }

    final List<FlSpot> growthSpots = [];
    final List<FlSpot> whoSpots = [];

    double maxY = 0;

    for (int i = 0; i < 60; i++) {
      final who = i < whoData.length ? whoData[i] : whoData.last;
      double w = 0;
      switch (type) {
        case "weight": w = who.m; break;
        case "height": w = who.m; break;
        case "head": w = who.m; break;
      }
      whoSpots.add(FlSpot((i + 1).toDouble(), w));
      maxY = maxY > w ? maxY : w;
    }

    for (int i = 0; i < sortedGrowth.length; i++) {
      final growth = sortedGrowth[i];
      double g = 0;
      switch (type) {
        case "weight": g = growth.weight; break;
        case "height": g = growth.height; break;
        case "head": g = growth.headCirc; break;
      }
      growthSpots.add(FlSpot((i + 1).toDouble(), g));
      maxY = maxY > g ? maxY : g;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (statusMessage.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              statusMessage,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          height: 300,
          padding: const EdgeInsets.only(right: 20, top: 16, left: 10, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: LineChart(
            LineChartData(
              minX: 1,
              maxX: 60,
              minY: 0,
              maxY: maxY + 5,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.blueAccent.withOpacity(0.8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isChild = spot.barIndex == 0;
                      return LineTooltipItem(
                        "${isChild ? 'Anak' : 'WHO'}: ${spot.y.toStringAsFixed(1)}",
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: type == "weight" ? 5 : 10,
                verticalInterval: 12,
                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) =>
                        Text(value.toInt().toString(), style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 12,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      if (value < 1 || value > 60) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'B${value.toInt()}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: growthSpots,
                  isCurved: true,
                  color: Colors.green.shade600,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: Colors.green.shade600,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.shade600.withOpacity(0.1),
                  ),
                ),
                LineChartBarData(
                  spots: whoSpots,
                  isCurved: true,
                  color: Colors.red.shade400,
                  barWidth: 2,
                  dashArray: [5, 5],
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
