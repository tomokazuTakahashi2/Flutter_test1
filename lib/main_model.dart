import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/todo.dart';

class MainModel extends ChangeNotifier{
  List<Todo>todoList = [];

  //One-time Read
  Future getTodoList() async{
    final snapshot = await FirebaseFirestore.instance.collection('todoList').get();
    final docs = snapshot.docs;
    final todoList = docs.map((doc) => Todo(doc)).toList();
    this.todoList = todoList;
    notifyListeners();
  }
  //Realtime changes・・・エミュレータにリアルタイム反映させる
  void getTodoListRealtime(){
    final snapdhots = FirebaseFirestore.instance.collection('todoList').snapshots();
    snapdhots.listen((snapdhot){
      final docs = snapdhot.docs;
      final todoList = docs.map((doc) => Todo(doc)).toList();
      //ソート
      todoList.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      this.todoList = todoList;
      notifyListeners();
    });
  }
}