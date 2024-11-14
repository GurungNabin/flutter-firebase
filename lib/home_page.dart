import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_tutorial/add_new_task.dart';
import 'package:flutter_firebase_tutorial/utils.dart';
import 'package:flutter_firebase_tutorial/widgets/date_selector.dart';
import 'package:flutter_firebase_tutorial/widgets/task_card.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List<DocumentSnapshot> tasks = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewTask(),
                ),
              );
            },
            icon: const Icon(
              CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const DateSelector(),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .where('uId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No data found'),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var taskData = snapshot.data!.docs[index].data();
                      var formattedDate = DateFormat('MM/dd/yyyy')
                          .format(taskData['date'].toDate());
                      print('object ${snapshot.data!.docs[index].id}');
                      return Dismissible(
                        key: ValueKey(index),
                        onDismissed: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            await FirebaseFirestore.instance
                                .collection('tasks')
                                .doc(snapshot.data!.docs[index].id)
                                .delete();
                            // Manually trigger a rebuild after deletion
                            setState(() {
                              snapshot.data!.docs.removeAt(index);
                            });

                            // await FirebaseFirestore.instance
                            //     .collection('tasks')
                            //     .doc(snapshot.data!.docs[index].id)
                            //     .update({
                            //   'newField': 'newValue',
                            //   'color': 'fffffff'
                            // });
                          }
                        },
                        // onDismissed: (direction) {
                        //   setState(() {
                        //     tasks.removeAt(index);
                        //   });
                        //   // Optionally, delete the task from Firestore
                        //   FirebaseFirestore.instance
                        //       .collection('tasks')
                        //       .doc(tasks[index].id)
                        //       .delete();
                        // },
                        child: Row(
                          children: [
                            Expanded(
                              child: TaskCard(
                                color: hexToColor(
                                    snapshot.data!.docs[index].data()['color']),
                                headerText:
                                    snapshot.data!.docs[index].data()['title'],
                                descriptionText: snapshot.data!.docs[index]
                                    .data()['description'],
                                scheduledDate: formattedDate,
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: snapshot.data!.docs[index]
                                          .data()['imageURL'] ==
                                      null
                                  ? const Icon(
                                      Icons.image_not_supported,
                                      size: 30,
                                    )
                                  : Image.network(
                                      snapshot.data!.docs[index]
                                          .data()['imageURL'],
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                '10:00AM',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
