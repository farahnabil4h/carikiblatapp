class Location {
  String? locationId;
  String? locationName;
  String? locationLatitude;
  String? locationLongitude;

  Location(
      {this.locationId,
      this.locationName,
      this.locationLatitude,
      this.locationLongitude});

  Location.fromJson(Map<String, dynamic> json) {
    locationId = json['location_id'];
    locationName = json['location_name'];
    locationLatitude = json['location_latitude'];
    locationLongitude = json['location_longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location_id'] = locationId;
    data['location_name'] = locationName;
    data['location_latitude'] = locationLatitude;
    data['location_longitude'] = locationLongitude;
    return data;
  }
}
