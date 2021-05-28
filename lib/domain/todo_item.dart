import 'package:flutter/cupertino.dart';
import 'package:mongodb_realm/syncable.dart';
import 'package:uuid/uuid.dart';

class TodoItem implements Syncable<TodoItem> {
  final String _id;
  String title;
  bool complete = false;

  TodoItem(this.title) : _id = Uuid().v4();

  @override
  String identity() => _id;

  @override
  Sync<TodoItem> content() => TodoItemSync(title: title, complete: complete);
}

class TodoItemSync implements Sync<TodoItem> {
  TodoItemSync({@required String title, @required bool complete});
}