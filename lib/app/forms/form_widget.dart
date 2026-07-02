import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart'; // Dùng để validate nếu cần
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:nylo_framework/nylo_framework.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../resources/widgets/map_widget/image_preview.dart';
import '../controllers/disaster_controller.dart';
import '../models/disaster_type.dart';
import '../service/media_service.dart';

class FormWidget extends StatefulWidget {
  final LatLng position;
  final Map<String, dynamic>? editData;
  const FormWidget({super.key, required this.position, required this.editData});

  @override
  createState() => _FormWidgetState();
}

class _FormWidgetState extends NyState<FormWidget> {
  // Khởi tạo key để quản lý trạng thái của FormBuilder
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = true;

  final DisasterController controller = DisasterController();
  final List<File> _selectedImages = [];

  //ds thiên tai lấy từ db
  List<DisasterType> _disasterOptions = [];
  DisasterType? initialDropdownValue;

  // Biến cờ kiểm tra xem đang Thêm mới hay đang Sửa
  bool get isEditMode => widget.editData != null;

  @override
  get init => () async {
    try {
      await controller.loadFile(context);
      if (!mounted) return;
      List<DisasterType> data = await controller.getDisasterType(context);
      if (!mounted) return;
      List<File> tempImages = [];
      DisasterType? tempDropdownValue;

      // setState(() {
      //   _disasterOptions = data; //gán dl vào biến tuỳ chọn
      //   _isLoading = false;
      // });
      // // Nếu ở chế độ sửa và bản ghi cũ có ảnh, nạp ảnh đó vào danh sách hiển thị luôn
      //   if (isEditMode && widget.editData!['image_path'] != null) {
      //     final oldImagePath = widget.editData!['image_path'] as String;
      //     if (oldImagePath.isNotEmpty && File(oldImagePath).existsSync()) {
      //       setState(() {
      //         _selectedImages.add(File(oldImagePath));
      //       });
      //     }
      //   }
      //   if (isEditMode && _disasterOptions.isNotEmpty) {
      //     initialDropdownValue = _disasterOptions.firstWhere(
      //       (element) => element.id == widget.editData!['disaster_type_id'],
      //       orElse: () => _disasterOptions.first,
      //     );
      //   }
      //   //_selectedDisaster = initialDropdownValue;
      //   if (widget.editData != null) {
      //     // Chế độ sửa: Giải mã danh sách ảnh cũ để hiển thị lên giao diện Form
      //     final String oldJsonPaths = widget.editData!['image_path'] ?? '[]';
      //     try {
      //       final List<dynamic> decoded = jsonDecode(oldJsonPaths);

      //       setState(() {
      //         _selectedImages.clear();
      //         // Chuyển các đường dẫn String thành các đối tượng File (hoặc XFile tùy thư viện ảnh của bạn)
      //         _selectedImages.addAll(
      //           decoded.map((path) => File(path.toString())).toList(),
      //         );
      //       });
      //     } catch (e) {
      //       print("Lỗi nạp ảnh cũ ở chế độ sửa: $e");
      //     }
      //   }
      // };
      if (isEditMode && widget.editData != null) {
        // Nạp cấu hình Dropdown cũ
        if (data.isNotEmpty) {
          tempDropdownValue = data.firstWhere(
            (element) => element.id == widget.editData!['disaster_type_id'],
            orElse: () => data.first,
          );
        }

        // Giải mã danh sách ảnh cũ ẩn trong JSON chuỗi
        final String oldJsonPaths = widget.editData!['image_path'] ?? '[]';
        try {
          final List<dynamic> decoded = jsonDecode(oldJsonPaths);
          for (var path in decoded) {
            final file = File(path.toString());
            if (file.existsSync()) {
              tempImages.add(file);
            }
          }
        } catch (e) {
          //print("Lỗi nạp ảnh cũ ở chế độ sửa: $e");
          showToastNotification(
            context,
            id: 'danger',
            description: "Lỗi nạp ảnh cũ ở chế độ sửa: $e",
          );
        }
      }

      // Cập nhật giao diện an toàn sau khi chuẩn bị xong dữ liệu
      setState(() {
        _disasterOptions = data;
        initialDropdownValue = tempDropdownValue;
        _selectedImages.clear();
        _selectedImages.addAll(tempImages);
        _isLoading = false; // Tắt vòng xoay loading
      });
    } catch (e) {
      //print("Lỗi khởi tạo FormWidget: $e");
      showToastNotification(
        context,
        id: 'danger',
        description: "Lỗi khởi tạo FormWidget: $e",
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  };
  // HÀM HELPER: Xử lý lưu file ảnh tạm vào thư mục tài liệu an toàn của App
  Future<String?> _saveImageToAppDirectory(File imageFile) async {
    try {
      // 1. Lấy thư mục Document gốc của ứng dụng bằng path_provider
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();

      // 2. Tạo tên file duy nhất tránh trùng lặp bằng timestamp + đuôi mở rộng gốc của ảnh
      String fileName =
          'disaster_${DateTime.now().millisecondsSinceEpoch}${p.extension(imageFile.path)}';

      // 3. Nối đường dẫn thư mục với tên file mới
      String targetPath = p.join(appDocumentsDir.path, fileName);

      // 4. Copy tệp tin vật lý vào ổ cứng của ứng dụng
      File savedFile = await imageFile.copy(targetPath);

      return savedFile.path; // Trả về đường dẫn tuyệt đối (String)
    } catch (e) {
      showToastNotification(
        context,
        id: 'danger',
        description: "Lỗi lưu ảnh bằng path_provider trong FormWidget: $e",
      );
      return null;
    }
  }

  // HÀM HELPER 2: Xử lý lưu TẤT CẢ ảnh từ một danh sách (HÀM MỚI)
  Future<List<String>> _saveAllImagesToAppDirectory(
    List<File> imageFiles,
  ) async {
    List<String> savedPaths = [];

    for (File file in imageFiles) {
      // Gọi lại hàm helper 1 của bạn để lưu từng ảnh một
      String? savedPath = await _saveImageToAppDirectory(file);

      if (savedPath != null) {
        savedPaths.add(savedPath); // Gom đường dẫn thành công vào mảng
      }
    }

    return savedPaths; // Trả về danh sách các đường dẫn chuỗi (List<String>)
  }

  @override
  void dispose() {
    // Xóa sạch mảng bộ nhớ đệm khi đóng màn hình để giải phóng RAM
    _selectedImages.clear();
    _disasterOptions.clear();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context)
            .viewInsets
            .bottom, //tự động đẩy giao diện lên phía trên để các ô ko bị bàn phím che khuất
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height *
              0.95, // Tăng nhẹ để vừa khít ô dropdown mới
        ),
        child: SafeArea(
          top: false,
          child: _isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  // Bọc toàn bộ nội dung bằng FormBuilder
                  child: FormBuilder(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode
                        .onUserInteraction, // Tự động validate khi user gõ/chọn
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thanh gạch ngang nhỏ định hướng vuốt xuống
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Text(
                              "Thêm thiên tai mới",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              constraints:
                                  const BoxConstraints(), //hằng số compline time, reuse, ko tính toán lại bố cục khi màn hình cập nhật
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // 1. Ô CHỌN LOẠI THIÊN TAI (Dropdown)
                        FormBuilderDropdown<DisasterType>(
                          name: 'disaster_type',
                          borderRadius: BorderRadius.circular(16),

                          menuMaxHeight: 300,

                          decoration: InputDecoration(
                            labelText: 'Chọn loại thiên tai *',

                            labelStyle: TextStyle(color: Colors.blue[800]),
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          initialValue: initialDropdownValue,
                          items: _disasterOptions.map((disaster) {
                            return DropdownMenuItem<DisasterType>(
                              value: disaster,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .transparent, // Không màu nếu không được chọn

                                  borderRadius: BorderRadius.circular(
                                    6,
                                  ), // Bo góc nhẹ cho item được chọn
                                ),
                                child: Text(
                                  disaster.nameDisaster ?? 'ko rõ',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors
                                        .black87, // Màu chữ của từng item trong menu
                                  ),
                                ),
                                //),
                              ),
                            );
                          }).toList(),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'Vui lòng chọn loại thiên tai',
                            ),
                          ]),
                        ),
                        const SizedBox(height: 15),

                        // 2. Ô NHẬP TIÊU ĐỀ THẢM HỌA
                        FormBuilderTextField(
                          name: 'title',
                          initialValue: isEditMode
                              ? widget.editData!['title']
                              : null,
                          decoration: InputDecoration(
                            labelText: "Tên",
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            hintText: "Ví dụ: bão Yagi",
                            hintStyle: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 18,
                            ),
                          ),
                          validator: FormBuilderValidators.compose([
                            //kết hợp nhiều đk ktra
                            FormBuilderValidators.required(
                              errorText: 'Vui lòng nhập tên thiên tai',
                            ),
                            FormBuilderValidators.maxLength(
                              100,
                              errorText: 'Tiêu đề quá dài',
                            ),
                          ]),
                        ),
                        const SizedBox(height: 15),

                        // 3. Ô NHẬP MÔ TẢ CHI TIẾT
                        FormBuilderTextField(
                          name: 'description',
                          initialValue: isEditMode
                              ? widget.editData!['description']
                              : null,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: "Mô tả",
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            hintText: "Vị trí, thời gian, mức độ thiệt hại...",
                            hintStyle: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Hiển thị Toạ độ
                        Row(
                          children: [
                            // Ô Vĩ độ (Latitude)
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'latitude',
                                enabled: false, // Khoá không cho sửa
                                initialValue: widget.position.latitude
                                    .toStringAsFixed(3),
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: "Vĩ độ (Latitude)*",
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ), // Viền màu đen
                                  ),
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors
                                      .grey[100], // Tạo hiệu ứng mờ ô bị khoá
                                  suffixIcon: const Icon(
                                    Icons.lock_outline,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15), // Khoảng cách giữa 2 ô
                            // Ô Kinh độ (Longitude)
                            Expanded(
                              child: FormBuilderTextField(
                                name: 'longitude',
                                enabled: false, // Khoá không cho sửa
                                initialValue: widget.position.longitude
                                    .toStringAsFixed(3),
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: "Kinh độ (Longtitude)*",

                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ), // Viền màu đen
                                  ),
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors
                                      .grey[100], // Tạo hiệu ứng mờ ô bị khoá
                                  suffixIcon: const Icon(
                                    Icons.lock_outline,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Text("Hình ảnh"),
                        const SizedBox(height: 8),
                        ImagePreview(
                          images: _selectedImages,
                          onAddPressed: () {
                            // Gọi MediaService để hiển thị BottomSheet chọn nguồn ảnh
                            MediaService.showImageSourceBottomSheet(
                              context: context,
                              onImageSelected: (File file) {
                                setState(() {
                                  _selectedImages.add(file);
                                });
                              },
                              onMultiImageSelected: (List<File> files) {
                                setState(() {
                                  _selectedImages.addAll(files);
                                });
                              },
                            );
                          },
                          onRemovePressed: (int index) {
                            // Xử lý xóa ảnh theo vị trí index
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                        ),
                        // Cụm nút bấm hành động
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Hủy",
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 17,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                // Size(chiều_rộng, chiều_cao)
                                minimumSize: const Size(150, 50),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  // 1. Kiểm tra tính hợp lệ của Form trước khi lưu
                                  if (_formKey.currentState
                                          ?.saveAndValidate() ??
                                      false) {
                                    // Lấy dữ liệu từ Form
                                    Map<String, dynamic> formData =
                                        _formKey.currentState!.value;

                                    DateTime now = DateTime.now();
                                    String formatTime = DateFormat(
                                      'dd/M/yyyy - HH:mm',
                                    ).format(now);

                                    String jsonImagePaths =
                                        '[]'; // Nếu không có ảnh -> json rỗng

                                    // 2. Xử lý lưu toàn bộ danh sách ảnh
                                    if (_selectedImages.isNotEmpty) {
                                      List<String> listPaths =
                                          await _saveAllImagesToAppDirectory(
                                            _selectedImages,
                                          );
                                      jsonImagePaths = jsonEncode(listPaths);
                                    }

                                    // 3. Hiển thị thông báo Toast thành công
                                    showToastNotification(
                                      context,
                                      id: 'success',
                                      title: 'Thành công',
                                      description: isEditMode
                                          ? 'Đã cập nhật thảm họa'
                                          : 'Đã thêm báo cáo thảm hoạ',
                                      duration: const Duration(seconds: 3),
                                      position: ToastNotificationPosition.top,
                                    );

                                    // 4. Đóng form + gửi dữ liệu ngược về màn hình cha (Map)
                                    Map<String, dynamic> returnData = {
                                      "disaster_type":
                                          formData['disaster_type'],
                                      "title": formData['title'],
                                      "description": formData['description'],
                                      "position": widget.position,
                                      "image_path":
                                          jsonImagePaths, // Đã đổi tên key cho chuẩn nhiều ảnh
                                      "create_time": isEditMode
                                          ? widget.editData!['create_time']
                                          : formatTime,
                                      "update_time": formatTime,
                                    };
                                    bool isSuccess = false;
                                    if (widget.editData != null) {
                                      final int reportId =
                                          widget.editData!['id'];
                                      isSuccess = await controller
                                          .updateReportedDisaster(
                                            reportId,
                                            returnData,
                                          );
                                    } else {
                                      isSuccess = await controller
                                          .saveReportedDisaster(
                                            context,
                                            returnData,
                                          );
                                    }
                                    if (isSuccess && mounted) {
                                      Navigator.pop(context, true);
                                    }
                                  }
                                }, // Kết thúc onPressed hợp lệ
                                child: Text(
                                  isEditMode ? "Cập nhật" : "Thêm mới",
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ), // Kết thúc child hợp lệ
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
