import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongodb_realm/sync_store.dart';
import 'package:mongodb_realm/syncable.dart';
import 'package:todo_app_embbedv2/domain/todo_item.dart';
import 'package:todo_app_embbedv2/domain/todo_list.dart';

class SyncedTodoListNotifier extends StateNotifier<TodoList> {
  final SyncStore<TodoList> _syncStore;

  SyncedTodoListNotifier(SyncStore<TodoList> syncStore) :
        _syncStore = syncStore,
        super(new TodoList()) {
    _hydrateTodoList();
  }

  Future add(TodoItem item) async {
    state = await _withStateChanged((s) => s.add(item));
  }

  Future remove(TodoItem item) async {
    state = await _withStateChanged((s) => s.remove(item));
  }

  Future toggleComplete(TodoItem item) async {
    state = await _withStateChanged((s) => s.toggleComplete(item));
  }

  Future setItemTitle(TodoItem item, String title) async {
    state = await _withStateChanged((s) => s.setItemTitle(item, title));
  }

  Future deleteList() async {
    await _syncStore.delete(state.identity());
    state = new TodoList();
  }

  Future<TodoList> _withStateChanged(TodoList Function(TodoList) map) async {
    final changedState = map(state);
    await _syncStore.upsert(changedState);
    return changedState;
  }

  Future _hydrateTodoList() async {
    final List<SyncableTuple> data = await _syncStore.getMany();
    if (data?.isEmpty ?? true) {
      return;
    }

    final singletonTodoList = data[0];

    state = TodoList.parse(singletonTodoList.identity, singletonTodoList.content);
  }
}