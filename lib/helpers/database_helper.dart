import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;

  DatabaseHelper._instance();

  String taskTable = 'task_table';
  String id = 'id';
  String title = 'title';
  String date = 'date';
  String priority = 'priority';
  String status = 'status';

  // Task Table
  // id | table | date | priority | status
  // 0     ''      ''       ''        0
  // 1     ''      ''       ''        0
  // 2     ''      ''       ''        0

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDB();
    }

    return _db;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + '/todo_list.db';
    final todoListDB =
        await openDatabase(path, version: 1, onCreate: _createDB);

    return todoListDB;
  }

  void _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $taskTable($id INTEGER PRIMARY KEY AUTOINCREMENT, $title TEXT, $date TEXT, $priority TEXT, $status INTEGER)',
    );
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(taskTable);

    return result;
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });

    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));

    return taskList;
  }

  Future<int> insertTask(Task task) async {
    Database db = await this.db;
    final int result = await db.insert(taskTable, task.toMap());

    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(
      taskTable,
      task.toMap(),
      where: '$id = ?',
      whereArgs: [task.id],
    );

    return result;
  }

  Future<int> deleteTask(Task task) async {
    print(id);
    Database db = await this.db;
    final int result = await db.delete(
      taskTable,
      where: '$id = ?',
      whereArgs: [task.id],
    );

    return result;
  }
}
