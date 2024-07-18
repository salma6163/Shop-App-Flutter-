import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/categories.dart';
import 'package:shop/data/dummy-items.dart';
import 'package:shop/models/category.dart';
import 'package:shop/widgets/newItem.dart';

import '../models/grocery-item.dart';

class grocerylist extends StatefulWidget {
  grocerylist({super.key});

  @override
  State<grocerylist> createState() => _grocerylistState();
}

class _grocerylistState extends State<grocerylist> {
  List<GroceryItem> grocery = [];

  void loaddata() async {
    final Uri url = Uri.https(
        'flutter-test-337c8-default-rtdb.firebaseio.com', 'shoppingList.json');
    final http.Response res = await http.get(url);
    final Map<String, dynamic> loadeddata = json.decode(res.body);
    final List<GroceryItem> loadeditems = [];

    loadeddata.forEach(
      (key, value) {
        final Category category = categories.entries
            .firstWhere((element) => element.value.title == value['category'])
            .value;

        loadeditems.add(
          GroceryItem(
            id: key,
            name: value['name'],
            quantity: value['quantity'],
            category: category,
          ),
        );
        setState(() {
          grocery = loadeditems;
        });
      },
    );

    // Now you can use loadeditems as needed
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loaddata();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("No Item Added yet ."),
    );

    if (grocery.isNotEmpty) {
      content = ListView.builder(
        itemCount: grocery.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(grocery[index].id),
          onDismissed: (_) {
            removeItem(grocery[index]);
          },
          child: ListTile(
            title: Text(grocery[index].name),
            leading: Container(
              width: 24,
              height: 25,
              color: grocery[index].category.color,
            ),
            trailing: Text(grocery[index].quantity.toString()),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(Icons.add),
          )
        ],
        title: Text("Shop"),
      ),
      body: content,
    );
  }

  void removeItem(GroceryItem item) {
    final Uri url = Uri.https('flutter-test-337c8-default-rtdb.firebaseio.com',
        'shoppingList/${item.id}.json');

    http.delete(url); //for remove from DB

    return setState(() {
      grocery.remove(item);
    });
  }

  Future _addItem() async {
    final newitem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => newItem(),
      ),
    );
    loaddata();
    if (newitem == null) {
      return;
    }

    setState(() {
      groceryItems.add(newitem);
    });
  }
}
