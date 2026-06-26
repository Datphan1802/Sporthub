import '../models/court_model.dart';

class DemoCourts {
  DemoCourts._();

  static final List<CourtModel> fallbackCourts = [
    CourtModel(
      id: 'demo-football-449',
      name: 'Sân bóng đá mini 449',
      location:
          'Đường 449 / 449 Lê Văn Việt, Tăng Nhơn Phú A, Quận 9, TP. Thủ Đức',
      price: 300000,
      description:
          'Sân bóng mini khu Lê Văn Việt, phù hợp đặt sân 5 người khi demo gần khu công nghệ cao.',
      imageUrl:
          'https://images.unsplash.com/photo-1556056504-5c7696c4c28d?w=900',
      latitude: 10.8465,
      longitude: 106.787,
      sportType: 'Bóng đá',
    ),
    CourtModel(
      id: 'demo-football-phuoc-binh',
      name: 'Sân bóng đá Phước Bình Q9',
      location: '600/1 Đỗ Xuân Hợp, Phường Phước Bình, Quận 9, TP. Thủ Đức',
      price: 320000,
      description:
          'Cụm sân bóng khu Phước Bình, gần trục Đỗ Xuân Hợp để demo đặt sân quanh Q9.',
      imageUrl:
          'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=900',
      latitude: 10.795947,
      longitude: 106.780681,
      sportType: 'Bóng đá',
    ),
    CourtModel(
      id: 'demo-football-thanh-phat',
      name: 'Sân bóng Thành Phát',
      location: '146 Nam Hòa, Phường Phước Long A, Quận 9, TP. Thủ Đức',
      price: 350000,
      description:
          'Sân bóng cỏ nhân tạo khu Phước Long A, dùng làm dữ liệu demo khi Firestore chưa có sân.',
      imageUrl:
          'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=900',
      latitude: 10.8155,
      longitude: 106.7735,
      sportType: 'Bóng đá',
    ),
    CourtModel(
      id: 'demo-badminton-locab',
      name: 'LocaB Academy Badminton Club',
      location: '12 Đường số 12D, Phường Long Thạnh Mỹ, Quận 9, TP. Thủ Đức',
      price: 90000,
      description:
          'Sân cầu lông khu Long Thạnh Mỹ, gần khu công nghệ cao và vị trí demo D1.',
      imageUrl:
          'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=900',
      latitude: 10.8498,
      longitude: 106.8192,
      sportType: 'Cầu lông',
    ),
    CourtModel(
      id: 'demo-badminton-an-binh',
      name: 'Sân cầu lông An Bình',
      location: '240A Dương Đình Hội, Tăng Nhơn Phú B, Quận 9, TP. Thủ Đức',
      price: 100000,
      description:
          'Cụm sân cầu lông khu Tăng Nhơn Phú B, phù hợp demo lọc sân cầu lông.',
      imageUrl:
          'https://images.unsplash.com/photo-1613918431703-aa50889e3be0?w=900',
      latitude: 10.8195,
      longitude: 106.7832,
      sportType: 'Cầu lông',
    ),
    CourtModel(
      id: 'demo-badminton-long-sen',
      name: 'Sân cầu lông Long Sen',
      location: '39P Gò Cát, Phường Phú Hữu, Quận 9, TP. Thủ Đức',
      price: 90000,
      description:
          'Sân cầu lông khu Phú Hữu, thêm lựa chọn demo trong phạm vi Quận 9.',
      imageUrl:
          'https://images.unsplash.com/photo-1599474924187-334a4ae5bd3c?w=900',
      latitude: 10.7968,
      longitude: 106.8025,
      sportType: 'Cầu lông',
    ),
    CourtModel(
      id: 'demo-badminton-new-star',
      name: 'Sân cầu lông New Star',
      location: '77 Đỗ Xuân Hợp, Phước Long B, Quận 9, TP. Thủ Đức',
      price: 95000,
      description:
          'Sân cầu lông khu Đỗ Xuân Hợp, dùng để demo danh sách sân quanh TP.HCM.',
      imageUrl:
          'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=900',
      latitude: 10.8064,
      longitude: 106.7711,
      sportType: 'Cầu lông',
    ),
  ];

  static List<CourtModel> withFallback(List<CourtModel> courts) {
    return courts.isEmpty ? fallbackCourts : courts;
  }
}
