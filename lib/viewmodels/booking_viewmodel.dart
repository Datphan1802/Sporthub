import 'dart:async';
import 'package:flutter/material.dart';
import '../data/demo_courts.dart';
import '../services/firestore_service.dart';
import '../models/court_model.dart';
import '../models/booking_model.dart';

class BookingViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<CourtModel> _courts = [];
  List<BookingModel> _myBookings = [];
  List<BookingModel> _allBookings = [];
  bool _isLoading = false;
  String? _lastBookingError;
  StreamSubscription<List<CourtModel>>? _courtsSubscription;
  StreamSubscription<List<BookingModel>>? _bookingsSubscription;
  StreamSubscription<List<BookingModel>>? _allBookingsSubscription;

  List<CourtModel> get courts => _courts;
  List<BookingModel> get myBookings => _myBookings;
  List<BookingModel> get allBookings => _allBookings;
  bool get isLoading => _isLoading;
  String? get lastBookingError => _lastBookingError;

  int get totalBookings => _myBookings.length;
  int get completedBookings =>
      _myBookings.where((b) => b.status == 'completed').length;
  int get upcomingBookings => _myBookings
      .where((b) => b.status == 'pending' || b.status == 'confirmed')
      .length;

  List<BookingModel> get activeBookings => _myBookings
      .where((b) => b.status == 'pending' || b.status == 'confirmed')
      .toList();

  void fetchCourts() {
    _courtsSubscription?.cancel();
    _courtsSubscription = _firestoreService.getCourts().listen((data) {
      _courts = DemoCourts.withFallback(data);
      notifyListeners();
    });
  }

  void fetchMyBookings(String userId) {
    _bookingsSubscription?.cancel();
    _bookingsSubscription = _firestoreService.getUserBookings(userId).listen((
      data,
    ) {
      _myBookings = data;
      notifyListeners();
    });
  }

  void fetchAllBookings() {
    _allBookingsSubscription?.cancel();
    _allBookingsSubscription = _firestoreService.getAllBookings().listen((
      data,
    ) {
      _allBookings = data;
      notifyListeners();
    });
  }

  void fetchBookingsByCourts(List<String> courtIds) {
    _allBookingsSubscription?.cancel();
    _allBookingsSubscription = _firestoreService
        .getBookingsByCourts(courtIds)
        .listen((data) {
          _allBookings = data;
          notifyListeners();
        });
  }

  Future<bool> bookCourt({
    required String courtId,
    required String courtName,
    required DateTime date,
    required String timeSlot,
    required String userId,
    required double price,
    required String courtLocation,
    required String courtImageUrl,
  }) async {
    _isLoading = true;
    _lastBookingError = null;
    notifyListeners();

    try {
      final result = await _firestoreService.bookCourtWithTransaction(
        courtId: courtId,
        courtName: courtName,
        date: date,
        timeSlot: timeSlot,
        userId: userId,
        price: price,
        courtLocation: courtLocation,
        courtImageUrl: courtImageUrl,
      );

      switch (result) {
        case BookingResult.success:
          _isLoading = false;
          _lastBookingError = null;
          notifyListeners();
          return true;
        case BookingResult.slotTaken:
          _lastBookingError =
              'Khung giờ này đã được đặt. Vui lòng chọn khung giờ khác.';
          break;
        case BookingResult.permissionDenied:
          _lastBookingError = 'Bạn không có quyền thực hiện thao tác này.';
          break;
        case BookingResult.error:
          _lastBookingError = 'Đã xảy ra lỗi. Vui lòng thử lại.';
          break;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _lastBookingError = 'Đã xảy ra lỗi: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.cancelBooking(bookingId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool isSlotTaken(String courtId, DateTime date, String timeSlot) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _myBookings.any(
      (b) =>
          b.courtId == courtId &&
          b.date.year == normalizedDate.year &&
          b.date.month == normalizedDate.month &&
          b.date.day == normalizedDate.day &&
          b.timeSlot == timeSlot &&
          (b.status == 'pending' || b.status == 'confirmed') &&
          !b.isPendingExpired,
    );
  }

  @override
  void dispose() {
    _courtsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _allBookingsSubscription?.cancel();
    super.dispose();
  }
}
