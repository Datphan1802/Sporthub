import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/court_model.dart';
import '../models/booking_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<CourtModel>> getCourts() {
    return _db.collection('courts').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CourtModel.fromMap(doc.data(), doc.id)).toList());
  }

  bool _isExpired(BookingModel b) {
    return b.isPending &&
        b.pendingUntil != null &&
        DateTime.now().isAfter(b.pendingUntil!);
  }

  Future<BookingResult> bookCourtWithTransaction({
    required String courtId,
    required String courtName,
    required DateTime date,
    required String timeSlot,
    required String userId,
    required double price,
    required String courtLocation,
    required String courtImageUrl,
  }) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    try {
      final qSnap = await _db
          .collection('bookings')
          .where('courtId', isEqualTo: courtId)
          .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      for (final doc in qSnap.docs) {
        final booking = BookingModel.fromMap(doc.data(), doc.id);
        if (!_isExpired(booking)) {
          return BookingResult.slotTaken;
        }
      }

      await _db.runTransaction((transaction) async {
        final docRef = _db.collection('bookings').doc();
        final pendingUntil =
            DateTime.now().add(const Duration(minutes: 15));
        transaction.set(docRef, {
          'userId': userId,
          'courtId': courtId,
          'courtName': courtName,
          'date': Timestamp.fromDate(normalizedDate),
          'timeSlot': timeSlot,
          'status': 'pending',
          'price': price,
          'courtLocation': courtLocation,
          'courtImageUrl': courtImageUrl,
          'pendingUntil': Timestamp.fromDate(pendingUntil),
          'createdAt': Timestamp.now(),
        });
      });

      return BookingResult.success;
    } on FirebaseException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        return BookingResult.permissionDenied;
      }
      return BookingResult.error;
    } catch (_) {
      return BookingResult.error;
    }
  }

  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<BookingModel>> getAllBookings() {
    return _db
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<BookingModel>> getBookingsByCourts(List<String> courtIds) {
    if (courtIds.isEmpty) {
      return Stream.value([]);
    }
    return _db
        .collection('bookings')
        .where('courtId', whereIn: courtIds)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
    });
  }

  Future<void> confirmBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'confirmed',
    });
  }
}

enum BookingResult {
  success,
  slotTaken,
  permissionDenied,
  error,
}
