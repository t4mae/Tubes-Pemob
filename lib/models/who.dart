class WhoData {
  final int month;
  final String gender; // L / P
  final double l;
  final double m;
  final double s;
  final double sd3neg;
  final double sd2neg;
  final double sd1neg;
  final double sd0;
  final double sd1;
  final double sd2;
  final double sd3;

  WhoData({
    required this.month,
    required this.gender,
    required this.l,
    required this.m,
    required this.s,
    required this.sd3neg,
    required this.sd2neg,
    required this.sd1neg,
    required this.sd0,
    required this.sd1,
    required this.sd2,
    required this.sd3,
  });

  factory WhoData.fromJson(Map<String, dynamic> rawJson, String gender) {
    // Create a normalized map with trimmed keys to handle "M       " etc.
    final json = rawJson.map((key, value) => MapEntry(key.trim(), value));

    double parseNum(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return WhoData(
      month: json['Month'] ?? 0,
      gender: gender,
      l: parseNum(json['L']),
      m: parseNum(json['M']),
      s: parseNum(json['S']),
      sd3neg: parseNum(json['SD3neg']),
      sd2neg: parseNum(json['SD2neg']),
      sd1neg: parseNum(json['SD1neg']),
      sd0: parseNum(json['SD0']),
      sd1: parseNum(json['SD1']),
      sd2: parseNum(json['SD2']),
      sd3: parseNum(json['SD3']),
    );
  }
}
