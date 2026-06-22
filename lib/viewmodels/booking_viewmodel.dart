import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/court_model.dart';
import '../models/booking_model.dart';

class BookingViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<CourtModel> _courts = [];
  List<BookingModel> _myBookings = [];
  bool _isLoading = false;

  List<CourtModel> get courts => _courts;
  List<BookingModel> get myBookings => _myBookings;
  bool get isLoading => _isLoading;

  void fetchCourts() {
    _firestoreService.getCourts().listen((data) {
      _courts = data;
      notifyListeners();
    });
  }

  void fetchMyBookings(String userId) {
    _firestoreService.getUserBookings(userId).listen((data) {
      _myBookings = data;
      notifyListeners();
    });
  }

  Future<void> bookCourt(BookingModel booking) async {
    _isLoading = true;
    notifyListeners();
    await _firestoreService.addBooking(booking);
    _isLoading = false;
    notifyListeners();
  }
}
