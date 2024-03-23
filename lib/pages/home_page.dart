import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  _HomePageState();

  late double _deviceHeight;
  Box? _box;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.15,
        title: const Text(
          "Taskly!",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskView() {
    // UI widgets cannot be asynchronous, so use FutureBuilder instead of async/await
    // The builder function is called once the future function has finished
    return FutureBuilder(
      future: Hive.openBox("tasks"),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // Once the connection is done, show the list of tasks
        if (snapshot.hasData) {
          _box = snapshot.data;
          return _taskList();
        }
        // Meanwhile, show a loading indicator
        else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _taskList() {
    // Getting tasks from the box (_box! means we are sure that _box is set, so we can get its values)
    List tasks = _box!.values.toList();

    // ListView has a "builder" factory method to create ListTile elements from a list
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        // Create a task element from each item in the list of tasks
        Task task = Task.fromMap(tasks[index]);

        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: task.done ? TextDecoration.lineThrough : null),
          ),
          subtitle: Text(
            task.timestamp.toString(),
          ),
          trailing: Icon(
            task.done
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () {
            task.done = !task.done;
            _box?.putAt(index, task.toMap());
            setState(() {});
          },
          onLongPress: () {
            _box?.deleteAt(index);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
        onPressed: () {
          _addTaskShowDialog();
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ));
  }

  void _addTaskShowDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Add Task",
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          content: TextField(
            onSubmitted: (value) {
              if (value != "") {
                Task task = Task(
                    content: value, timestamp: DateTime.now(), done: false);
                _box!.add(task.toMap());
              }
              setState(() {});
              Navigator.pop(context);
            },
            onChanged: (value) {},
          ),
        );
      },
    );
  }
}
