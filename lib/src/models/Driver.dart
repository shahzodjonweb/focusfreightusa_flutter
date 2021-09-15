import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Driver extends HiveObject {
  @HiveField(0)
  var key;
  @HiveField(1)
  var name;
  @HiveField(2)
  var email;
  @HiveField(3)
  var phone;
  @HiveField(4)
  var type;
  @HiveField(5)
  var status;
  @HiveField(6)
  var address;
   @HiveField(7)
  var isActive;

  
  Driver(this.key , this.name , this.email , this.phone , this.type, this.status,this.address);
  
  Driver.fromJson(Map<String, dynamic> parsedJson) {
    key = parsedJson['access_token'];
    name = parsedJson['user']['fullname'];
    email = parsedJson['user']['email'];
    phone = parsedJson['user']['phone'];
    type = parsedJson['user']['type'];
    status = parsedJson['user']['status'];
    address = parsedJson['user']['address'];  
  }
 
}