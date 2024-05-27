import 'package:flutter/material.dart';
import 'bill_calculator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goldi Bill Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InitialPage(),
    );
  }
}

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  String? userInput;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goldi Bill Calculator'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  userInput = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter number of people',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (userInput != null && userInput!.isNotEmpty) {
                    int numberOfPeople = int.parse(userInput!);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            MyHomePage(numberOfPeople: numberOfPeople)));
                  }
                },
                child: Text('Proceed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int numberOfPeople;

  MyHomePage({required this.numberOfPeople});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late BillCalculator billCalculator;

  @override
  void initState() {
    super.initState();
    billCalculator = BillCalculator(
      totalBillAmount: 100.0,
      numberOfPeople: widget.numberOfPeople,
      taxAmount: 10.0,
      tipPercentage: 15.0,
      billItems: [
        BillItem(name: 'Beer', quantity: 2, totalCost: 20.0),
        BillItem(name: 'Pizza', quantity: 1, totalCost: 30.0),
        BillItem(name: 'Burger', quantity: 2, totalCost: 15.0),
      ],
    );
    _initializePeople();
  }

  List<String> peopleNames = [];

  void _initializePeople() {
    setState(() {
      peopleNames = List.generate(
          billCalculator.numberOfPeople, (index) => 'Person ${index + 1}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goldi Bill Calculator'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'People',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: peopleNames.length,
                          itemBuilder: (context, index) {
                            return Draggable<String>(
                              data: peopleNames[index],
                              child: Card(
                                color: Colors.blueAccent,
                                child: ListTile(
                                  title: Text(peopleNames[index]),
                                ),
                              ),
                              feedback: Material(
                                color: Colors.transparent,
                                child: Card(
                                  color: Colors.blueAccent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(peopleNames[index]),
                                  ),
                                  elevation: 4.0,
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: Card(
                                  color: Colors.blueAccent,
                                  child: ListTile(
                                    title: Text(peopleNames[index]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Items',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: billCalculator.billItems.length,
                          itemBuilder: (context, index) {
                            return DragTarget<String>(
                              onAccept: (personName) {
                                _assignItemToPerson(
                                    billCalculator.billItems[index],
                                    personName);
                              },
                              builder: (context, candidateData, rejectedData) {
                                return Card(
                                  color: Colors.greenAccent,
                                  child: ListTile(
                                    title: Text(
                                        billCalculator.billItems[index].name),
                                    subtitle: Text(
                                        'Quantity: ${billCalculator.billItems[index].quantity}'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: billCalculator.people.length,
              itemBuilder: (context, index) {
                Person person = billCalculator.people[index];
                double totalCost = person.items.fold(0, (sum, item) {
                  int itemCount = item.assignedPeople[person.name] ?? 0;
                  double itemCostPerUnit = item.totalCost / item.quantity;
                  return sum + itemCostPerUnit * itemCount;
                });
                String items = person.items.map((item) {
                  int itemCount = item.assignedPeople[person.name] ?? 0;
                  return '${item.name} $itemCount';
                }).join(', ');

                return ListTile(
                  title: Text(person.name),
                  subtitle: Text('Items: $items'),
                  trailing: Text('\$${totalCost.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _assignItemToPerson(BillItem item, String personName) async {
    int? assignedQuantity = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController quantityController = TextEditingController();
        return AlertDialog(
          title: Text('Assign to $personName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How many for this person?'),
              SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                int quantity = int.tryParse(quantityController.text) ?? 0;
                int currentAssigned =
                    item.assignedPeople.values.fold(0, (sum, q) => sum + q);
                int availableQuantity = item.quantity.toInt() - currentAssigned;
                if (quantity > 0 && quantity <= availableQuantity) {
                  Navigator.of(context).pop(quantity);
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (assignedQuantity != null) {
      setState(() {
        if (!billCalculator.people.any((person) => person.name == personName)) {
          billCalculator.people.add(Person(name: personName, items: []));
        }
        Person person = billCalculator.people
            .firstWhere((person) => person.name == personName);
        for (int i = 0; i < assignedQuantity; i++) {
          person.items.add(item);
        }
        if (item.assignedPeople.containsKey(personName)) {
          item.assignedPeople[personName] =
              item.assignedPeople[personName]! + assignedQuantity;
        } else {
          item.assignedPeople[personName] = assignedQuantity;
        }
      });
    }
  }

  void _removeItemFromPerson(BillItem item, String personName) {
    setState(() {
      item.removeAssignment(personName);
      Person person = billCalculator.people
          .firstWhere((person) => person.name == personName);
      person.items.removeWhere((assignedItem) => assignedItem == item);
    });
  }
}



// Item doubles
// Oh my, I made a wrong move. 
// Item can have many people assigned. Think of it as a Item total/person in responsible.

// Like 1 Pizza = $30
// Person 1, Person 2, Person 3, all share the pizza.
// Each should be $10 to each person bill's.

// Now if there's Person 4 there will be $30/4 instead.

// The quantity feature shine is a scenario where unequal share happened.
// Let's say they drink beer, there are 4 beers and the bill is $40.
// Person 1 drink 2 glasses, he should get $20 to his bill.
// Person 2 and 3 drink 1 glass so they should get $10 to their bills.