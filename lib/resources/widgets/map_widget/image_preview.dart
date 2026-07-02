import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAddPressed;
  final Function(int index) onRemovePressed;

  const ImagePreview({
    super.key,
    required this.images,
    required this.onAddPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Để cuộn mượt bên trong SingleChildScrollView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Hiển thị 4 cột hàng ngang
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount:
          images.length + 1, // Cộng 1 để chừa chỗ cho nút dấu "+" thêm ảnh
      itemBuilder: (context, index) {
        // NÚT BẤM THÊM ẢNH (Nằm ở cuối danh sách)
        if (index == images.length) {
          return GestureDetector(
            onTap: onAddPressed,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid, // Viền nét liền
                ),
              ),
              child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
            ),
          );
        }

        // Ô HIỂN THỊ ẢNH ĐÃ CHỌN + NÚT XÓA
        return Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  images[index],
                  fit: BoxFit.cover, // Ảnh tự co dãn vừa khít ô
                ),
              ),
            ),
            // Nút "X" nhỏ màu trắng nền đen để xóa ảnh
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: () => onRemovePressed(index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
