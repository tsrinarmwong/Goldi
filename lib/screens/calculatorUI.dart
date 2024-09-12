import 'package:flutter/material.dart';
import '../processors/item.dart'; // Import the Item class
import '../processors/bill_calculator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:share/share.dart';

final Color primaryColor = Color(0xFFF7B32B); // Gold
final Color secondaryColor = Color(0xFF465775); // Deep Navy Blue
final Color coralColor = Color(0xFFFF6F59);
final Color lightYellowColor = Color(0xFFFCF6B1);
final Color darkSlateBlueColor = Color(0xFF2D3A4D);

final List<Color> predefinedColors = [
  Color(0xFF1F77B4),
  Color(0xFFFF7F0E),
  Color(0xFF2CA02C),
  Color(0xFFD62728),
  Color(0xFF9467BD),
  Color(0xFF8C564B),
  Color(0xFFE377C2),
  Color.fromARGB(255, 38, 72, 240),
  Color(0xFFBCBD22),
  Color(0xFF17BECF),
];

class CalculatorScreen extends StatefulWidget {
  final List<Item> initialItems;

  CalculatorScreen({this.initialItems = const []});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  List<Item> items = [];
  List<String> eaters = [];
  Map<String, Color> eaterColors = {};
  Map<String, Color> eaterTextColors = {};
  TextEditingController taxAmountController = TextEditingController();
  TextEditingController tipAmountController = TextEditingController();
  double subtotal = 0.0;
  double taxAmount = 0.0;
  double tipAmount = 0.0;
  double taxRate = 0.0;
  double tipRate = 0.0;
  double total = 0.0;
  Map<String, double> individualTotals = {};
  double subtotalPlusTax = 0.0;
  Map<String, bool> paymentStatus = {};

  @override
  void initState() {
    super.initState();
    assignColorsToEaters();
    if (widget.initialItems.isNotEmpty) {
      items = widget.initialItems;
    } else {
    }
    calculateSubtotal();
    taxAmountController.text = taxAmount.toStringAsFixed(2);
    tipAmountController.text = tipAmount.toStringAsFixed(2);
  }

  void assignColorsToEaters() {
    final random = Random();
    final availableColors = predefinedColors
        .where((color) => !eaterColors.containsValue(color))
        .toList();

    for (var eater in eaters) {
      if (!eaterColors.containsKey(eater)) {
        final color = availableColors.isNotEmpty
            ? availableColors.removeAt(0)
            : predefinedColors[random.nextInt(predefinedColors.length)];
        eaterColors[eater] = color;
        eaterTextColors[eater] = getTextColorForBackground(color);
        paymentStatus[eater] = false; // Ensure payment status is initialized
      }
    }
  }

  String generateReceiptContent() {
    StringBuffer receiptBuffer = StringBuffer();
    receiptBuffer.writeln("Goldi Bill Calculator Receipt\n");
    receiptBuffer.writeln("Items:");

    for (var item in items) {
      receiptBuffer
          .writeln("${item.name} (\$${item.totalPrice.toStringAsFixed(2)})");
      receiptBuffer.writeln("  Eaters: ${item.eaters.join(', ')}");
    }

    receiptBuffer.writeln("\nSubtotal: \$${subtotal.toStringAsFixed(2)}");
    receiptBuffer.writeln("Tax Amount: \$${taxAmount.toStringAsFixed(2)}");
    receiptBuffer.writeln("Tip Amount: \$${tipAmount.toStringAsFixed(2)}");
    receiptBuffer.writeln("Total: \$${total.toStringAsFixed(2)}");

    receiptBuffer.writeln("\nIndividual Totals:");
    for (var entry in individualTotals.entries) {
      receiptBuffer
          .writeln("${entry.key}: \$${entry.value.toStringAsFixed(2)}");
    }

    return receiptBuffer.toString();
  }

  void exportReceipt() {
    String receiptContent = generateReceiptContent();
    Share.share(receiptContent, subject: 'Goldi Bill Calculator Receipt');
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
      Map<String, double> shares = item.calculateEaterShares();

      for (var entry in shares.entries) {
        String eaterName = entry.key;
        double share = entry.value;
        individualTotals[eaterName] =
            (individualTotals[eaterName] ?? 0.0) + share;
      }
    }

    for (var eater in eaters) {
      double subtotalShare = individualTotals[eater] ?? 0.0;
      double taxShare = subtotalShare * taxRate;
      double tipShare = (subtotalShare + taxShare) * tipRate;
      individualTotals[eater] = subtotalShare + taxShare + tipShare;
    }

