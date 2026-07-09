import 'package:flutter/material.dart';
import 'package:trying_flutter/utils/models/activity_model.dart';

class ActivityListWidget extends StatelessWidget {
  const ActivityListWidget({super.key, required this.activityModelStore});
  final List<ActivityModel> activityModelStore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 400,
      child: ListView.builder(
        itemCount: activityModelStore.length,
        itemBuilder: (context, index) {
          ActivityModel item = activityModelStore[index];

          return ListTile(title: Text(item.activityDate));
        },
      ), // ListView.builder
    ); // Container
  }
}

// import 'package:flutter/material.dart';
// import 'package:trying_flutter/utils/models/activity_model.dart';

// class ActivityListWidget extends StatelessWidget {
//   const ActivityListWidget({super.key, required this.activityModelStore});
//   final List<ActivityModel> activityModelStore;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       height: 400,
//       child: ListView.builder(
//         itemCount: activityModelStore.length,
//         itemBuilder: (context, index) {
//           ActivityModel item = activityModelStore[index];

         
//           return ListTile(
//             leading: const Icon(Icons.fitness_center, color: Colors.deepPurple),
//             title: Text(item.exerciseName),
//             subtitle: Text(item.activityDate),
//             trailing: Text("${item.kcalExpense} kcal", style: const TextStyle(color: Colors.red)),
//           );
//         },
//       ), // ListView.builder
//     ); // Container
//   }
// }