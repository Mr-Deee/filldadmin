class Rider {
  final String key;
  final String email;
  final String numberPlate;
final String imageUrl;
  final String status;
  // bool isActive;

  Rider(this.key, this.email,
      this.numberPlate,
  this.imageUrl,
      this.status,
  // this.isActive
      );

  // Create a method to convert a Rider object to a Map for Firebase
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'numberPlate': numberPlate,
       'riderImageUrl': imageUrl,
      'status': status,
      // 'isActive': isActive,
    };
  }
}
