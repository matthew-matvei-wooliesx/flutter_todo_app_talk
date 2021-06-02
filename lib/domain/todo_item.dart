import 'package:flutter/cupertino.dart';
import 'package:mongodb_realm/syncable.dart';
import 'package:uuid/uuid.dart';

class TodoItem implements Syncable<TodoItem> {
  final String _id;
  final String title;
  final bool complete;

  TodoItem(this.title) : _id = Uuid().v4(), complete = false;
  const TodoItem._(String id, {this.title, this.complete}) : _id = id;

  TodoItem withTitle(String title) =>
      TodoItem._(_id, title: title, complete: complete);

  TodoItem withComplete(bool complete) =>
      TodoItem._(_id, title: title, complete: complete);

  @override
  String identity() => _id;

  @override
  Sync<TodoItem> content() => TodoItemSync(title: title, complete: complete);
}

class TodoItemSync implements Sync<TodoItem> {
  TodoItemSync({@required String title, @required bool complete});
}