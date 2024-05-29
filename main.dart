import 'package:flutter/material.dart';
import 'item.dart'; // Import the Item class
import 'bill_calculator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Calculator',
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  TextEditingController taxAmountController = TextEditingController();
  TextEditingController tipAmountController = TextEditingController();

  double subtotal = 0.0;
  double taxAmount = 0.0;
  double subtotalPlusTax = 0.0;
  double tipAmount = 0.0;
  double taxRate = 0.0;
  double tipRate = 0.0;
  double total = 0.0;

  List<Item> items = [];
  final List<Color> predefinedColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Color.fromARGB(255, 232, 7, 206),
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.lime,
    Colors.amber,
  ];

  Map<String, Color> eaterColors = {};
  Map<String, Color> eaterTextColors = {};

  final List<String> eaters = [
    'Gamyui',
    'Jak',
    'June',
    'Jiannan',
    'Itim',
    'Gammy',
    'Kevin'
  ];
  Map<String, double> individualTotals = {};

  @override
  void initState() {
    super.initState();
    assignColorsToEaters();
    initializeMockData();
    calculateSubtotal();
    taxAmountController.text = taxAmount.toStringAsFixed(2);
    tipAmountController.text = tipAmount.toStringAsFixed(2);
  }

  void initializeMockData() {
    setState(() {
      items = [
        Item(
            name: '387 Vacheron',
            quantity: 1,
            totalPrice: 135.00,
            eaters: eaters.sublist(0, eaters.length - 2)),
        Item(
            name: 'Seasonal Nigiri',
            quantity: 1,
            totalPrice: 75.00,
            eaters: eaters),
        Item(
            name: 'Seasonal Sashimi',
            quantity: 1,
            totalPrice: 85.00,
            eaters: eaters),
        Item(
            name: 'R - Momomaki',
            quantity: 1,
            totalPrice: 24.00,
            eaters: eaters),
        Item(
            name: 'Hokkaido Ngiri',
            quantity: 1,
            totalPrice: 16.00,
            eaters: ['Itim']),
        Item(
            name: 'Forbidden Murasaki',
            quantity: 1,
            totalPrice: 10.00,
            eaters: ['Gammy']),
        Item(
            name: 'Asahi Can',
            quantity: 1,
            totalPrice: 9.00,
            eaters: ['Kevin']),
        Item(name: 'Edamame', quantity: 1, totalPrice: 8.00, eaters: eaters),
        Item(
            name: 'Shishito Kushi (2 @10.00)',
            quantity: 2,
            totalPrice: 20.00,
            eaters: eaters),
        Item(
            name: 'Sliders (4 @16.00)',
            quantity: 4,
            totalPrice: 64.00,
            eaters: eaters),
        Item(
            name: 'Hotate Batayaki (2 @20.00)',
            quantity: 2,
            totalPrice: 40.00,
            eaters: eaters),
        Item(
            name: 'Extra Hotate (2 @7.00)',
            quantity: 2,
            totalPrice: 14.00,
            eaters: eaters),
        Item(
            name: 'R-Negi Hamachi',
            quantity: 1,
            totalPrice: 14.00,
            eaters: eaters),
        Item(
            name: 'GL Dry Mountain',
            quantity: 1,
            totalPrice: 14.00,
            eaters: eaters),
        Item(
            name: 'R - Negi Toro',
            quantity: 1,
            totalPrice: 16.00,
            eaters: eaters),
        Item(
            name: 'R-ShioKoji Sake',
            quantity: 1,
            totalPrice: 14.00,
            eaters: ['Kevin']),
        Item(
            name: 'R - Karai Tuna',
            quantity: 1,
            totalPrice: 16.00,
            eaters: eaters),
      ];

      taxAmount = 67.45;
      tipAmount = 115.46;
    });
  }

  void assignColorsToEaters() {
    final random = Random();
    final shuffledColors = predefinedColors..shuffle(random);

    for (int i = 0; i < eaters.length; i++) {
      eaterColors[eaters[i]] = shuffledColors[i % predefinedColors.length];
      eaterTextColors[eaters[i]] = getTextColorForBackground(
          shuffledColors[i % predefinedColors.length]);
    }
  }

  Color getTextColorForBackground(Color backgroundColor) {
    int brightness = (backgroundColor.red * 299 +
            backgroundColor.green * 587 +
            backgroundColor.blue * 114) ~/
        1000;
    return brightness > 128 ? Colors.black : Colors.white;
  }

  void calculateSubtotal() {
    subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void calculate() {
    setState(() {
      taxAmount = double.tryParse(taxAmountController.text) ?? 0.0;
      tipAmount = double.tryParse(tipAmountController.text) ?? 0.0;

      subtotalPlusTax = subtotal + taxAmount;
      taxRate = BillCalculator.calculateSalesTaxRate(subtotal, taxAmount);
      tipRate = BillCalculator.calculateTipRate(subtotalPlusTax, tipAmount);
      total = subtotalPlusTax + tipAmount;

      calculateIndividualTotals();
    });
  }

  void calculateIndividualTotals() {
    individualTotals = {for (var eater in eaters) eater: 0.0};

    for (var item in items) {
      for (var eater in item.eaters) {
        individualTotals[eater] =
            (individualTotals[eater] ?? 0.0) + item.calculateShare(eater);
      }
    }

    for (var eater in eaters) {
      double subtotalShare = individualTotals[eater] ?? 0.0;
      double taxShare = subtotalShare * taxRate;
      double tipShare = (subtotalShare + taxShare) * tipRate;
      individualTotals[eater] = subtotalShare + taxShare + tipShare;
    }
  }

  void updateItem(int index, String name, int quantity, double totalPrice,
      List<String> eaters) {
    setState(() {
      items[index] = Item(
          name: name,
          quantity: quantity,
          totalPrice: totalPrice,
          eaters: eaters);
      calculateSubtotal(); // Recalculate subtotal when items are updated
    });
  }

  void showPieChartDialog({Item? item, int? index}) {
    TextEditingController nameController =
        TextEditingController(text: item?.name ?? '');
    TextEditingController quantityController =
        TextEditingController(text: item?.quantity.toString() ?? '1');
    TextEditingController priceController =
        TextEditingController(text: item?.totalPrice.toString() ?? '0.0');
    List<PieChartSectionData> sections = [];
    Map<String, int> eaterPortions = {};

    for (var eater in eaters) {
      eaterPortions[eater] = item?.eaters.where((e) => e == eater).length ?? 0;
      if (eaterPortions[eater]! > 0) {
        sections.add(
          PieChartSectionData(
            value: eaterPortions[eater]!.toDouble(),
            title: '$eater (${eaterPortions[eater]})',
            color: eaterColors[eater]!,
            titleStyle: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: eaterTextColors[eater]),
            radius: 80,
          ),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Total Price'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 300, // Increase the size of the chart
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 0, // Set to 0 for filled pie chart
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                Wrap(
                  children: eaters.map((eater) {
                    return Container(
                      margin: EdgeInsets.all(4.0),
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: eaterColors[eater]!.withOpacity(0.2),
                        border:
                            Border.all(color: eaterColors[eater]!, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.add,
                                size: 16, color: eaterColors[eater]),
                            onPressed: () {
                              setState(() {
                                eaterPortions[eater] =
                                    (eaterPortions[eater] ?? 0) + 1;
                                sections.clear();
                                for (var e in eaters) {
                                  if (eaterPortions[e]! > 0) {
                                    sections.add(
                                      PieChartSectionData(
                                        value: eaterPortions[e]!.toDouble(),
                                        title: '$e (${eaterPortions[e]})',
                                        color: eaterColors[e]!,
                                        titleStyle: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: eaterTextColors[e]),
                                        radius: 80,
                                      ),
                                    );
                                  }
                                }
                              });
                            },
                          ),
                          Text('$eater (${eaterPortions[eater]})',
                              style: TextStyle(color: eaterColors[eater])),
                          IconButton(
                            icon: Icon(Icons.remove,
                                size: 16, color: eaterColors[eater]),
                            onPressed: () {
                              setState(() {
                                if (eaterPortions[eater]! > 0) {
                                  eaterPortions[eater] =
                                      (eaterPortions[eater] ?? 0) - 1;
                                  sections.clear();
                                  for (var e in eaters) {
                                    if (eaterPortions[e]! > 0) {
                                      sections.add(
                                        PieChartSectionData(
                                          value: eaterPortions[e]!.toDouble(),
                                          title: '$e (${eaterPortions[e]})',
                                          color: eaterColors[e]!,
                                          titleStyle: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: eaterTextColors[e]),
                                          radius: 80,
                                        ),
                                      );
                                    }
                                  }
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (item == null) {
                    items.add(Item(
                      name: nameController.text,
                      quantity: int.tryParse(quantityController.text) ?? 1,
                      totalPrice: double.tryParse(priceController.text) ?? 0.0,
                      eaters: eaterPortions.entries
                          .expand((entry) =>
                              List<String>.filled(entry.value, entry.key))
                          .toList(),
                    ));
                  } else if (index != null) {
                    items[index] = Item(
                      name: nameController.text,
                      quantity: int.tryParse(quantityController.text) ?? 1,
                      totalPrice: double.tryParse(priceController.text) ?? 0.0,
                      eaters: eaterPortions.entries
                          .expand((entry) =>
                              List<String>.filled(entry.value, entry.key))
                          .toList(),
                    );
                  }
                  calculateSubtotal();
                  Navigator.of(context).pop();
                });
              },
              child: Text(item == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Calculator'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
              TextField(
                controller: taxAmountController,
                decoration: InputDecoration(
                  labelText: 'Tax Amount',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: tipAmountController,
                decoration: InputDecoration(
                  labelText: 'Tip Amount',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: calculate,
                child: Text('Calculate Totals'),
              ),
              SizedBox(height: 16.0),
              Text('Tax Rate: ${(taxRate * 100).toStringAsFixed(2)}%'),
              Text('Tip Rate: ${(tipRate * 100).toStringAsFixed(2)}%'),
              Text('Total: \$${total.toStringAsFixed(2)}'),
              SizedBox(height: 16.0),
              Text('Items:'),
              ...items.asMap().entries.map((entry) {
                int index = entry.key;
                Item item = entry.value;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Item Name: ${item.name}'),
                      Text('Quantity: ${item.quantity}'),
                      Text(
                          'Total Price: \$${item.totalPrice.toStringAsFixed(2)}'),
                      Text('Eaters: ${item.eaters.join(', ')}'),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () =>
                                showPieChartDialog(item: item, index: index),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => showPieChartDialog(),
                child: Text('Add Item'),
              ),
              SizedBox(height: 16.0),
              Text('Individual Totals:'),
              ...individualTotals.entries.map((entry) {
                String eater = entry.key;
                double total = entry.value;
                return Text('$eater: \$${total.toStringAsFixed(2)}');
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
