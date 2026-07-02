import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  //static để gọi hàm từ bất kì đâu
  static final ImagePicker _picker = ImagePicker(); //tạo single ton tái sd đc
  //hàm chụp/ chọn
  //source là camera hoặc gallery, nén dung lg còn 80%
  static Future<File?> pickImage(ImageSource source, {int quality = 80}) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: quality,
      );
      if (photo != null) {
        return File(
          photo.path,
        ); //chuyển đổi từ định dạng trừu tg đa nền tảng XFile sang tiêu chuẩn File
      }
    } catch (e) {
      print("Lỗi MediaService (pickImage): $e");
      // showToastNotification(
      //   context,
      //   id: "danger",
      //   description: "Lỗi MediaService: $e",
      // );
    }
    return null;
  }

  // 2. Hàm chọn nhiều ảnh từ thư viện
  static Future<List<File>> pickMultiImage({int quality = 80}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: quality,
      );
      if (images.isNotEmpty) {
        return images.map((img) => File(img.path)).toList();
      }
    } catch (e) {
      print("Lỗi MediaService (pickMultiImage): $e");
    }
    return [];
  }

  // 3. Hàm hiển thị BottomSheet để người dùng chọn nguồn ảnh (Camera hoặc Gallery)
  static void showImageSourceBottomSheet({
    required BuildContext context,
    required Function(File selectedImage) onImageSelected, //callback
    Function(List<File> selectedImages)? onMultiImageSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            //tránh tràn màn hình, ko chiếm dụng dtich dư thừa
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Chụp ảnh mới'),
                onTap: () async {
                  Navigator.pop(context);
                  File? file = await pickImage(ImageSource.camera);
                  if (file != null) onImageSelected(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Chọn từ thư viện ảnh'),
                onTap: () async {
                  Navigator.pop(context);

                  // Nếu tầng gọi có truyền hàm xử lý chọn nhiều ảnh
                  if (onMultiImageSelected != null) {
                    List<File> files = await pickMultiImage();
                    if (files.isNotEmpty) onMultiImageSelected(files);
                  } else {
                    // Nếu không thì chỉ chọn 1 ảnh đơn lẻ từ thư viện
                    File? file = await pickImage(ImageSource.gallery);
                    if (file != null) onImageSelected(file);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
