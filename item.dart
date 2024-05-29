// item.dart

class Item {
  String name;
  int quantity;
  double totalPrice;
  List<String> eaters;

  Item({
    required this.name,
    required this.quantity,
    required this.totalPrice,
    required this.eaters,
  });

  void addEater(String eater) {
    eaters.add(eater);
  }

  void removeEater(String eater) {
    eaters.remove(eater);
  }

  double calculateShare(String eater) {
    if (eaters.contains(eater)) {
      int count = eaters.where((e) => e == eater).length;
      return (totalPrice / eaters.length) * count;
    }
    return 0.0;
  }
}
