import '../models/court_model.dart';

List<CourtModel> filterCourtsBySport(
  List<CourtModel> courts,
  String? selectedSport,
) {
  if (selectedSport == null || selectedSport == 'Tất cả') {
    return courts;
  }

  return courts.where((court) => court.sportType == selectedSport).toList();
}
