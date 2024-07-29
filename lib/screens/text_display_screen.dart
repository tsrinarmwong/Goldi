import 'package:flutter/material.dart';
import 'package:goldi/processors/item.dart';

class TextDisplayScreen extends StatelessWidget {
  final List<Item> items;

  TextDisplayScreen({required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parsed Items'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.name),
            trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }
}
