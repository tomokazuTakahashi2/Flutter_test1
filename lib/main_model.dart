import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/todo.dart';

class MainModel extends ChangeNotifier {
  List<Todo> todoList = [];
  String newTodoText = '';

  //One-time Read
  Future getTodoList() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('todoList').get();
    final docs = snapshot.docs;
    final todoList = docs.map((doc) => Todo(doc)).toList();
    this.todoList = todoList;
    notifyListeners();
  }

  //Realtime changes・・・エミュレータにリアルタイム反映させる
  void getTodoListRealtime() {
    final snapdhots =
        FirebaseFirestore.instance.collection('todoList').snapshots();
    snapdhots.listen((snapdhot) {
      final docs = snapdhot.docs;
      final todoList = docs.map((doc) => Todo(doc)).toList();
      //ソート(日付が新しい順)
      todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      this.todoList = todoList;
      notifyListeners();
    });
  }

  Future add() async {
    //Firestoreの'todoList'に保存する
    final collection = FirebaseFirestore.instance.collection('todoList');
    await collection.add({
      'title': newTodoText,
      'createdAt': Timestamp.now(), //現在時刻が入る
    });
  }

  void reload() {
    notifyListeners();
  }

  //デリート処理
  Future deleteCheckedItems() async {
    //絞り込み
    final checkedItems = todoList.where((todo) => todo.isDone).toList();
    final references =
        checkedItems.map((todo) => todo.documentReference).toList();

    //FirestoreのBatch write
    WriteBatch batch = FirebaseFirestore.instance.batch();
    references.forEach((reference) {
      batch.delete(reference);
    });
    return batch.commit();
  }
  //完了ボタンを未選択の場合は半透明にする
  bool checkShouldActiveCompleteButton(){
    final checledItems =todoList.where((todo) => todo.isDone).toList();
    return checledItems.length > 0;
  }
}
