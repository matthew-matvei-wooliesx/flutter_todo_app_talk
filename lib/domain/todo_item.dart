import 'package:mongodb_realm/syncable.dart';
import 'package:uuid/uuid.dart';

class TodoItem implements Syncable {
  final String _id;
  String title;
  bool complete = false;

  TodoItem(this.title) : _id = Uuid().v4();

  @override
  String identity() => _id;

  @override
  // TODO: implement content by JSON-serialising this model
  String content() => throw UnimplementedError();
}