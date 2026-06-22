import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/court_model.dart';
import '../models/booking_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of Courts
  Stream<List<CourtModel>> getCourts() {
    return _db.collection('courts').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CourtModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Add Booking
  Future<void> addBooking(BookingModel booking) async {
    await _db.collection('bookings').add(booking.toMap());
  }

  // Stream of My Bookings
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
