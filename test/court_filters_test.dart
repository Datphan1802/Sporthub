import 'package:flutter_test/flutter_test.dart';
import 'package:sporthub/models/court_model.dart';
import 'package:sporthub/utils/court_filters.dart';

void main() {
  final courts = [
    CourtModel(
      id: 'football',
      name: 'Sân bóng',
      location: 'Quận 9',
      price: 300000,
      description: '',
      imageUrl: '',
      sportType: 'Bóng đá',
    ),
    CourtModel(
      id: 'badminton',
      name: 'Sân cầu lông',
      location: 'Thủ Đức',
      price: 90000,
      description: '',
      imageUrl: '',
      sportType: 'Cầu lông',
    ),
  ];

  test('returns all courts when no sport filter is selected', () {
    expect(filterCourtsBySport(courts, null), courts);
  });

  test('returns only courts matching the selected sport', () {
    final filtered = filterCourtsBySport(courts, 'Bóng đá');

    expect(filtered, hasLength(1));
    expect(filtered.single.id, 'football');
  });
}
