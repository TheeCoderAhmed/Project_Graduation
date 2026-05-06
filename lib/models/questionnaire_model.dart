

class QuestionnaireModel {
  final double waitingTime;
  final double serviceQuality;
  final double hygiene;
  final double staffCommunication;

  QuestionnaireModel({
    required this.waitingTime,
    required this.serviceQuality,
    required this.hygiene,
    required this.staffCommunication,
  });

  factory QuestionnaireModel.fromMap(Map<String, dynamic> map) {
    double parseSafely(dynamic value) {
      if (value is num) {
        return value.toDouble().clamp(0.0, 5.0);
      }
      return 0.0;
    }

    return QuestionnaireModel(
      waitingTime: parseSafely(map['waitingTime']),
      serviceQuality: parseSafely(map['serviceQuality']),
      hygiene: parseSafely(map['hygiene']),
      staffCommunication: parseSafely(map['staffCommunication']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'waitingTime': waitingTime,
      'serviceQuality': serviceQuality,
      'hygiene': hygiene,
      'staffCommunication': staffCommunication,
    };
  }
}
