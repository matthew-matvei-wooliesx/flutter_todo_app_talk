import 'package:flutter/cupertino.dart';
import 'package:mongodb_realm/syncable.dart';
import 'package:uuid/uuid.dart';

class TodoItem {
  final String id;
  final String title;
  final bool complete;

  TodoItem(this.title) : id = Uuid().v4(), complete = false;
  const TodoItem._(String id, {this.title, this.complete}) : id = id;

  TodoItem withTitle(String title) =>
      TodoItem._(id, title: title, complete: complete);

  TodoItem withComplete(bool complete) =>
      TodoItem._(id, title: title, complete: complete);
}
