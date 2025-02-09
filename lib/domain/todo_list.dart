import 'package:flutter/cupertino.dart';
import 'package:mongodb_realm/syncable.dart';
import 'package:todo_app_embbedv2/domain/todo_item.dart';
import 'package:uuid/uuid.dart';

/// Represents the primary domain object in this application, a to-do list.
///
/// Since this class implements [Syncable], it can be stored and retrieved in a
/// Realm. Therefore, its identity must be consistent across sessions. This
/// class is implemented as an immutable data structure to improve compatibility
/// with this application's state management solution, which reacts to
/// reassignment.
class TodoList implements Syncable<TodoListSync> {
  final String _id;
  final List<TodoItem> _items;

  TodoList() : _id = Uuid().v4(), _items = [];
  const TodoList._(String id, List<TodoItem> items) : _id = id, _items = items;

  TodoList.parse(String identifier, dynamic data) :
        _id = identifier,
        _items = (data as List<dynamic>)
            .map((item) => TodoItem.parse(item))
            .toList();

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
                ? i.copyWith(complete: !i.complete)
                : i)
              .toList());

  TodoList setItemTitle(TodoItem item, String title) =>
      TodoList._(
          _id,
          _items
              .map((i) => i.id == item.id
                ? i.copyWith(title: title)
                : i)
              .toList());

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int get count => _items.length;

  operator [](int i) => _items[i];

  @override
  String identity() => _id;

  @override
  TodoListSync content() =>
      TodoListSync(items: _items
          .map((item) =>
            TodoItemSync(
                title: item.title,
                complete: item.complete))
          .toList());
}

/// Defines the persistable representation of a [TodoList].
class TodoListSync implements ListSyncableDto {
  final List<Map> _payload;

  TodoListSync({@required List<TodoItemSync> items})
      : _payload = items.map((e) => e.payload()).toList();

  @override
  List payload() => _payload;
}
