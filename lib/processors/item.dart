class Item {
  String name;
  double totalPrice;
  List<String> eaters;

  Item({
    required this.name,
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

  Map<String, double> calculateEaterShares() {
    Map<String, double> shares = {};
    int totalPortions = eaters.length;
    double pricePerPortion = totalPrice / totalPortions;

    for (var eater in eaters) {
      shares[eater] = pricePerPortion * eaters.where((e) => e == eater).length;
    }

    return shares;
  }
}
