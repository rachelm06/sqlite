import 'package:flutter/material.dart';
import 'package:sqlite_demo/DatabaseHelper.dart'
void main() {
  runApp(const SqliteDemoApp());
}

class SqliteDemoApp extends StatelessWidget {
  const SqliteDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MainApp(title: 'SQLite demo'),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MainAppState createState() => _MainAppState();
}

import 'dart:async';




CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT, 
  name TEXT NOT NULL,
  age INTEGER NOT NULL, 
  email TEXT NOT NULL
)

class User {
  int? id;
  String name;
  int age;
  String email;

  User({this.id, required this.name, required this.age, required this.email});

  User.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        name = res["name"],
        age = res["age"],
        email = res["email"];

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'age': age, 'email': email};
  }
}

import 'package:flutter/services.dart';
import 'package:sqlite_demo/model/user.dart';
import 'package:sqlite_demo/utils/database_helper.dart';

class _MainAppState extends State<MainApp> {
  late DatabaseHelper dbHelper;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  bool isEditing = false;
  late User _user;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    dbHelper.initDB().whenComplete(() async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(widget.title!),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                hintText: 'Enter your name', labelText: 'Name'),
                          ),
                          TextFormField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            decoration: const InputDecoration(
                                hintText: 'Enter your age', labelText: 'Age'),
                          ),
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                                hintText: 'Enter your email',
                                labelText: 'Email'),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 10),
                                    child: ElevatedButton(
                                      onPressed: addOrEditUser,
                                      child: const Text('Submit'),
                                    )),
                              ])
                        ]))),
                Expanded(
                  flex: 1,
                  child: SafeArea(child: userWidget()),
                )
              ],
            )),
          ],
        ));
  }

  // ...
  Future<void> addOrEditUser() async {
    String email = emailController.text;
    String name = nameController.text;
    String age = ageController.text;

    if (!isEditing) {
      User user = User(name: name, age: int.parse(age), email: email);
      await addUser(user);
    } else {
      _user.email = email;
      _user.age = int.parse(age);
      _user.name = name;
      await updateUser(_user);
    }
    resetData();
    setState(() {});
  }

  Future<int> addUser(User user) async {
    return await dbHelper.insertUser(user);
  }

  Future<int> updateUser(User user) async {
    return await dbHelper.updateUser(user);
  }

  void resetData() {
    nameController.clear();
    ageController.clear();
    emailController.clear();
    isEditing = false;
  }

}

Widget userWidget() {
    return FutureBuilder(
      future: this.dbHelper.retrieveUsers(),
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, position) {
                return Dismissible(
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: const Icon(Icons.delete_forever),
                    ),
                    key: UniqueKey(),
                    onDismissed: (DismissDirection direction) async {
                      await this
                          .dbHelper
                          .deleteUser(snapshot.data![position].id!);
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => populateFields(snapshot.data![position]),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12.0, 12.0, 12.0, 6.0),
                                    child: Text(
                                      snapshot.data![position].name,
                                      style: const TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12.0, 6.0, 12.0, 12.0),
                                    child: Text(
                                      snapshot.data![position].email.toString(),
                                      style: const TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          snapshot.data![position].age
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 2.0,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ));
              });
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void populateFields(User user) {
    _user = user;
    nameController.text = _user.name;
    ageController.text = _user.age.toString();
    emailController.text = _user.email;
    isEditing = true;
}