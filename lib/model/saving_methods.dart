
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:writers_app/created_classes/FullArticle.dart';
import 'package:writers_app/created_classes/database.dart';
import 'package:writers_app/created_classes/original_article.dart';

mixin SavingMethods{
  TextEditingController bodyController=TextEditingController();
  TextEditingController titleController=TextEditingController();
  List<Widget> listOfUpLoadedTiles=[];

  MyDatabase db = MyDatabase();
  final fireStore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  List<OriginalArticle> selectedBox ;
  List<OriginalArticle> selectedArticles ;
  String get user=> auth.currentUser.uid;


  List<OriginalArticle> articlesFetched = [];

  Future<void> upLoadPicAndSaveUrl(File image) async {

      String imageURL = await uploadFile(image);
      DocumentSnapshot docSnapShot =await profilePicRef.get();
      if(!docSnapShot.exists) profilePicRef.set({"profile": imageURL});

     else  profilePicRef.update({"profile": imageURL});

  }
  DocumentReference get profilePicRef=>fireStore.collection(user).doc('profile_pic');

  Future<String> uploadFile(File _image) async {

    await deleteFromStorage();
     final storageReference =FirebaseStorage.instance.ref()
        .child('profile/${_image.path}');

    final uploadTask =await storageReference.putFile(_image);

    print('File Uploaded');
    String returnURL;
    await storageReference.getDownloadURL().then((fileURL) {
      returnURL =  fileURL;
    });
    _error;
    print('URL got');
    _error;

    return returnURL;

  }
  get _error{
    print('____________________________________________');
  }

  initializeSelectedArticles(){
    selectedArticles = selectedBox.where((element) => element!=null).toList();
  }


  initializeUploadArticles(){

  }

  Future upLoadMultipleArticles(BuildContext context)async{
    selectedArticles=[];
    final docRef= fireStore.collection(user).doc('articles');
    initializeSelectedArticles();

    fireStore.collection('users').doc('users').update({auth.currentUser.displayName:user});
    //if(fireStore.collection(user).doc('articles'))
    if(selectedArticles.isNotEmpty){
      for(var article in selectedArticles ){
        var title = article.title;
        var body  = article.body;
        var id = article.id;
        if(articlesFetched.isNotEmpty) articlesFetched.add(OriginalArticle(title, body,id));
       // DefaultTabController.of(context).animateTo(2);
        final docSnapshot = await docRef.get();
        if(!docSnapshot.exists) await docRef.set({'${title.toPlainText()}':[id,jsonEncode(title),jsonEncode(body)],});
        else  await docRef.update({'${title.toPlainText()}':[id,jsonEncode(title),jsonEncode(body)],});

      }
    }


  }

  Future deleteFromStorage() async {
    final downloadurlMap = await fireStore.collection(user).doc('profile_pic').get();
    final String downloadurl = downloadurlMap['profile'].toString();

    String fileUrl =Uri.decodeFull(downloadurl).replaceAll(RegExp(r'(\?alt).*'), '');
    final photoRef =  FirebaseStorage.instance.refFromURL(fileUrl);

    try {
      photoRef.delete();
    } on Exception catch (e) {
      print('Could not delete old pic');
    }

  }


}

