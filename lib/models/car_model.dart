// customer_model.dart
class Customer {
  String id;
  String birthDate;
  String customerName;
  String emailAddress;
  String nik;
  String phoneNum;
  String status;

  Customer(
      {required this.id,
      required this.birthDate,
      required this.customerName,
      required this.emailAddress,
      required this.nik,
      required this.phoneNum,
      required this.status});
}

// car_model.dart
class Car {
  String id;
  String carType;
  String carName;
  String brand;
  String location;
  bool availability;
  String imgUrl;
  String licensePlate;
  String rentPrice;
  String? isUsable;

  Car(
      {required this.id,
      required this.carType,
      required this.carName,
      required this.brand,
      required this.location,
      required this.availability,
      required this.imgUrl,
      required this.licensePlate,
      required this.rentPrice,
      this.isUsable});

  factory Car.fromFirestore(Map<String, dynamic> firestoreDoc, String docId) {
    return Car(
      id: docId,
      carType: firestoreDoc['car_type'] ??
          'Unknown', // Provide a default value in case the field is missing
      carName: firestoreDoc['car_name'] ?? 'Unknown',
      licensePlate: firestoreDoc['license_plate'] ?? 'Unknown',
      rentPrice: (firestoreDoc['rent_price'] is int)
          ? (firestoreDoc['rent_price'] as int).toDouble()
          : firestoreDoc['rent_price'] ??
              0.0, // Ensuring that rentPrice is a double even if it comes as int
      imgUrl: firestoreDoc['img_url'] ?? 'Unknown',
      brand: firestoreDoc['brand'] ?? 'Unknown',
      location: firestoreDoc['location'] ?? 'Unknown', availability: false,
    );
  }
}

// rental_model.dart
class Rental {
  String id;
  String carId;
  String customerId;
  DateTime startDate;
  DateTime endDate;
  String destination;
  int revenue;
  String customerName;
  String carName;

  Rental(
      {required this.id,
      required this.carId,
      required this.customerId,
      required this.startDate,
      required this.endDate,
      required this.destination,
      // required this.rentalPrice,
      required this.revenue,
      required this.customerName,
      required this.carName});
  @override
  String toString() {
    return 'Rental{id: $id, carId: $carId, customerId: $customerId, startDate: $startDate, endDate: $endDate,destination: $destination, revenue: $revenue, customerName: $customerName, carName: $carName}';
  }
}

// rental_monitoring_model.dart
class RentalMonitoring {
  String id;
  String? carId;
  String customerId;
  String latitude;
  String longitude;
  bool smokePresence;
  int temperature;
  Car? carDetails;
  String? carName;
  String? customerName;

  RentalMonitoring({
    required this.id,
    this.carId,
    required this.customerId,
    required this.latitude,
    required this.longitude,
    required this.smokePresence,
    required this.temperature,
    this.carDetails,
    this.carName,
    this.customerName,
  });

  factory RentalMonitoring.fromFirestore(Map<String, dynamic> data) {
    return RentalMonitoring(
      carId: data['car_id'] as String?,
      customerId: data['customer_id'],
      latitude: (data['latitude_id'] is double)
          ? data['latitude_id'].toString()
          : data['latitude_id'] as String,
      longitude: (data['longitude_id'] is double)
          ? data['longitude_id'].toString()
          : data['longitude_id'] as String,
      smokePresence: data['smoke_presence'],
      temperature: data['temperature'],
      id: '',
    );
  }
}