    // Recalculate total to match individual shares
    total = individualTotals.values.reduce((sum, element) => sum + element);
  }

  void updateItem(int index, String name, int quantity, double totalPrice,
      List<String> eaters) {
    setState(() {
      items[index] = Item(
          name: name,
          totalPrice: totalPrice,
          eaters: eaters);
      calculateSubtotal(); // Recalculate subtotal when items are updated
    });
  }

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
      calculateSubtotal(); // Recalculate subtotal after item deletion
      calculate(); // Recalculate totals after item deletion
    });
  }

  void showEaterDialog() {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Eaters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Eater Name'),
              ),
              SizedBox(height: 16.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: eaters.map((eater) {
                  return Chip(
                    backgroundColor: eaterColors[eater] ?? Colors.grey,
                    label: Text(
                      eater,
                      style: TextStyle(
                          color: eaterTextColors[eater] ?? Colors.white),
                    ),
                    onDeleted: () {
                      setState(() {
                        eaters.remove(eater);
                        eaterColors.remove(eater);
                        eaterTextColors.remove(eater);
                      });
                      Navigator.of(context).pop();
                      showEaterDialog(); // Reopen the dialog to reflect changes
                    },
                  );
                }).toList(),
              ),
            ],
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
                  if (nameController.text.isNotEmpty) {
                    eaters.add(nameController.text);
                    assignColorsToEaters(); // Assign color to the new eater
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Add Eater'),
            ),
          ],
        );
      },
    );
  }

  void showPieChartDialog({Item? item, int? index}) {
    TextEditingController nameController =
        TextEditingController(text: item?.name ?? '');
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
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: eaterTextColors[eater]),
            radius: 120,
          ),
        );
      }
    }

    void updateSections() {
      setState(() {
        sections.clear();
        for (var e in eaters) {
          if (eaterPortions[e]! > 0) {
            sections.add(
              PieChartSectionData(
                value: eaterPortions[e]!.toDouble(),
                title: '$e (${eaterPortions[e]})',
                color: eaterColors[e]!,
                titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: eaterTextColors[e]),
                radius: 120,
              ),
            );
          }
        }
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(item == null ? 'Add Item' : 'Edit Item'),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Item Name'),
                      ),
                      SizedBox(height: 8.0),
                      // TextField(
                      //   decoration: InputDecoration(labelText: 'Quantity'),
                      //   keyboardType: TextInputType.number,
                      // ),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: priceController,
                        decoration: InputDecoration(labelText: 'Total Price'),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            for (var eater in eaters) {
                              eaterPortions[eater] = 1;
                            }
                            updateSections();
                          });
                        },
                        child: Text('Equal Share'),
                      ),
                      Wrap(
                        children: eaters.map((eater) {
                          return Container(
                            margin: EdgeInsets.all(2.0),
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: eaterColors[eater]!.withOpacity(0.2),
                              border: Border.all(
                                  color: eaterColors[eater]!, width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.add,
                                      size: 12, color: eaterColors[eater]),
                                  onPressed: () {
                                    setState(() {
                                      eaterPortions[eater] =
                                          (eaterPortions[eater] ?? 0) + 1;
                                      updateSections();
                                    });
                                  },
                                ),
                                Text('$eater (${eaterPortions[eater]})',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black)),
                                IconButton(
                                  icon: Icon(Icons.remove,
                                      size: 12, color: eaterColors[eater]),
                                  onPressed: () {
                                    setState(() {
                                      if (eaterPortions[eater]! > 0) {
                                        eaterPortions[eater] =
                                            (eaterPortions[eater] ?? 0) - 1;
                                        updateSections();
                                      }
                                    });
                                  },
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
                          totalPrice:
                              double.tryParse(priceController.text) ?? 0.0,
                          eaters: eaterPortions.entries
                              .expand((entry) =>
                                  List<String>.filled(entry.value, entry.key))
                              .toList(),
                        ));
                      } else if (index != null) {
                        items[index] = Item(
                          name: nameController.text,
                          totalPrice:
                              double.tryParse(priceController.text) ?? 0.0,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.orange;
      }
      if (states.contains(MaterialState.selected)) {
    return Colors.green;
  }
      return Colors.red;
    }


    return Scaffold(
      appBar: AppBar(
        title: Text('Goldi Bill Calculator'),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.refresh),
        //     onPressed: initializeBlankData,
        //   ),
        //   // IconButton(
        //   //   icon: Icon(Icons.share),
        //   //   onPressed: exportReceipt,
        //   // ),
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: showEaterDialog,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF465775), // Navy blue color
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '(Eaters)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          '${eaters.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => showPieChartDialog(),
                    child: Text('Add Item',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        )),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Items: ${items.length}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: items.asMap().entries.map((entry) {
                  int index = entry.key;
                  Item item = entry.value;
                  return GestureDetector(
                    onTap: () => showPieChartDialog(item: item, index: index),
                    child: Container(
                      width: MediaQuery.of(context).size.width -
                          32, // Adjust width to fit one item per row
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: lightYellowColor,
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: darkSlateBlueColor),
                              ),
                              Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: darkSlateBlueColor),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Eaters: ${item.eaters.length}',
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.black54),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteItem(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              Text(
                'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: taxAmountController,
                decoration: InputDecoration(
                  labelText: 'Tax Amount',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16.0),
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
              Text(
                'Tax Rate: ${(taxRate * 100).toStringAsFixed(2)}%',
                style: TextStyle(fontWeight: FontWeight.w100, fontSize: 16.0),
              ),
              Text(
                'Tip Rate: ${(tipRate * 100).toStringAsFixed(2)}%',
                style: TextStyle(fontWeight: FontWeight.w100, fontSize: 16.0),
              ),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              Text(
                'Individual Totals:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              ...individualTotals.entries.map((entry) {
                String eater = entry.key;
                double total = entry.value;
                return Row(
                  children: [
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: paymentStatus[eater],
                      onChanged: (bool? value) {
                        setState(() {
                          paymentStatus[eater] = value ?? false;
                        });
                      },
                    ),
                    Text(
                      '$eater: \$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    )
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}