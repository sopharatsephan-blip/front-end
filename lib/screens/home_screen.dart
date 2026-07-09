import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trying_flutter/utils/models/activity_model.dart'; // วิ่งเข้า utils/models
import 'package:trying_flutter/utils/app_api.dart';                 // วิ่งเข้า utils
import 'package:trying_flutter/widgets/activity_list_widget.dart';   // วิ่งเข้า widgets
import 'package:trying_flutter/widgets/kcal_summary_widget.dart';   // วิ่งเข้า widgets



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ActivityModel> activityModelStore = [];

  void _fetchData() async {
    var response = await AppAPI.get("/activities/get_all_by_user");
    Map<String, dynamic> json = jsonDecode(response.body);
    ActivityResponse activityResponse = ActivityResponse.fromJson(json);

    setState(() {
      activityModelStore = activityResponse.data;
    });
  }

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Home Screen"),
      ), 
      body: Column(
        children: [
          KCalSummary(activityModelStore: activityModelStore),
          ActivityListWidget(activityModelStore: activityModelStore),
        ],
      ), 
    ); 
  }
}