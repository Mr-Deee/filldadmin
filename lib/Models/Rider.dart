class Rider {
  final String key;
  final String Name;
  final String email;
  final String numberPlate;
final String imageUrl;
final String ghcard;
final String ghcardimageUrl;
final String licenseplate;

  // final String status;
  // bool isActive;

  Rider(this.key,
      this.Name,
      this.email,
      this.numberPlate,
      this.imageUrl,
      this.ghcardimageUrl,
      this.ghcard,
      this.licenseplate,
      // this.status,

  // this.isActive
      );
  // static Rider fromMap(Map<String, dynamic> data)
  //
  // {
  // Create a method to convert a Rider object to a Map for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id':key,
      'FirstName':Name,
      'email': email,
      'numberPlate': numberPlate,
       'riderImageUrl': imageUrl,
      'car_details': {
        'GhanaCardUrl': ghcardimageUrl,
      'GhanaCardNumber': ghcard,
      'licensePlateNumber': licenseplate,

      // Add other properties within 'car_details' if needed
    },
      // 'status': status,
      // 'isActive': isActive,
    };
  }
}
