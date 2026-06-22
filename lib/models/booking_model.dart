import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String courtId;
  final String courtName;
  final DateTime date;
  final String timeSlot;
  final String status;

  BookingModel({
    required this.id,
    required this.userId,
    required this.courtId,
    required this.courtName,
    required this.date,
    required this.timeSlot,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courtId': courtId,
      'courtName': courtName,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'status': status,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      courtId: map['courtId'] ?? '',
      courtName: map['courtName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      timeSlot: map['timeSlot'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }
}
