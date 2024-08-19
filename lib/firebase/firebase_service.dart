// firebase_service.dart
import 'package:car/models/car_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Rental>> fetchRentals(String carId, String monthYear) async {
    DateTime start = DateFormat('MM/yyyy').parse(monthYear);
    DateTime end = DateTime(start.year, start.month + 1, 0, 23, 59, 59);

    QuerySnapshot rentalSnapshot = await _firestore
        .collection('rental')
        .where('car_id', isEqualTo: carId)
        .where('end_date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('end_date', isLessThanOrEqualTo: end.toIso8601String())
        .where('status',
            isEqualTo: 'done') //Only fetch rentals that is already done
        .orderBy('end_date', descending: true)
        .get();

    List<Rental> fetchedRentals = [];

    for (var doc in rentalSnapshot.docs) {
      var rentalData = doc.data() as Map<String, dynamic>;
      // Fetch the customer name using the customer_id from the rental data
      String customerName = 'Unknown';
      if (rentalData['customer_id'] != null) {
        DocumentSnapshot customerSnapshot = await _firestore
            .collection('customer')
            .doc(rentalData['customer_id'])
            .get();

        customerName = customerSnapshot.exists
            ? (customerSnapshot.data()
                    as Map<String, dynamic>)['customer_name'] ??
                'Unknown'
            : 'Unknown';
      }

      String carName = "Unknown";
      if (rentalData['car_id'] != null) {
        DocumentSnapshot carSnapshot =
            await _firestore.collection('car').doc(rentalData['car_id']).get();

        carName = carSnapshot.exists
            ? (carSnapshot.data() as Map<String, dynamic>)['customer_name'] ??
                'Unknown'
            : 'Unknown';
      }

      Rental rental = Rental(
          id: doc.id,
          carId: rentalData['car_id'],
          customerId: rentalData['customer_id'],
          startDate: parseDate(rentalData['start_date']),
          endDate: parseDate(rentalData['end_date']),
          destination: rentalData['destination'],
          // rentalPrice: rentalData['rent_price'],
          revenue: (rentalData['revenue'] as num).toInt(),
          customerName: customerName,
          carName: carName);

      fetchedRentals.add(rental);
    }

    return fetchedRentals;
  }

  Future<List<Rental>> fetchAllRentals() async {
    QuerySnapshot rentalSnapshot = await _firestore
        .collection('rental')
        .where('status', isEqualTo: 'ongoing')
        .orderBy('end_date', descending: true)
        .get();

    List<Rental> fetchedRentals = [];

    for (var doc in rentalSnapshot.docs) {
      var rentalData = doc.data() as Map<String, dynamic>;
      // Fetch the customer name using the customer_id from the rental data
      String customerName = 'Unknown';
      if (rentalData['customer_id'] != null) {
        DocumentSnapshot customerSnapshot = await _firestore
            .collection('customer')
            .doc(rentalData['customer_id'])
            .get();

        customerName = customerSnapshot.exists
            ? (customerSnapshot.data()
                    as Map<String, dynamic>)['customer_name'] ??
                'Unknown'
            : 'Unknown';
      }

      //fetch car name using car id from rental data
      String carName = "Unknown";
      if (rentalData['car_id'] != null) {
        DocumentSnapshot carSnapshot =
            await _firestore.collection('car').doc(rentalData['car_id']).get();

        carName = carSnapshot.exists
            ? (carSnapshot.data() as Map<String, dynamic>)['car_name'] ??
                'Unknown'
            : 'Unknown';
      }

      Rental rental = Rental(
          id: doc.id,
          carId: rentalData['car_id'],
          customerId: rentalData['customer_id'],
          startDate: parseDate(rentalData['start_date']),
          endDate: parseDate(rentalData['end_date']),
          destination: rentalData['destination'],
          // rentalPrice: rentalData['rent_price'],
          revenue: (rentalData['revenue'] as num).toInt(),
          customerName: customerName,
          carName: carName);

      fetchedRentals.add(rental);
    }

    return fetchedRentals;
  }

  DateTime parseDate(dynamic date) {
    // If the date is already a DateTime object, return it directly.
    if (date is DateTime) return date;

    // If the date is a Timestamp, convert to DateTime and return.
    if (date is Timestamp) return date.toDate();

    // If the date is a String, parse it and adjust the time to 00:01.
    if (date is String) {
      // Parse the date string to a DateTime object.
      DateTime parsedDate = DateFormat("yyyy-MM-dd").parse(date, true).toUtc();

      // Adjust the time to 00:01 and consider UTC+7.
      return parsedDate.add(Duration(hours: 7, minutes: 1));
    }

    // Return current date/time if input type is not handled.
    return DateTime.now();
  }

  Future<void> addRental(String carId, String customerId, String startDate,
      String endDate, String destination, int revenue) async {
    try {
      //check the car status
      final carRef = await _firestore.collection('car').doc(carId).get();

      if (carRef == null) {
        Get.snackbar('Error', 'Failed to get car reference',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 1));
        return;
      } else {
        //Check if the availability is false (unavailable)
        if (carRef.data()?['availability'] == false) {
          Get.snackbar('Error', 'This car is unavailable',
              snackPosition: SnackPosition.BOTTOM,
              duration: Duration(seconds: 1));
        } else {
          //if car is available, set the availability to false (Unavailable)
          await _firestore.collection('rental').add({
            'car_id': carId,
            'customer_id': customerId,
            'start_date': startDate,
            'end_date': endDate,
            'destination': destination,
            'revenue': revenue,
            'status': 'ongoing'
          });
          // Find the document in rental_monitoring that has the same car_id used in this operation
          final docRef = await _firestore
              .collection('rental_monitoring')
              .where('car_id', isEqualTo: carId)
              .get()
              .then((querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              return querySnapshot.docs.first.reference;
            } else {
              // Handle the case where no document matches the car_id
              print('No document found for car ID: $carId');
              return null;
            }
          });
          if (docRef == null) {
            return;
          } else {
            //update the customer_id with the same customer_id used to update rental_monitoring
            await docRef.update({'customer_id': customerId});
          }
          Get.snackbar('Success', 'Rental Schedule added successfully',
              snackPosition: SnackPosition.BOTTOM,
              duration: Duration(seconds: 1));
        }
      }
    } catch (error) {
      Get.snackbar('Error', 'Failed to add Rental Schedule: $error',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    }
  }

  Future<void> addCar(
    String carType,
    String carName,
    String licensePlate,
    String rentPrice,
    String imageUrl,
    String brand,
    String location,
  ) async {
    try {
      await _firestore.collection('car').add({
        'car_type': carType,
        'car_name': carName,
        'availability': true, // Assuming newly added car is available
        'license_plate': licensePlate,
        'rent_price': rentPrice,
        'is_usable': true,
        'img_url': imageUrl,
        'brand': brand,
        'location': location,
      });
      Get.snackbar('Success', 'Car added successfully',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    } catch (error) {
      Get.snackbar('Error', 'Failed to add car: $error',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    }
  }

  Future<void> finishBooking(String carId, String id) async {
    try {
      //Gets the rental_monitoring data of the car
      final monitoringRef = await _firestore
          .collection('rental_monitoring')
          .where('car_id', isEqualTo: carId)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first.reference;
        } else {
          // Handle the case where no document matches the car_id
          print('No document found for car ID: $carId');
          return null;
        }
      });
      if (monitoringRef == null) {
        return;
      } else {
        await monitoringRef.update({'customer_id': "none"});
      }
      //Updates the status field in rental

      await _firestore.collection('rental').doc(id).update({'status': 'done'});
      Get.snackbar('Success', 'Booking finished successfully',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
      //Update the car status back to available
    } catch (error) {
      Get.snackbar('Error', 'Failed to finish booking',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    }
  }

  Future<void> updateCar(
      String carId,
      String carType,
      String carName,
      String licensePlate,
      String rentPrice,
      String imageUrl,
      String brand,
      String location,
      bool availability) async {
    try {
      await _firestore.collection('car').doc(carId).update({
        'car_type': carType,
        'car_name': carName,
        'availability': availability,
        'license_plate': licensePlate,
        'rent_price': rentPrice,
        'img_url': imageUrl,
        'brand': brand,
        'location': location
      });
      Get.snackbar('Success', 'Car updated successfully',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    } catch (error) {
      Get.snackbar('Error', 'Failed to update car: $error',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    }
  }

  Future<void> deleteCar(String carId) async {
    try {
      await _firestore
          .collection('car')
          .doc(carId)
          .update({'is_usable': false});
      Get.snackbar('Success', 'Car deleted successfully',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    } catch (error) {
      Get.snackbar('Error', 'Failed to delete car: $error',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection('customer').doc(customerId).delete();
      Get.snackbar('Success', 'Customer deleted successfully',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    } catch (error) {
      Get.snackbar('Error', 'Failed to delete customer: $error',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
      print(error);
    }
  }

  Future<List<Car>> getCars() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('car')
        .where('is_usable', isEqualTo: true)
        .get();
    return querySnapshot.docs.map((doc) {
      return Car(
        id: doc.id,
        carType: doc['car_type'],
        carName: doc['car_name'],
        brand: doc['brand'],
        location: doc['location'],
        availability: doc['availability'],
        imgUrl: doc['img_url'],
        licensePlate: doc['license_plate'],
        rentPrice: doc['rent_price'],
      );
    }).toList();
  }

  Future<List<Car>> getRentedCars() async {
    QuerySnapshot querySnapshot = await _firestore.collection('car').get();
    return querySnapshot.docs.map((doc) {
      return Car(
        id: doc.id,
        carType: doc['car_type'],
        carName: doc['car_name'],
        brand: doc['brand'],
        location: doc['location'],
        availability: doc['availability'],
        imgUrl: doc['img_url'],
        licensePlate: doc['license_plate'],
        rentPrice: doc['rent_price'],
      );
    }).toList();
  }

  Future<List<Customer>> getCustomers() async {
    QuerySnapshot querySnapshot = await _firestore.collection('customer').get();
    return querySnapshot.docs.map((doc) {
      return Customer(
          id: doc.id,
          birthDate: doc['birth_date'],
          customerName: doc['customer_name'],
          emailAddress: doc['email_address'],
          nik: doc['nik'].toString(),
          phoneNum: doc['phone_num'].toString(),
          status: doc['status']);
    }).toList();
  }

  Future<Customer?> getCustomer(String customerId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('customer').doc(customerId).get();
    if (snapshot.exists) {
      return Customer(
          id: snapshot.id,
          birthDate: snapshot['birth_date'],
          customerName: snapshot['customer_name'],
          emailAddress: snapshot['email_address'],
          nik: snapshot['nik'],
          phoneNum: snapshot['phone_num'],
          status: snapshot['status']);
    }
    return null;
  }

  Future<void> addCustomer(String customerName, String nik, String phoneNum,
      String birthDate, String emailAddress, String status) async {
    try {
      await _firestore.collection('customer').add({
        'customer_name': customerName,
        'nik': nik.toInt(),
        'phone_num': phoneNum.toInt(),
        'birth_date': birthDate,
        'email_address': emailAddress,
        'status': status
      });
      Get.snackbar('Success', 'Customer added successfully',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    } catch (error) {
      Get.snackbar('Error', 'Failed to add customer: $error',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    }
  }

  Future<void> updateCustomer(
      String customerId,
      String customerName,
      String nik,
      String phoneNum,
      String birthDate,
      String emailAddress,
      String status) async {
    try {
      await _firestore.collection('customer').doc(customerId).update({
        'customer_name': customerName,
        'nik': nik.toInt(),
        'phone_num': phoneNum.toInt(),
        'birth_date': birthDate,
        'email_address': emailAddress,
        'status': status
      });
      Get.snackbar('Success', 'Customer updated successfully',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    } catch (error) {
      Get.snackbar('Error', 'Failed to update customer: $error',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    }
  }

  Future<Car?> getCar(String carId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('car').doc(carId).get();
    if (snapshot.exists) {
      return Car(
        id: snapshot.id,
        carType: snapshot['car_type'],
        carName: snapshot['car_name'],
        location: snapshot['location'],
        brand: snapshot['brand'],
        availability: snapshot['availability'],
        imgUrl: snapshot['img_url'],
        licensePlate: snapshot['license_plate'],
        rentPrice: snapshot['rent_price'],
      );
    }
    return null;
  }

  Future<List<RentalMonitoring>> fetchRentalMonitoringData() async {
    List<RentalMonitoring> rentalMonitorings = [];

    QuerySnapshot rentalMonitoringSnapshot =
        await _firestore.collection('rental_monitoring').get();

    for (var doc in rentalMonitoringSnapshot.docs) {
      var rentalData =
          RentalMonitoring.fromFirestore(doc.data() as Map<String, dynamic>);

      Car? carDetails;
      String? carName;
      String? customerName;

      if (rentalData.carId != null) {
        // Fetch car details only if carId is not null
        DocumentSnapshot carDoc =
            await _firestore.collection('car').doc(rentalData.carId).get();

        if (carDoc.exists) {
          carDetails = Car.fromFirestore(
              carDoc.data() as Map<String, dynamic>, carDoc.id);
          Map<String, dynamic>? carData =
              carDoc.data() as Map<String, dynamic>?;
          if (carData != null) {
            carName = carData['car_name'];
          }
        }
      }

      if (rentalData.customerId != "none") {
        DocumentSnapshot customerDoc = await _firestore
            .collection('customer')
            .doc(rentalData.customerId)
            .get();

        if (customerDoc.exists) {
          Map<String, dynamic>? customerData =
              customerDoc.data() as Map<String, dynamic>?;
          if (customerData != null) {
            customerName = customerData['customer_name'];
          }
        }
      } else {
        customerName = "Not Rented";
      }

      // Assign fetched details to the rental monitoring data
      rentalData.carDetails = carDetails;
      rentalData.carName = carName;
      rentalData.customerName = customerName;

      rentalMonitorings.add(rentalData);
    }

    return rentalMonitorings;
  }
}
