import 'package:flutter/cupertino.dart';
import 'package:mongodb_realm/syncable.dart';
import 'package:todo_app_embbedv2/domain/todo_item.dart';
import 'package:uuid/uuid.dart';

class TodoList implements Syncable<TodoList> {
  final String _id;
  final List<TodoItem> _items;

  TodoList() : _id = Uuid().v4(), _items = [];
  const TodoList._(String id, List<TodoItem> items) : _id = id, _items = items;

  TodoList add(TodoItem item) =>
      TodoList._(_id, [item, ..._items]);

  TodoList remove(TodoItem item) =>
      TodoList._(
          _id,
          _items
              .where((element) => element.identity() != item.identity())
              .toList());

  TodoList toggleComplete(TodoItem item) =>
      TodoList._(
          _id,
          _items
              .map((e) => e.identity() == item.identity()
                ? e.withComplete(!e.complete)
                : e)
              .toList());

  TodoList setItemTitle(TodoItem item, String title) =>
      TodoList._(
          _id,
          _items
              .map((e) => e.identity() == item.identity()
                ? e.withTitle(title)
                : e)
              .toList());

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