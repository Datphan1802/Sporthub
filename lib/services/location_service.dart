import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

typedef LocationProvider = Future<LatLng?> Function();

class LocationService {
  static const String demoLocationAddress =
      '7 Đ. D1, Tăng Nhơn Phú, Hồ Chí Minh 700000, Việt Nam';
  static const LatLng demoLocation = LatLng(10.8414168, 106.8100745);
  static const String _demoLocationMode = String.fromEnvironment(
    'USE_DEMO_LOCATION',
  );

  final LocationProvider? _locationProvider;
  final bool _useDemoLocation;

  LocationService({LocationProvider? locationProvider, bool? useDemoLocation})
    : _locationProvider = locationProvider,
      _useDemoLocation =
          useDemoLocation ??
          (_demoLocationMode.isEmpty
              ? kDebugMode
              : _demoLocationMode.toLowerCase() == 'true');

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  Future<LatLng?> getCurrentLocation() async {
    if (_useDemoLocation) {
      return demoLocation;
    }

    final realLocation = await (_locationProvider ?? _getDeviceLocation)();
    return realLocation ?? demoLocation;
  }

  Future<LatLng?> _getDeviceLocation() async {
    try {
      final hasPermission = await isLocationPermissionGranted();
      if (!hasPermission) {
        final granted = await requestLocationPermission();
        if (!granted) return null;
      }

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  String buildDirectionsUrl({
    double? currentLat,
    double? currentLng,
    required double destLat,
    required double destLng,
  }) {
    final origin = currentLat != null && currentLng != null
        ? '&origin=$currentLat,$currentLng'
        : '';
    return 'https://www.google.com/maps/dir/?api=1$origin&destination=$destLat,$destLng';
  }
}
