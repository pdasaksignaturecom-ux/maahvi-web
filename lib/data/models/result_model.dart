class ResultModel {
  final String id;
  final String stateId;
  final String stateName;
  final String date;
  final String drawTime;
  final String drawName;
  final Map<String, List<String>> winningNumbers;
  final String? pdfUrl;
  final String? imageUrl;

  ResultModel({
    required this.id,
    required this.stateId,
    required this.stateName,
    required this.date,
    required this.drawTime,
    required this.drawName,
    required this.winningNumbers,
    this.pdfUrl,
    this.imageUrl,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    var winningData = json['winningNumbers'] as Map<String, dynamic>? ?? {};
    Map<String, List<String>> parsedWinningNumbers = {};

    winningData.forEach((key, value) {
      if (value is List) {
        parsedWinningNumbers[key] = List<String>.from(value);
      }
    });

    return ResultModel(
      id: json['_id'] ?? '',
      // stateId না থাকলে stateName ব্যবহারের ব্যাকআপ ব্যবস্থা
      stateId:
          json['stateId']?.toString() ?? json['stateName']?.toString() ?? '',
      stateName: json['stateName']?.toString() ?? '',
      date: json['date'] ?? '',
      drawTime: json['drawTime'] ?? '',
      drawName: json['drawName'] ?? '',
      winningNumbers: parsedWinningNumbers,
      pdfUrl: json['pdfUrl'],
      imageUrl: json['imageUrl'],
    );
  }
}
