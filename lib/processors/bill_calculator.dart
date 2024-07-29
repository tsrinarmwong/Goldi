class BillCalculator {
  static double calculateSubtotal(double total, double salesTaxRate, double tipRate) {
    return total / ((1 + salesTaxRate) * (1 + tipRate));
  }

  static double calculateSalesTaxRate(double subtotal, double taxAmount) {
    return taxAmount / subtotal;
  }

  static double calculateTipRate(double subtotalPlusTax, double tipAmount) {
    return tipAmount / subtotalPlusTax;
  }
}