import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sporthub/services/location_service.dart';

void main() {
  group('LocationService demo location', () {
    test('uses the real device location when it is available', () async {
      final location = await LocationService(
        locationProvider: () async => const LatLng(10.777, 106.701),
        useDemoLocation: false,
      ).getCurrentLocation();

      expect(location, isNotNull);
      expect(location!.latitude, closeTo(10.777, 0.000001));
      expect(location.longitude, closeTo(106.701, 0.000001));
    });

    test('uses the fixed D1 location when demo mode is enabled', () async {
      final location = await LocationService(
        locationProvider: () async => const LatLng(10.777, 106.701),
        useDemoLocation: true,
      ).getCurrentLocation();

      expect(location, isNotNull);
      expect(location!.latitude, closeTo(10.8414168, 0.000001));
      expect(location.longitude, closeTo(106.8100745, 0.000001));
    });

    test(
      'falls back to the fixed demo location when GPS is unavailable',
      () async {
        final location = await LocationService(
          locationProvider: () async => null,
        ).getCurrentLocation();

        expect(location, isNotNull);
        expect(location!.latitude, closeTo(10.8414168, 0.000001));
        expect(location.longitude, closeTo(106.8100745, 0.000001));
      },
    );

    test('uses the current location as directions origin when provided', () {
      final url = LocationService().buildDirectionsUrl(
        currentLat: 10.8414168,
        currentLng: 106.8100745,
        destLat: 10.845,
        destLng: 106.812,
      );

      expect(
        url,
        'https://www.google.com/maps/dir/?api=1&origin=10.8414168,106.8100745&destination=10.845,106.812',
      );
    });
  });
}
