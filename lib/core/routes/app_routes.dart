// Route names used throughout the application.
// Centralized constants for route navigation to avoid string typos.

class AppRoutes {
  AppRoutes._();

  // Route Names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String courtDetail = '/court-detail';
  static const String booking = '/booking';
  static const String myBookings = '/my-bookings';
  static const String profile = '/profile';
  static const String main = '/main';

  // Owner Routes
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerCourts = '/owner/courts';
  static const String ownerCalendar = '/owner/calendar';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminApproval = '/admin/approval';

  // Map Route
  static const String map = '/map';
}
