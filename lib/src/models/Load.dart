import '../models/Shipper.dart';

class Load {
  var id;
  var number;
  var price;
  var milage;
  var deadhead;
  var status;
  List<Shipper> shippers = [];

  Load(this.id, this.price, this.milage, this.deadhead, this.status,
      this.shippers);

  Load.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    number = parsedJson['number'];
    price = parsedJson['price'];
    milage = parsedJson['milage'];
    deadhead = parsedJson['deadhead'];
    status = parsedJson['status'];
    for (final shipper in parsedJson['shippers']) {
      Shipper eachshipper = Shipper.fromJson(shipper);
      shippers.add(eachshipper);
    }
  }
  Load.fromJsonForList(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    number = parsedJson['number'];
    status = parsedJson['status'];

    shippers.add(Shipper.fromJson(parsedJson['firstshipper']));
    shippers.add(Shipper.fromJson(parsedJson['lastshipper']));
  }
}
