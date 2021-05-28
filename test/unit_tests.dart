import 'package:test/test.dart';
import 'package:todo_app_embbedv2/domain/todo_item.dart';
import 'package:todo_app_embbedv2/main.dart';

void main(){
  group('Home', () {
    test('item list should be empty', () {
      final homeState = HomeState();
      expect(homeState.todoList.count, 0);
    });

    test('item list should have 1 item and it should be an instance of Todo class', () {
      final homeState = HomeState();
      var item = TodoItem('new test todo');

      homeState.addItem(item);
      expect(homeState.todoList.count, 1);

      item = homeState.todoList[0];
      expect(item.runtimeType, TodoItem);
    });

    test('item in list should be modified', () {
      final homeState = HomeState();
      var item = TodoItem('new test todo');

      homeState.addItem(item);
      item.title = 'edited test todo';

      expect(item.title, 'edited test todo');
    });

    test('item in list should be deleted and list should be empty again', () {
      final homeState = HomeState();
      var item = TodoItem('new test todo');

      homeState.addItem(item);
      homeState.deleteItem(item);

      expect(homeState.todoList.count, 0);
    });
  });
}