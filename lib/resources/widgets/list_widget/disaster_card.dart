import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../../app/controllers/disaster_controller.dart';
import '../marker/marker_detail.dart';

class DisasterCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onRefresh; // ──> THÊM DÒNG NÀY

  const DisasterCard({super.key, required this.item, this.onRefresh});

  @override
  State<DisasterCard> createState() => _DisasterCardState();
}

class _DisasterCardState extends NyState<DisasterCard> {
  final DisasterController _controller = DisasterController();

  @override
  Widget build(BuildContext context) {
    // Bóc tách dữ liệu từ Map
    final String title = widget.item['title'] ?? 'Không có tiêu đề';
    final String name = widget.item['name'] ?? 'Không rõ';

    // Ép kiểu tọa độ an toàn, lấy 3 chữ số thập phân
    final double lat = double.parse(
      (widget.item['latitude'] ?? 0.0).toString(),
    );
    final double lng = double.parse(
      (widget.item['longitude'] ?? 0.0).toString(),
    );
    final Uint8List? uint8ListBytes = widget.item['imageBytes'];

    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) =>
              MarkerDetail(disasterData: widget.item, controller: _controller),
        );
        if ((result == true || result == 'delete') && mounted) {
          // await _controller.fetchDisaster(-1);
          // setState(() {});
          widget.onRefresh!();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0, left: 16.0, right: 16.0),
        padding: const EdgeInsets.all(
          12.0,
        ), // Thêm không gian đệm bên trong card
        decoration: BoxDecoration(
          color:
              Colors.white, // Chuyển nền sang màu Trắng cho tinh tế và sạch sẽ
          borderRadius: BorderRadius.circular(16.0),
          // Thêm đổ bóng mờ giúp Card nổi lên trên nền bản đồ
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey[100]!), // Viền mờ bao quanh
        ),
        child: Row(
          children: [
            // 1. Khối chứa Icon SVG thiên tai (Được bọc khung tròn màu xanh nhạt)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: uint8ListBytes != null && uint8ListBytes.isNotEmpty
                  ? SvgPicture.memory(
                      uint8ListBytes,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,

                      // Ép màu icon sang màu xanh cho đồng bộ hệ thống nếu muốn
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.warning,
                        size: 32,
                        color: Colors.red,
                      ),
                    )
                  : const Icon(Icons.blur_on, size: 32, color: Colors.blue),
            ),
            const SizedBox(width: 16.0), // Khoảng cách giữa Icon và Khối chữ
            // 2. KHỐI CHỮ: Bắt buộc bọc bằng Expanded để tự động co giãn và xuống dòng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // BIẾN ĐỔI QUAN TRỌNG: Căn thẳng lề trái
                children: [
                  // Tên loại thiên tai (Ví dụ: Bão, Sét)
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4.0),

                  // Tiêu đề phụ (Ví dụ: abc, lụt...)
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow
                        .ellipsis, // Nếu tiêu đề dài quá tự động hóa thành dấu "..."
                  ),
                  const SizedBox(height: 6.0),

                  // Khối hiển thị Tọa độ (Có thêm icon nhỏ nhìn chuyên nghiệp hơn)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily:
                              'monospace', // Chữ dạng mã code cho ngay ngắn
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Nút mũi tên chuyển tiếp (Nhìn thanh thoát kiểu iOS)
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// import '../map_widget/marker_detail.dart';

// class DisasterCard extends StatelessWidget {
//   final Map<String, dynamic> item;

//   const DisasterCard({super.key, required this.item});
//   @override
//   Widget build(BuildContext context) {
//     // Bóc tách dữ liệu từ Map
//     final String title =
//         item['title'] ?? 'Không có tiêu đề'; // Tiêu đề người dùng nhập
//     final String name =
//         item['name'] ?? 'Không rõ'; // Tên loại thiên tai (Ví dụ: Bão)
//     final double lat = double.parse(
//       (item['latitude'] ?? 0.0).toStringAsFixed(3),
//     );
//     final double lng = double.parse(
//       (item['longitude'] ?? 0.0).toStringAsFixed(3),
//     );
//     final Uint8List? uint8ListBytes = item['imageBytes'];

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12.0),
//       decoration: BoxDecoration(
//         color: Colors.blue[100],
//         borderRadius: BorderRadius.circular(16.0), // Bo tròn góc
//       ),
//       child: Row(
//         children: [
//           Column(
//             children: [
//               Row(
//                 children: [
//                   if (uint8ListBytes != null && uint8ListBytes.isNotEmpty)
//                     //? Image.memory(
//                     //base64Decode(base64String),
//                     SvgPicture.memory(
//                       uint8ListBytes,
//                       width: 32,
//                       height: 32,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         // Trường hợp chuỗi base64 bị lỗi mã hóa hoặc hỏng dữ liệu
//                         return const Icon(
//                           Icons.broken_image,
//                           color: Colors.red,
//                           size: 32,
//                         );
//                       },
//                     ),
//                   Text(name),
//                 ],
//               ),
//               Text(title),
//               Text('$lat, $lng'),
//             ],
//           ),
//           IconButton(
//             icon: const Icon(
//               Icons.arrow_forward_ios,
//             ), // Dạng mũi tên mảnh kiểu iOS
//             // Hoặc dùng Icons.arrow_forward cho mũi tên mặc định
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 builder: (context) => MarkerDetail(disasterData: item),
//               ); // Code xử lý khi bấm nút ở đây
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
