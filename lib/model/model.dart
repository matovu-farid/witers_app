import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writers_app/created_classes/FullArticle.dart';
import 'package:writers_app/created_classes/database.dart';
import 'dart:core';
import 'package:writers_app/created_classes/writer_profile.dart';



class WritersModel with ChangeNotifier{
  var _pickerColor = Colors.black;
  var _selectedColor = Colors.black;
  TextEditingController bodyController=TextEditingController();
  TextEditingController titleController=TextEditingController();
 // Profile profile = Profile()..name=get;

  MyDatabase db = MyDatabase();
   final fireStore = FirebaseFirestore.instance;
   final auth = FirebaseAuth.instance;

  List<Map<String,String>> selectedBox ;
  List<Map<String,String>> selectedArticles ;

  _initializeSelectedArticles(){
    selectedArticles = selectedBox.where((element) => element!=null).toList();
  }
   String get user=> auth.currentUser.uid;

  int index= 0;

  List<FullArticle> articlesFetched = [];

  fetchFromFirestore()async {
    if(articlesFetched.isEmpty){
    final docRef = fireStore.collection(user).doc('articles');
    final documentSnapshot = await docRef.get();
    var map = documentSnapshot.data();

    final keys = map.keys.toList();
    for (var key in keys) {
      final articleMap = map[key];
      final title = articleMap.keys.first.toString();
      final body = articleMap.values.first.toString();
      print(title);
      print(body);
      articlesFetched.add(FullArticle(title, body));
    }
  }
  }

  upLoad()async{
    selectedArticles=[];
     final docRef= fireStore.collection(user).doc('articles');
     _initializeSelectedArticles();
     print(selectedArticles);
     if(selectedArticles.isNotEmpty){
       for(var article in selectedArticles ){
         var title = article['title'];
         var body  = article['body'];
         await docRef.set({'$title$index':{title : body}},SetOptions(merge: true));
         articlesFetched.add(FullArticle(title, body));
       }
     }
      index++;
     notifyListeners();

  }



  onChecked(int index,bool isChecked,List<Map<String,String>> list){
    if(selectedBox==null){
      selectedBox=List<Map<String,String>>(list.length);

    }


    final article =list[index];
    if (isChecked) selectedBox[index]=article;
  else {
    if(index<selectedBox.length)

      selectedBox[index] = null;
    }
    notifyListeners();
  }

  changeColor(Color selectedColorGot){
    _selectedColor= selectedColorGot;
        notifyListeners();
  }

   //FirebaseAuth auth= FirebaseAuth.instance;
  void signout(){
    Color color = Colors.white;
    auth.signOut();
    notifyListeners();
  }

  Color get selectedColor =>_selectedColor;
   Color get pickerColor =>_pickerColor;


}