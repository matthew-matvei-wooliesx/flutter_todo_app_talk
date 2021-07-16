import 'package:mongodb_realm/syncable.dart';
import 'package:uuid/uuid.dart';

/// An individual item on a to-do list.
///
/// This is implemented as a simple immutable object. Note that while each item
/// has an [id] property, this only needs to be unique within the to-do list it
/// appears on, and is not intended to be used for data persistence purposes.
class TodoItem {
  final String id;
  final String title;
  final bool complete;

  TodoItem(this.title) : id = Uuid().v4(), complete = false;
  const TodoItem._(String id, {this.title, this.complete}) : id = id;

  TodoItem.parse(dynamic data) :
        id = Uuid().v4(),
        title = data["title"],
        complete = data["complete"];

  TodoItem copyWith({String title = null, bool complete = null}) =>
    TodoItem._(id, title: title ?? this.title, complete: complete ?? this.complete);
}

class TodoItemSync implements MapSync {
  final String _title;
  final bool _complete;

  TodoItemSync({String title, bool complete}) : _title = title, _complete = complete;

  @override
  Map payload() => Map.fromEntries(
      [
        MapEntry("title", _title), MapEntry("complete", _complete)
      ]);

}