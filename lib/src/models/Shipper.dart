import '../models/Location.dart';
class Shipper {
  var order;
  var checkin;
  var checkout;
  var time;
  Location location;

  Shipper(this.order, this.checkin , this.checkout , this.time , this.location);
  
  Shipper.fromJson(Map<String, dynamic> parsedJson){
    order = parsedJson['order'];
    if(parsedJson['in'] == 0 || parsedJson['in'] == 1){
      checkin = null;
    }else{
      checkin = parsedJson['in'];
    }
    if(parsedJson['out'] == 0 || parsedJson['out'] == 1){
      checkout = null;
    }else{
      checkout = parsedJson['out'];
    }
    
    time = parsedJson['time'];
   location = Location.fromJson(parsedJson['location']);
  }
}