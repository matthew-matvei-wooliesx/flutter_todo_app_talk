import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mongodb_realm/sync_store.dart';
import 'package:todo_app_embbedv2/domain/todo_item.dart';
import 'package:todo_app_embbedv2/domain/todo_list.dart';
import 'package:todo_app_embbedv2/synced_todo_list_notifier.dart';
import 'package:todo_app_embbedv2/new_todo.dart';

final todoListProvider = StateNotifierProvider<SyncedTodoListNotifier, TodoList>((ref) =>
  new SyncedTodoListNotifier(new SyncStore<TodoList>("TodoList")));

final todoListCountProvider = Provider<int>((ref) => ref.watch(todoListProvider).count);

void main() => runApp(ProviderScope(child: Main()));

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterTodo',
      home: Home(),
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
  AnimationController emptyListController;

  @override
  void initState() {
    emptyListController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    emptyListController.forward();
    super.initState();
  }

  @override
  void dispose() {
    emptyListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (_, ScopedReader watch, __) {
        final todoList = watch(todoListProvider);

        return Scaffold(
            appBar: AppBar(
              title: Text(
                'FlutterTodo',
                key: Key('main-app-title'),
              ),
              centerTitle: true,
            ),
            floatingActionButton: Stack(
              children: <Widget>[
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    tooltip: 'Create item',
                    child: Icon(Icons.add),
                    onPressed: _goToNewItemView,
                    heroTag: 'Create',
                  ),
                ),
                if (todoList.isNotEmpty) Positioned(
                  bottom: 90,
                  right: 10,
                  child: FloatingActionButton(
                    tooltip: 'Reset Todo List',
                    child: Icon(Icons.delete),
                    onPressed: _deleteTodoList,
                    heroTag: 'Reset',
                  ),
                )
              ],
            ),
            body: renderBody(todoList)
        );
      },
    );
  }

  Widget renderBody(TodoList todoList) {
    return todoList.isEmpty
        ? emptyList()
        : buildListView(todoList);
  }
  
  Widget emptyList(){
    return Center(
      child: FadeTransition(
        opacity: emptyListController,
        child: Text('No items')
      )
    );
  }

  Widget buildListView(TodoList todoList) {
    return AnimatedList(
      key: animatedListKey,
      initialItemCount: todoList.count,
      itemBuilder: (BuildContext _, int index, Animation<double> animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: buildItem(todoList[index], index),
        );
      },
    );
  }

  Widget buildItem(TodoItem item, int index){
    return Dismissible(
      key: Key('${item.hashCode}'),
      background: Container(color: Colors.red[700]),
      onDismissed: (direction) => removeItemFromList(item, index),
      direction: DismissDirection.startToEnd,
      child: buildListTile(item, index),
    );
  }

  Widget buildListTile(TodoItem item, int index){
    return ListTile(
      onTap: () => context.read(todoListProvider.notifier).toggleComplete(item),
      onLongPress: () => goToEditItemView(item),
      title: Text(
        item.title,
        key: Key('item-$index'),
        style: TextStyle(
          color: item.complete ? Colors.grey : Colors.black,
          decoration: item.complete ? TextDecoration.lineThrough : null
        ),
      ),
      trailing: Icon(item.complete
        ? Icons.check_box
        : Icons.check_box_outline_blank,
        key: Key('completed-icon-$index'),
      ),
    );
  }

  void _goToNewItemView() {
    // Here we are pushing the new view into the Navigator stack. By using a
    // MaterialPageRoute we get standard behaviour of a Material app, which will
    // show a back button automatically for each platform on the left top corner
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewTodoView();
    })).then((title){
      if(title != null && title != "") {
        addItem(TodoItem(title));
      }
    });
  }

  Future addItem(TodoItem item) async {
    await context.read(todoListProvider.notifier).add(item);

    if(animatedListKey.currentState != null)
      animatedListKey.currentState.insertItem(0);
  }

  void goToEditItemView(TodoItem item){
    // We re-use the NewTodoView and push it to the Navigator stack just like
    // before, but now we send the title of the item on the class constructor
    // and expect a new title to be returned so that we can edit the item
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NewTodoView(item: item);
    })).then((title) {
      if(title != null && title != "") {
        setItemTitle(item, title);
      }
    });
  }

  Future _deleteTodoList() async {
    await context.read(todoListProvider.notifier).deleteList();
  }

  Future setItemTitle(TodoItem item, String title) async {
    await context.read(todoListProvider.notifier).setItemTitle(item, title);
  }

  Future removeItemFromList(TodoItem item, int index) async {
    animatedListKey.currentState.removeItem(index, (context, animation) {
      return SizedBox(width: 0, height: 0,);
    });

    await deleteItem(item);
  }

  Future deleteItem(TodoItem item) async {
    await context.read(todoListProvider.notifier).remove(item);
    final todoListIsNotEmpty = context.read(todoListCountProvider) > 0;

    if (todoListIsNotEmpty || emptyListController == null) {
      return;
    }

    emptyListController.reset();
    emptyListController.forward();
  }
}