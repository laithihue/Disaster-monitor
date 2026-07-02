import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/controllers/disaster_controller.dart';
import '../../../app/controllers/disaster_repository.dart';
import '../../../app/controllers/gps_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/forms/form_widget.dart';
import '../marker/marker_detail.dart';
import 'instrucsion_banner.dart';

class MapWidget extends NyStatefulWidget {
  MapWidget({super.key});

  @override
  createState() => _MapWidgetState();
}

class _MapWidgetState extends NyState<MapWidget> {
  //vtri htai của ng dùng
  LatLng _curLocation = const LatLng(21.0285, 105.8542);

  late MapController _mapController = MapController();
  bool _isMapReady = false; //ktra load xong chx

  final GpsController gpsController = GpsController();
  final DisasterController disasterController = DisasterController();

  @override
  get init => () async {
    _mapController = MapController();
    // Nạp danh sách thảm họa từ DB lên mảng RAM của Controller
    await disasterController.fetchDisaster(-1);

    // Lắng nghe tiếng chuông từ Controller để tự động vẽ lại Marker khi có thay đổi (Xóa/Thêm mới)
    // whenStateChanges('disaster_data_provider', perform: () {
    //   setState(() {});
    // });
    // afterStateChange(stateKey: 'disaster_data_provider', handler: () {
    //   setState(() {}); // Tự động ép giao diện Map vẽ lại các Marker mới
    // });

    await getLatLng();
  };

  @override
  Future<void> stateUpdated(dynamic data) async {
    super.stateUpdated(data);

    // Ép giao diện Map vẽ lại toàn bộ các Marker mới nhất từ Controller
    setState(() {});
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> getLatLng() async {
    Position position = await gpsController.getPosition();
    setState(() {
      _curLocation = LatLng(position.latitude, position.longitude);
    });
    if (_isMapReady) {
      _mapController.move(_curLocation, 17.0); //(toạ độ đích, mức độ zoom)
    }
  }

  @override
  Widget view(BuildContext context) {
    final curDisasters = disasterController.disasters;
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _curLocation, // tâm
            initialZoom: 17.0,
            onMapReady: () {
              setState(() {
                _isMapReady = true;
              });
              _mapController.move(_curLocation, 17.0);
            },
            onLongPress: (tapPosition, point) async {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) =>
                    FormWidget(position: point, editData: null),
              );
              if (result != null && result == true) {
                // bool isSaved = await disasterController.saveReportedDisaster(
                //   context,
                //   result,
                // );
                //if (isSaved && mounted) {
                if (mounted) {
                  await disasterController.fetchDisaster(-1);
                  setState(() {});
                }
              }
            },
          ),
          children: [
            TileLayer(
              // Bring your own tiles
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.vietgis.disaster_app',
            ),
            MarkerLayer(
              markers: [
                // 1. Đặt 1 Marker tại vị trí hiện tại
                Marker(
                  point: _curLocation,
                  width: 48,
                  height: 48,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 46,
                  ),
                ),
                // 2. TỰ ĐỘNG THÊM CÁC MARKER THIÊN TAI ĐÃ BÁO CÁO QUA FORM
                ...curDisasters.map((disasterData) {
                  //LatLng pos = disasterData['position'];
                  double lat =
                      double.tryParse(disasterData['latitude'].toString()) ??
                      0.0;
                  double lng =
                      double.tryParse(disasterData['longitude'].toString()) ??
                      0.0;

                  String title = disasterData['title'];

                  //String? base64String = type?.image;
                  final uint8ListBytes = disasterData['imageBytes'];

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 100, // Chiều rộng đủ cho nhãn chữ
                    height: 85, // Chiều cao đủ cho cả ảnh và chữ xếp dọc
                    alignment: Alignment
                        .topCenter, // Giúp ghim chính xác tâm vòng tròn vào tọa độ
                    child: GestureDetector(
                      onTap: () async {
                        final result = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => MarkerDetail(
                            disasterData: disasterData,
                            controller: disasterController,
                          ),
                        );
                        if (result == 'deleted' && mounted) {
                          await disasterController.fetchDisaster(-1);
                          setState(() {});
                        } else if (result == true && mounted) {
                          await disasterController.fetchDisaster(-1);
                          setState(() {});
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bong bóng chứa ảnh thiên tai viền đỏ nổi bật
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.2,
                                  ), // Sửa lại cách viết withValues chuẩn Flutter mới
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.lightBlueAccent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child:
                                  //base64String != null && base64String.isNotEmpty
                                  uint8ListBytes != null &&
                                      uint8ListBytes.isNotEmpty
                                  //? Image.memory(
                                  //base64Decode(base64String),
                                  ? SvgPicture.memory(
                                      uint8ListBytes,
                                      width: 37,
                                      height: 37,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Trường hợp chuỗi base64 bị lỗi mã hóa hoặc hỏng dữ liệu
                                        return const Icon(
                                          Icons.broken_image,
                                          color: Colors.red,
                                          size: 35,
                                        );
                                      },
                                    )
                                  : const Icon(
                                      Icons.warning,
                                      color: Colors.red,
                                      size: 35,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Nhãn hiển thị tên thiên tai nền đen mờ
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withValues(), // Sửa lại cách viết withValues chuẩn Flutter mới
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
        // Cụm các nút bấm FloatingActionButton điều khiển bản đồ
        Positioned(
          top: 16, // Cách mép trên thanh TabBar 16 pixel
          left: 16,
          right: 16,
          child: const Center(
            child: InstructionBanner(), // Gọi widget riêng của chúng ta ra
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: FloatingActionButton(
                  heroTag: "cur_location",
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.gps_fixed,
                    color: Colors.blue,
                    size: 35,
                  ),
                  onPressed: () {
                    if (_isMapReady) {
                      _mapController.move(
                        _curLocation,
                        _mapController.camera.zoom,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "zoom_in",
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black),
                onPressed: () {
                  if (_isMapReady) {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "zoom_out",
                backgroundColor: Colors.white,
                child: const Icon(Icons.remove, color: Colors.black),
                onPressed: () {
                  if (_isMapReady) {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    ); // Đóng Stack gọn gàng
  }
}
