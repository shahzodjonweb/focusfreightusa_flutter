class Location {
  var state;
  var county;
  var city;
  var zipcode;

  Location(this.state , this.county , this.city , this.zipcode);
  
  Location.fromJson(Map<String, dynamic> parsedJson){
    state = parsedJson['state'];
    county = parsedJson['county'];
    city = parsedJson['city'];
   zipcode = parsedJson['zipcode'];
  }
}