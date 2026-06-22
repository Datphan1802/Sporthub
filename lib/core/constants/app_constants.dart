// Application-wide constants used throughout the SportHub app.
// Centralizes hardcoded values for easy maintenance and configuration.

class AppConstants {
  AppConstants._();

  // Application Info
  static const String appName = 'SportHub';
  static const String appTagline = 'Book Your Favorite Courts';

  // Firestore Collection Names
  static const String usersCollection = 'users';
  static const String courtsCollection = 'courts';
  static const String bookingsCollection = 'bookings';

  // Booking Status Values
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCancelled = 'cancelled';
  static const String statusCompleted = 'completed';

  // Default Time Slots for court booking
  static const List<String> timeSlots = [
    '06:00 - 07:00',
    '07:00 - 08:00',
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
    '19:00 - 20:00',
    '20:00 - 21:00',
    '21:00 - 22:00',
  ];

  // Placeholder images for courts when none are available
  static const String placeholderCourtImage =
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800';
  static const String placeholderAvatarImage =
      'https://ui-avatars.com/api/?name=User&background=6366f1&color=fff&size=200';

  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
}
