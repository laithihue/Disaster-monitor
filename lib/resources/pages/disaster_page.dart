import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:disaster_app/resources/widgets/map_widget/map_widget.dart';

import '../widgets/list_widget/list_widget.dart';

class DisasterPage extends NyStatefulWidget {
  static RouteView path = ("/disaster", (_) => DisasterPage());

  DisasterPage({super.key}) : super(child: () => _DisasterPageState());
}

class _DisasterPageState extends NyPage<DisasterPage> {
  @override
  get init => () {};

  @override
  bool get stateManaged => false;

  @override
  Widget view(BuildContext context) {
    return DefaultTabController(
      length: 2, //số tab
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            "Giám sát thiên tai",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.map), text: "Bản đồ"),
              Tab(icon: Icon(Icons.list), text: "Danh sách"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            //nd tab 1
            MapWidget(),
            //nd tab 2
            //Center(child: Text("dsach")),
            ListWidget(),
          ],
        ),
      ),
    );
  }
}
