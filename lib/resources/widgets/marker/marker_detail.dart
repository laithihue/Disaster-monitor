import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';

//import '../../../app/controllers/disaster_controller.dart';
import '../../../app/controllers/disaster_controller.dart';
import 'changed_marker.dart';
import 'delete_marker.dart';
import 'edit_marker.dart';

class MarkerDetail extends StatefulWidget {
  final Map<String, dynamic> disasterData;
  final DisasterController controller;
  const MarkerDetail({
    super.key,
    required this.disasterData,
    required this.controller,
  });

  @override
  createState() => _MarkerDetailState();
}

class _MarkerDetailState extends NyState<MarkerDetail> {
  void _deleteDisasterItem(BuildContext context, Map<String, dynamic> item) {
    // Khởi tạo class handler và truyền các tham số cần thiết vào
    DeleteMarker(
      context: context,
      item: item,
      controller: widget.controller,
    ).execute(); // Chạy logic xóa
  }

  @override
  Widget build(BuildContext context) {
    // 1. Bóc tách dữ liệu
    final disasterData = widget.disasterData;
    final String title = disasterData['title'] ?? 'Không rõ tên';
    final String description =
        disasterData['description'] ?? 'Không có mô tả chi tiết.';
    final String disasterName = disasterData['name'] ?? 'Thiên tai';

    final Uint8List? uint8ListBytes = disasterData['imageBytes'];
    // Xử lý lấy tọa độ an toàn
    final dynamic posData = disasterData['position'];
    final LatLng pos = posData is LatLng
        ? posData
        : LatLng(
            double.parse((disasterData['latitude'] ?? 0.0).toString()),
            double.parse((disasterData['longitude'] ?? 0.0).toString()),
          );

    final String createTime = disasterData['create_time'] ?? 'Chưa rõ';
    final String updateTime = disasterData['update_time'] ?? 'Chưa rõ';
    // final String? imagePath = disasterData['image_path'];

    final String jsonPaths = disasterData['image_path'] ?? '[]';
    List<String> imageList = [];
    try {
      imageList = List<String>.from(jsonDecode(jsonPaths));
    } catch (e) {
      //print("Lỗi giải mã danh sách ảnh: $e");
      showToastNotification(
        context,
        id: "danger",
        description: "Lỗi giải mã ds ảnh: $e",
      );
    }
    return Container(
      // Thêm padding bọc toàn bộ BottomSheet cho thoáng giống ảnh mẫu
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Toàn bộ căn lề trái
          children: [
            // Hàng Tiêu đề & Nút đóng
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.all(3),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.blue[200],
                    size: 40,
                  ), // Đổi icon giống ảnh mẫu
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            //// KHỐI HIỂN THỊ HÌNH ẢNH NGƯỜI DÙNG UPLOAD
            // Container(
            //   width: double.infinity,
            //   height: 180,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[100], // Màu nền xám nhạt như ảnh mẫu
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            //   child: _buildUserImage(userImageRaw),
            // ),
            ////lưu 1 ảnh
            // imagePath != null &&
            //         imagePath.isNotEmpty &&
            //         File(imagePath).existsSync()
            //     ? Container(
            //         width: double.infinity,
            //         height: 180,
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(10),
            //           image: DecorationImage(
            //             image: FileImage(File(imagePath)),
            //             fit: BoxFit
            //                 .cover, // Giúp ảnh lấp đầy khung hình, không bị bóp méo
            //           ),
            //         ),
            //       )
            imageList.isNotEmpty
                ? Container(
                    height: 180, // Chiều cao của khung chứa ảnh
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListView.builder(
                      scrollDirection:
                          Axis.horizontal, // Cho phép vuốt ngang qua các ảnh
                      itemCount: imageList.length,
                      itemBuilder: (context, index) {
                        final String path = imageList[index];
                        final File imageFile = File(path);

                        // Kiểm tra xem file ảnh có thực sự tồn tại trong bộ nhớ máy không
                        if (!imageFile.existsSync()) {
                          return const SizedBox.shrink(); // Nếu ảnh bị mất, ẩn đi
                        }

                        return Container(
                          width:
                              280, // Chiều rộng của mỗi bức ảnh khi cuộn ngang
                          margin: const EdgeInsets.only(
                            right: 12.0,
                          ), // Khoảng cách giữa các ảnh
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(imageFile),
                              fit: BoxFit
                                  .cover, // Lấp đầy khung hình không bóp méo
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_outlined),
                        SizedBox(height: 10),
                        Text('Không có hình ảnh'),
                      ],
                    ),
                  ),
            const SizedBox(height: 16),

            // KHỐI TAG LOẠI THIÊN TAI (Ví dụ: [Icon] Bão)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50], // Nền xanh nhạt
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Thu nhỏ vừa khít nội dung

                children: [
                  SvgPicture.memory(
                    uint8ListBytes!,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(
                      Colors.blue,
                      BlendMode.srcIn,
                    ),
                    errorBuilder: (context, error, stackTrace) {
                      // Trường hợp chuỗi base64 bị lỗi mã hóa hoặc hỏng dữ liệu
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.red,
                        size: 32,
                      );
                    },
                  ),
                  SizedBox(width: 5),
                  Text(
                    disasterName,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // MÔ TẢ SỰ KIỆN
            const Text(
              'Mô tả sự kiện',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // THÔNG TIN VỊ TRÍ & NGÀY TẠO
            Row(
              children: [
                Expanded(
                  child: _buildInfor(
                    icon: Icons.location_on,
                    iconColor: Colors.red,
                    bgColor: Colors.red[50]!,
                    title: "Vị trí",
                    value:
                        "${pos.latitude.toStringAsFixed(4)},\n${pos.longitude.toStringAsFixed(4)}",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfor(
                    icon: Icons.calendar_today,
                    iconColor: Colors.orange,
                    bgColor: Colors.orange[50]!,
                    title: "Ngày tạo",
                    value: createTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // CẬP NHẬT LẦN CUỐI
            _buildInfor(
              icon: Icons.history,
              iconColor: Colors.green,
              bgColor: Colors.green[50]!,
              title: "Cập nhật lần cuối",
              value: updateTime,
              isFulWidth: true,
            ),
            const SizedBox(height: 24),
            ChangedMarker(
              onEditPressed: () {
                //print("User bấm nút Sửa");
                EditMarker(
                  context: context,
                  item: disasterData, // Dữ liệu thảm họa gốc
                  position: pos, // Tọa độ LatLng đã parse ở đầu hàm build
                  controller: widget
                      .controller, // Controller của class Cha truyền xuống
                ).execute();
              },
              onDeletePressed: () {
                _deleteDisasterItem(context, disasterData);
              },
              onDirectionsPressed: () async {
                final String googleUrl =
                    'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}';
                await launchUrl(
                  Uri.parse(googleUrl),
                  mode: LaunchMode.externalApplication,
                );
                //print("User bấm nút Đường dẫn");
              },
            ),
          ],
        ),
      ),
    );
  }
}

// SỬA LẠI THÀNH PHẦN HIỂN THỊ THÔNG TIN CHO THẲNG HÀNG LỀ TRÁI
Widget _buildInfor({
  required IconData icon,
  required Color iconColor,
  required Color bgColor,
  required String title,
  required String value,
  bool isFulWidth = false,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey[200]!,
      ), // Tạo khung viền mờ bo góc giống ảnh mẫu
    ),
    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.center, // Giúp các icon luôn căn giữa dòng chữ
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape
                .circle, // Chuyển ô vuông icon thành hình tròn chuẩn thiết kế mẫu
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .start, // SỬA QUAN TRỌNG: Giúp chữ luôn căn thẳng lề trái
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
