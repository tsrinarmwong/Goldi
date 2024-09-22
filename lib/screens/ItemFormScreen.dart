import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../processors/item.dart'; // Import your Item class

class ItemFormPage extends StatefulWidget {
  final Item? item;
  final int? index;
  final List<String> eaters;
  final Map<String, Color> eaterColors;
  final Map<String, Color> eaterTextColors;

  ItemFormPage({
    this.item,
    this.index,
    required this.eaters,
    required this.eaterColors,
    required this.eaterTextColors,
  });

  @override
  _ItemFormPageState createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  List<PieChartSectionData> sections = [];
  Map<String, int> eaterPortions = {};

  @override
  void initState() {
    super.initState();
    // Prepopulate fields if editing
    nameController.text = widget.item?.name ?? '';

    // Set price only if editing, otherwise use empty field with a placeholder
    if (widget.item != null) {
      priceController.text = widget.item!.totalPrice.toString();
    }

    for (var eater in widget.eaters) {
      eaterPortions[eater] = widget.item?.eaters.where((e) => e == eater).length ?? 0;
    }
    updateSections();
  }

  void updateSections() {
    setState(() {
      sections.clear();
      for (var e in widget.eaters) {
        if (eaterPortions[e]! > 0) {
          sections.add(
            PieChartSectionData(
              value: eaterPortions[e]!.toDouble(),
              title: '$e (${eaterPortions[e]})',
              color: widget.eaterColors[e]!,
              titleStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.eaterTextColors[e],
              ),
              radius: 120,
            ),
          );
        }
      }
    });
  }

  void updatePortion(String eater, int change) {
    setState(() {
      eaterPortions[eater] = (eaterPortions[eater] ?? 0) + change;
      if (eaterPortions[eater]! < 0) eaterPortions[eater] = 0;
      updateSections();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              SizedBox(height: 8.0),
              // Updated Total Price field with hintText
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Total Price',
                  hintText: '0.0', // Add placeholder text
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    for (var eater in widget.eaters) {
                      eaterPortions[eater] = 1;
                    }
                    updateSections();
                  });
                },
                child: Text('Equal Share'),
              ),
              Wrap(
                children: widget.eaters.map((eater) {
                  return Container(
                    margin: EdgeInsets.all(2.0),
                    padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: widget.eaterColors[eater]!.withOpacity(0.2),
                      border: Border.all(color: widget.eaterColors[eater]!, width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, size: 12, color: widget.eaterColors[eater]),
                          onPressed: () => updatePortion(eater, 1),
                        ),
                        Text('$eater (${eaterPortions[eater]})',
                            style: TextStyle(fontSize: 12, color: Colors.black)),
                        IconButton(
                          icon: Icon(Icons.remove, size: 12, color: widget.eaterColors[eater]),
                          onPressed: () => updatePortion(eater, -1),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 8.0),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.6,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 0,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final double price = double.tryParse(priceController.text) ?? 0.0;
                  final List<String> selectedEaters = eaterPortions.entries
                      .expand((entry) => List<String>.filled(entry.value, entry.key))
                      .toList();

                  final newItem = Item(
                    name: nameController.text,
                    totalPrice: price,
                    eaters: selectedEaters,
                  );
                  Navigator.of(context).pop(newItem); // Return the new item
                }
              },
              child: Text(widget.item == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}