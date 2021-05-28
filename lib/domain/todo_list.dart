import 'package:flutter/cupertino.dart';
import 'package:mongodb_realm/syncable.dart';
import 'package:todo_app_embbedv2/domain/todo_item.dart';
import 'package:uuid/uuid.dart';

class TodoList implements Syncable<TodoList> {
  final String _id;
  final List<TodoItem> _items = [];

  TodoList() : _id = Uuid().v4();

  void add(TodoItem item) => _items.insert(0, item);
  void remove(TodoItem item) => _items.remove(item);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int get count => _items.length;

  operator [](int i) => _items[i];

  @override
  String identity() => _id;

  @override
  Sync<TodoList> content() => TodoListSync(items: _items.map((e) => e.content()));
}

class TodoListSync implements Sync<TodoList> {
  TodoListSync({@required List<TodoItemSync> items});
}