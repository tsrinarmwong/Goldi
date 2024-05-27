class BillCalculator {
  double totalBillAmount;
  int numberOfPeople;
  double taxAmount;
  double tipPercentage;
  List<BillItem> billItems;
  List<Person> people;

  BillCalculator({
    required this.totalBillAmount,
    required this.numberOfPeople,
    required this.taxAmount,
    required this.tipPercentage,
    required this.billItems,
  }) : people = List.generate(
          numberOfPeople,
          (index) => Person(name: 'Person ${index + 1}', items: []),
        ); // Initialize people list in the constructor

  double calculateSingleItemCost(double quantity, double totalCost) {
    return totalCost / quantity;
  }

  double calculateTaxPercentage() {
    return (taxAmount / totalBillAmount) * 100;
  }

  double calculateTipAmount() {
    return (totalBillAmount * (tipPercentage / 100));
  }

  double calculateTotalAmountPerPerson() {
    double subtotal = totalBillAmount + taxAmount;
    double totalAmount = subtotal + calculateTipAmount();

    return totalAmount / numberOfPeople;
  }

  void assignItemsToIndividuals() {
    // Reset orders for all individuals
    people.forEach((person) {
      person.items.clear();
    });

    // Assign items to individuals based on their orders
    billItems.forEach((item) {
      // Here you can implement your own logic to determine which person ordered which item
      // For demonstration purposes, we'll just assign items round-robin to individuals
      for (int i = 0; i < billItems.length; i++) {
        Person person = people[i % numberOfPeople];
        person.items.add(item);
      }
    });
  }
}

class BillItem {
  String name;
  double quantity;
  double totalCost;
  Map<String, int> assignedPeople;

  BillItem({
    required this.name,
    required this.quantity,
    required this.totalCost,
  }) : assignedPeople = {};

  void removeAssignment(String personName) {
    assignedPeople.remove(personName);
  }
}


class Person {
  String name;
  List<BillItem> items;

  Person({
    required this.name,
    required this.items,
  });
}
