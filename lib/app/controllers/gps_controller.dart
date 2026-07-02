import 'package:geolocator/geolocator.dart';
import 'controller.dart';

class GpsController extends Controller {
  Future<Position> getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Tọa độ mặc định của Hà Nội nếu xảy ra lỗi hoặc bị từ chối
    final Position hanoiFallback = Position(
      latitude: 21.0285,
      longitude: 105.8542,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      floor: null,
    );

    try {
      // 1. Kiểm tra dịch vụ định vị (GPS)
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Dịch vụ định vị tắt. Sử dụng tọa độ Hà Nội.');
        return hanoiFallback;
      }

      // 2. Kiểm tra quyền truy cập vị trí
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Quyền bị từ chối. Sử dụng tọa độ Hà Nội.');
          return hanoiFallback;
        }
      }

      // 3. Kiểm tra nếu bị từ chối vĩnh viễn
      if (permission == LocationPermission.deniedForever) {
        print('Quyền bị từ chối vĩnh viễn. Sử dụng tọa độ Hà Nội.');
        return hanoiFallback;
      }

      // 4. Lấy vị trí thực tế thành công
      return await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 20),
      ); // Quá 5 giây không phản hồi sẽ nhảy vào catch
    } catch (e) {
      // Xử lý các lỗi ngoại lệ khác (nếu có)
      print('Lỗi xảy ra: $e. Sử dụng tọa độ Hà Nội.');
      return hanoiFallback;
    }
  }
}
