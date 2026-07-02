import 'dart:typed_data';

import 'package:disaster_app/app/models/disaster_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../../../app/controllers/disaster_controller.dart';

class DetailFilter extends StatefulWidget {
  final Function(int? disasterTypeId)
  onFilterChanged; //truyền id ra màn hình cha
  const DetailFilter({super.key, required this.onFilterChanged});

  @override
  createState() => _DetailFilterState();
}

class _DetailFilterState extends NyState<DetailFilter> {
  final DisasterController controller = DisasterController();
  int _selectedIndex = 0;
  final DisasterType disasterImage = DisasterType(id: null);
  //List<DisasterType> filters = [];
  List<DisasterType> filters = [
    DisasterType(id: -1, nameDisaster: 'Tất cả', image: null),
  ];
  void loadFilter() async {
    final List<DisasterType> disasterTypes = await controller.getDisasterType(
      context,
    );
    setState(() {
      // Reset lại mảng tránh trùng lặp khi gọi lại hàm
      filters = [DisasterType(id: -1, nameDisaster: 'Tất cả', image: null)];
      filters.addAll(disasterTypes);
    });
  }

  @override
  get init => () {
    loadFilter();
  };

  @override
  Widget view(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(16.0),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = (_selectedIndex == index);

          final item = filters[index];
          final String? name = item.nameDisaster ?? '';
          //final String? image = item['image'];
          //final Uint8List? uint8ListBytes = disasterImage.imageBytes;
          final Uint8List? uint8ListBytes = item.imageBytes;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onFilterChanged(item.id);
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 12.0),
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
              child: Row(
                children: [
                  if (uint8ListBytes != null && uint8ListBytes.isNotEmpty)
                    SvgPicture.memory(
                      uint8ListBytes,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Trường hợp chuỗi base64 bị lỗi mã hóa hoặc hỏng dữ liệu
                        return const Icon(
                          Icons.broken_image,
                          color: Colors.red,
                          size: 32,
                        );
                      },
                    ),

                  Text(
                    name!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
