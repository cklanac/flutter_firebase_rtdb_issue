import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/*
Run using:
firebase_core: ^1.10.6
firebase_database: ^9.0.4
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('FlutterFire'),
          ),
          body: const MyList()),
    );
  }
}

class MyList extends StatefulWidget {
  const MyList({Key? key}) : super(key: key);

  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  int count = 0;
  final _db = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _db
                .child('items')
                .push()
                .set({
                  'name': getRandomVal(),
                  'count': count++,
                })
                .then((_) => print('It has been written!'))
                .catchError((error) => print('You got an error $error'));
          },
          child: const Text("Append a item"),
        ),
        const SizedBox(height: 5),
        StreamBuilder<DatabaseEvent>(
          // stream: _db.child('items').onValue,
          stream: _db.child('items').orderByKey().onValue,
          builder: (contect, snapshot) {
            final tilesList = <ListTile>[];
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.data!.snapshot.exists) {
              return const Text("No data found");
            }

            final myItems =
                Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
            print(snapshot.data!.snapshot.value);
            tilesList.addAll(
              myItems.values.map(
                (value) {
                  final nextItem =
                      Item.fromRTDB(Map<String, dynamic>.from(value));
                  return ListTile(
                    title: Text('${nextItem.count}'),
                    subtitle: Text(nextItem.name),
                  );
                },
              ),
            );

            return Expanded(
              child: ListView(
                children: tilesList,
              ),
            );
          },
        )
      ],
    );
  }
}

class Item {
  final String name;
  final int count;

  Item({required this.count, required this.name});

  factory Item.fromRTDB(Map<String, dynamic> data) {
    return Item(
      name: data['name'] ?? 'foobar',
      count: data['count'] ?? -1,
    );
  }
}

String getRandomVal() {
  final vals = ['abc', 'foo', 'bar', 'baz', 'qux', 'wux', 'xyz', 'zzz'];
  return vals[Random().nextInt(vals.length)];
}
