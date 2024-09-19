class Rider {
  final String key;
  final String name;
  final String number;
  final String email;
  final String earnings;
  final String numberPlate;
  final String imageUrl;
  final String? ghcard;
  final String? ghcardimageUrl;
  final String licensePlate;

  Rider({
    required this.key,
    required this.name,
    required this.number,
    required this.email,
    required this.earnings,
    required this.numberPlate,
    required this.imageUrl,
    this.ghcard,
    this.ghcardimageUrl,
    required this.licensePlate,
  });

  // Create a method to convert a Rider object to a Map for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': key,
      'firstName': name,
      'phoneNumber': number,
      'email': email,
      'numberPlate': numberPlate,
      'earnings': earnings,
      'car_details': {
        'ghanaCardUrl': ghcardimageUrl,
        'riderImageUrl': imageUrl,
        'ghanaCardNumber': ghcard,
        'licensePlateNumber': licensePlate,
      },
    };
  }

  // Create a method to convert a Map into a Rider object (useful for Firebase snapshots)
  static Rider fromMap(String key, Map<String, dynamic> data) {
    return Rider(
      key: key,
      name: data['firstName'] ?? '',
      number: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      earnings: data['earnings'] ?? '',
      numberPlate: data['numberPlate'] ?? '',
      imageUrl: data['car_details']?['riderImageUrl'] ?? '',
      ghcardimageUrl: data['car_details']?['ghanaCardUrl'],
      ghcard: data['car_details']?['ghanaCardNumber'],
      licensePlate: data['car_details']?['licensePlateNumber'] ?? '',
    );
  }
}
