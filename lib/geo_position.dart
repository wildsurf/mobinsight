class GeoPosition {
  double _latitude;
  double _longitude;

  GeoPosition({double latitude, double longitude}) {
    this._latitude = latitude;
    this._longitude = longitude;
  }

  GeoPosition.fromJson(Map<String, dynamic> json) {
    _latitude = json['latitude'];
    _longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['"latitude"'] = this._latitude;
    data['"longitude"'] = this._longitude;
    data['"mapLatitude"'] = '"${this._latitude.toString()}"';
    data['"mapLongitude"'] = '"${this._longitude.toString()}"';
    return data;
  }
}
