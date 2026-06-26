import 'package:flutter_test/flutter_test.dart';
import 'package:sporthub/data/demo_courts.dart';

void main() {
  test('demo courts include football and badminton courts around Q9', () {
    final courts = DemoCourts.fallbackCourts;

    expect(courts, isNotEmpty);
    expect(courts.any((court) => court.sportType == 'Bóng đá'), isTrue);
    expect(courts.any((court) => court.sportType == 'Cầu lông'), isTrue);
    expect(courts.every((court) => court.hasLocation), isTrue);
    expect(
      courts.every(
        (court) =>
            court.location.contains('Quận 9') ||
            court.location.contains('Thủ Đức'),
      ),
      isTrue,
    );
  });
}
