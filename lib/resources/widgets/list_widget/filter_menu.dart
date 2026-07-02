import 'package:flutter/material.dart';

class FilterMenu extends StatelessWidget {
  final ValueChanged<String> onSelected;
  //hàm onSelected khi đc gọi bắt bc truyền vào 1 chuỗi String, ko cần trả về gtri j
  //= final void Function(String) onSelected;
  const FilterMenu({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      child: const Icon(Icons.tune, color: Colors.blue),
      onSelected: onSelected,

      //(String value) => {print("Đã nhána lọc $value")},
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'update',
          child: Row(
            children: [
              Icon(Icons.refresh),
              SizedBox(width: 10),
              Text("Thời gian cập nhật"),
            ],
          ),
        ),

        const PopupMenuItem<String>(
          value: 'create_desc',
          child: Row(
            children: [
              Icon(Icons.add_circle_outline),
              SizedBox(width: 10),
              Text("Ngày tạo: mới nhất"),
            ],
          ),
        ),

        const PopupMenuItem<String>(
          value: 'create_asc',
          child: Row(
            children: [
              Icon(Icons.add_circle_outline),
              SizedBox(width: 10),
              Text("Ngày tạo: cũ nhất"),
            ],
          ),
        ),

        const PopupMenuItem<String>(
          value: 'sort_az',
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha),
              SizedBox(width: 10),
              Text("Tên A-Z"),
            ],
          ),
        ),
      ],
    );
  }
}
