import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String courtId;
  final String courtName;
  final DateTime date;
  final String timeSlot;
  final String status;
  final double price;
  final String courtLocation;
  final String courtImageUrl;
  final DateTime? pendingUntil;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.courtId,
    required this.courtName,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.price,
    required this.courtLocation,
    required this.courtImageUrl,
    this.pendingUntil,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courtId': courtId,
      'courtName': courtName,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'status': status,
      'price': price,
      'courtLocation': courtLocation,
      'courtImageUrl': courtImageUrl,
      if (pendingUntil != null) 'pendingUntil': Timestamp.fromDate(pendingUntil!),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    try {
      final dateField = map['date'];
      if (dateField is Timestamp) {
        parsedDate = dateField.toDate();
      } else if (dateField is DateTime) {
        parsedDate = dateField;
      } else {
        parsedDate = DateTime.now();
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    DateTime? parsedPendingUntil;
    try {
      final pu = map['pendingUntil'];
      if (pu != null) {
        if (pu is Timestamp) {
          parsedPendingUntil = pu.toDate();
        } else if (pu is DateTime) {
          parsedPendingUntil = pu;
        }
      }
    } catch (_) {}

    DateTime parsedCreatedAt;
    try {
      final ca = map['createdAt'];
      if (ca is Timestamp) {
        parsedCreatedAt = ca.toDate();
      } else if (ca is DateTime) {
        parsedCreatedAt = ca;
      } else {
        parsedCreatedAt = DateTime.now();
      }
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    return BookingModel(
      id: id,
      userId: map['userId'] is String ? map['userId'] : '',
      courtId: map['courtId'] is String ? map['courtId'] : '',
      courtName: map['courtName'] is String ? map['courtName'] : '',
      date: parsedDate,
      timeSlot: map['timeSlot'] is String ? map['timeSlot'] : '',
      status: map['status'] is String ? map['status'] : 'pending',
      price: (map['price'] is num ? map['price'] : 0).toDouble(),
      courtLocation: map['courtLocation'] is String ? map['courtLocation'] : '',
      courtImageUrl: map['courtImageUrl'] is String ? map['courtImageUrl'] : '',
      pendingUntil: parsedPendingUntil,
      createdAt: parsedCreatedAt,
    );
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? courtId,
    String? courtName,
    DateTime? date,
    String? timeSlot,
    String? status,
    double? price,
    String? courtLocation,
    String? courtImageUrl,
    DateTime? pendingUntil,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courtId: courtId ?? this.courtId,
      courtName: courtName ?? this.courtName,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      price: price ?? this.price,
      courtLocation: courtLocation ?? this.courtLocation,
      courtImageUrl: courtImageUrl ?? this.courtImageUrl,
      pendingUntil: pendingUntil ?? this.pendingUntil,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isPendingExpired =>
      isPending && pendingUntil != null && DateTime.now().isAfter(pendingUntil!);
}
