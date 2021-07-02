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
              .where((i) => i.id != item.id)
              .toList());

  TodoList toggleComplete(TodoItem item) =>
      TodoList._(
          _id,
          _items
              .map((i) => i.id == item.id
                ? i.withComplete(!i.complete)
                : i)
              .toList());

  TodoList setItemTitle(TodoItem item, String title) =>
      TodoList._(
          _id,
          _items
              .map((i) => i.id == item.id
                ? i.withTitle(title)
                : i)
              .toList());

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int get count => _items.length;

  operator [](int i) => _items[i];

  @override
  String identity() => _id;

  @override
  Sync<TodoList> content() =>
      TodoListSync(items: _items
          .map((item) =>
            _TodoItemSync(
                title: item.title,
                complete: item.complete))
          .toList());
}

class TodoListSync implements ListSync<TodoList> {
  final List<Map> _payload;

  TodoListSync({@required List<_TodoItemSync> items})
      : _payload = items.map((e) => e.payload()).toList();

  @override
  List payload() => _payload;
}

class _TodoItemSync implements MapSync<_TodoItemSync> {
  final String _title;
  final bool _complete;

  _TodoItemSync({String title, bool complete}) : _title = title, _complete = complete;

  @override
  Map payload() => Map.fromEntries(
      [
        MapEntry("title", _title), MapEntry("complete", _complete)
      ]);

}