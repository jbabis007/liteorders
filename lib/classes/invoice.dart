
import 'package:liteorders/classes/delail.dart';
import 'package:liteorders/classes/enterprise.dart';
import 'package:liteorders/classes/supplier.dart';



class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Enterprise customer;
  final List<Detail> items;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
  });
}

class InvoiceInfo {
  final String description;
  final String number;
  final String date;


  const InvoiceInfo({
    required this.description,
    required this.number,
    required this.date,

  });
}


