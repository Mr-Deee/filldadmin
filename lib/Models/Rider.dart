class Rider {
  final String key;
  final String Name;
  final String number;
  final String email;
  final String earnings;
  final String numberPlate;
  final String imageUrl;
  final String ghcard;
  final String ghcardimageUrl;
  final String licenseplate;

  // final String status;
  // bool isActive;

  Rider(
    this.key,
    this.Name,
    this.email,
    this.numberPlate,
    this.earnings,
    this.imageUrl,
    this.ghcardimageUrl,
    this.ghcard,
    this.licenseplate,
    this.number,
    // this.status,

    // this.isActive
  );

  // static Rider fromMap(Map<String, dynamic> data)
  //
  // {
  // Create a method to convert a Rider object to a Map for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': key,
      'FirstName': Name,
      'phoneNumber': number,
      'email': email,
      'numberPlate': numberPlate,
      'earnings': earnings,
      // 'riderImageUrl': imageUrl,
      'car_details': {
        'GhanaCardUrl': ghcardimageUrl,
        'riderImageUrl': imageUrl,
        'ghanaCardNumber': ghcard,
        'licensePlateNumber': licenseplate,

        // Add other properties within 'car_details' if needed
      },
      // 'status': status,
      // 'isActive': isActive,
    };
  }
}
