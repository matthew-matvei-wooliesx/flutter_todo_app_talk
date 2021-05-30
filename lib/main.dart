import 'package:flutter/material.dart';
import 'package:mongodb_realm/sync_store.dart';
import 'package:todo_app_embbedv2/domain/todo_item.dart';
import 'package:todo_app_embbedv2/domain/todo_list.dart';
import 'package:todo_app_embbedv2/new_todo.dart';

import 'package:mongodb_realm/mongodb_realm.dart';

void main() => runApp(Main());

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
  HomeState createState() => HomeState(SyncStore());
}

class HomeState extends State<Home> with TickerProviderStateMixin {
  final SyncStore _syncStore;
  var todoList = TodoList();
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
  AnimationController emptyListController;

  HomeState(SyncStore syncStore) : _syncStore = syncStore;

  @override
  void initState() {
    emptyListController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    emptyListController.forward();
    super.initState();

    // Simple test by logging platform version using MongoDB Realm Plugin
    MongodbRealm.platformVersion.then((version) => print("Currently running version $version"));
  }

  @override
  void dispose() {
    emptyListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FlutterTodo',
          key: Key('main-app-title'),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () =>goToNewItemView(),
      ),
      body: renderBody()
    );
  }

  Widget renderBody(){
    if (todoList.isEmpty) {
      return emptyList();
    } else {
      return buildListView();
    }
  }
  
  Widget emptyList(){
    return Center(
    child: FadeTransition(
      opacity: emptyListController,
      child: Text('No items')
    )
    );
  }

  Widget buildListView() {
    return AnimatedList(
      key: animatedListKey,
      initialItemCount: todoList.count,
      itemBuilder: (BuildContext context,int index, animation){
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
      onTap: () => toggleItemComplete(item),
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

  Future toggleItemComplete(TodoItem item) async {
    item.complete = !item.complete;
    await _syncStore.update(item);
    setState(() { });
  }

  void goToNewItemView(){
    // Here we are pushing the new view into the Navigator stack. By using a
    // MaterialPageRoute we get standard behaviour of a Material app, which will
    // show a back button automatically for each platform on the left top corner
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return NewTodoView();
    })).then((title){
      if(title != null) {
        setState(() {
          addItem(TodoItem(title));
        });
      }
    });
  }

  void addItem(TodoItem item){
    todoList.add(item);
    if(animatedListKey.currentState != null)
      animatedListKey.currentState.insertItem(0);
  }

  void goToEditItemView(TodoItem item){
    // We re-use the NewTodoView and push it to the Navigator stack just like
    // before, but now we send the title of the item on the class constructor
    // and expect a new title to be returned so that we can edit the item
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return NewTodoView(item: item);
    })).then((title) {
      if(title != null) {
        setItemTitle(item, title);
      }
    });
  }

  void setItemTitle(TodoItem item, String title) {
    item.title = title;
  }

  void removeItemFromList(TodoItem item, int index) {
    animatedListKey.currentState.removeItem(index, (context, animation) {
      return SizedBox(width: 0, height: 0,);
    });

    deleteItem(item);
  }

  void deleteItem(TodoItem item){
    todoList.remove(item);

    if (todoList.isNotEmpty || emptyListController == null) {
      return;
    }

    emptyListController.reset();
    setState(() {});
    emptyListController.forward();
  }
}