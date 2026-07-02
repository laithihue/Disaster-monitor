// import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../../../app/controllers/disaster_controller.dart';
import '../../../app/controllers/disaster_repository.dart';
// import '../marker/marker_detail.dart';
import 'detail_filter_widget.dart';
import 'disaster_card.dart';
import 'filter_menu.dart';

class ListWidget extends StatefulWidget {
  const ListWidget({super.key});
  @override
  createState() => _ListWidgetState();
}

class _ListWidgetState extends NyState<ListWidget> {
  final DisasterController _controller = DisasterController();
  //final DisasterRepository _repository = DisasterRepository();
  final TextEditingController _searchController = TextEditingController();

  //@override
  // boot() async {
  //   super.init();
  //   stateName = 'disaster_data_provider';
  //   await _controller.fetchDisaster(-1);
  // }
  @override
  get init => () async {
    //await _controller.fetchDisaster(-1);
    await _controller.fetchSortedReports();
  };

  @override
  Future<void> stateUpdated(dynamic data) async {
    super.stateUpdated(data);
    setState(() {});
  }
  //List<Map<String, dynamic>> disasters = [];

  // @override
  // Future<void> stateUpdated(dynamic data) async {
  //   // 1. Gán dữ liệu mới vào biến của Class
  //   setState(() {
  //     if (data is List) {
  //       this.disasters = List<Map<String, dynamic>>.from(data);
  //     } else {
  //       this.disasters = [];
  //     }
  //   });
  // }

  void _executeSearch(String query) async {
    await _controller.executeSearch(query);
    setState(() {});
  }

  void _handleMenuAction(String action) async {
    String sortType = 'create_desc'; // Mặc định nếu không khớp

    if (action == 'sort_az') {
      sortType = 'alpha_asc';
    } else if (action == 'update') {
      sortType = 'update_desc';
    } else if (action == 'create_desc') {
      sortType = 'create_desc';
    } else if (action == 'create_asc') {
      sortType = 'create_asc';
    }
    await _controller.executeFilter(sortType);
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose(); // Đừng quên giải phóng bộ nhớ khi hủy widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disasters = _controller.disasters;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        title: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên hoặc ...',
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _executeSearch(_searchController.text);
                      },
                    ),
                    // Thêm thuộc tính này vào InputDecoration của TextField
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear(); // Xóa chữ trong ô
                              _executeSearch(''); // Hiển thị lại toàn bộ list
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      //borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 15.0,
                    ),
                  ),

                  onSubmitted: (value) {
                    _executeSearch(value);
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              FilterMenu(onSelected: _handleMenuAction),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailFilter(
            onFilterChanged: (id) {
              _controller.fetchDisaster(id);
              setState(() {});
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Tìm thấy ${disasters.length} thảm hoạ'),
          ),

          Expanded(
            child: disasters.isEmpty
                ? const Center(child: Text("Chưa có dữ liệu"))
                : ListView.builder(
                    itemCount: disasters.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemBuilder: (context, index) {
                      final item = disasters[index];
                      return DisasterCard(
                        item: item,
                        onRefresh: () async {
                          await _controller.fetchSortedReports();
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
