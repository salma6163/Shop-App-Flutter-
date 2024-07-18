import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/data/categories.dart';
import 'package:shop/models/category.dart';

import 'package:http/http.dart' as http;
import 'package:shop/models/grocery-item.dart';

class newItem extends StatefulWidget {
  const newItem({super.key});

  @override
  State<newItem> createState() => _newItemState();
}

class _newItemState extends State<newItem> {
  var enteredNmae = '';
  var enteredquantity = 0;
  var selectedcategory = categories[Categories.dairy]!;
  final formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Form(
          key: formkey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (newValue) {
                  enteredNmae = newValue!;
                }, //to save data
                decoration: const InputDecoration(
                  label: Text("name"),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1) {
                    return 'error';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      onSaved: (newValue) {
                        enteredquantity = int.parse(newValue!);
                      }, //to save data
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: Text("Quantity"),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'error';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: selectedcategory,
                        onSaved: (newValue) {
                          setState(() {
                            selectedcategory = newValue!;
                          });
                        }, //to save data
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(category.value.title)
                                ],
                              ),
                            ),
                        ],
                        onChanged: (value) {}),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        formkey.currentState!.reset();
                      },
                      child: Text("Reset")),
                  ElevatedButton(
                      onPressed: () async {
                        //to ensure the data is correct
                        if (formkey.currentState!.validate()) {
                          formkey.currentState!.save();
                          /////////////save data when close app//////////////////////
                          final Uri url = Uri.https(
                              'flutter-test-337c8-default-rtdb.firebaseio.com',
                              'shoppingList.json');
                          final http.Response res = await http.post(
                            url,
                            headers: {'Conten-Type': 'application/json'},
                            body: json.encode(
                              {
                                'name': enteredNmae,
                                'quantity': enteredquantity,
                                'category': selectedcategory.title,
                              },
                            ),
                          );

                          //////////////////////////////////
                          final Map<String, dynamic> resdata =
                              json.decode(res.body);
                          if (res.statusCode == 200) {
                            Navigator.of(context).pop();
                            GroceryItem(
                                id: resdata['name'],
                                name: enteredNmae,
                                quantity: enteredquantity,
                                category: selectedcategory);
                          }
                        }
                      },
                      child: Text("Add Item"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
