// rental_controller.dart
import 'package:car/firebase/firebase_service.dart';
import 'package:car/models/car_model.dart';
import 'package:get/get.dart';

class FirebaseController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  Rx<Customer?> customer = Rx<Customer?>(null);
  Rx<Car?> car = Rx<Car?>(null);
  Rx<List<Customer>> customers = Rx<List<Customer>>([]);
  Rx<List<Rental>> rental = Rx<List<Rental>>([]);
  Rx<RentalMonitoring?> rentalMonitoring = Rx<RentalMonitoring?>(null);
  RxBool isLoading = true.obs;
  var totalRevenue = 0.obs;

  Future<List<Car>> fetchCars() async {
    List<Car> carList = await _firebaseService.getCars();
    return carList;
  }

  Future<List<Car>> fetchRentedCars() async {
    List<Car> carList = await _firebaseService.getRentedCars();
    return carList;
  }

  Future<List<Rental>> fetchRentals(String carId, String monthYear) async {
    List<Rental> rentalList =
        await _firebaseService.fetchRentals(carId, monthYear);
    rental.value = rentalList;
    totalRevenue.value =
        rentalList.fold(0, (sum, rental) => sum + rental.revenue);
    return rentalList;
  }

  Future<List<Rental>> fetchAllRentals() async {
    List<Rental> rentalList = await _firebaseService.fetchAllRentals();
    rental.value = rentalList;
    return rentalList;
  }

  Future<List<Customer>> fetchCustomers() async {
    List<Customer> customerList =
        []; // Declare customerList outside the try block
    try {
      isLoading.value =
          true; // Assume isLoading is an RxBool or similar observable
      customerList =
          await _firebaseService.getCustomers(); // Fetch the customers
      customers.value =
          customerList; // Assume customers is an RxList<Customer> or similar
    } catch (e) {
      print("Error fetching customers: $e");
    } finally {
      isLoading.value =
          false; // Always executed, ensures loading state is reset
    }
    return customerList;
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
    await _firebaseService.addCar(
        carType, carName, licensePlate, rentPrice, imageUrl, brand, location);
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
    bool availability,
  ) async {
    await _firebaseService.updateCar(carId, carType, carName, licensePlate,
        rentPrice, imageUrl, brand, location, availability);
  }

  Future<void> deleteCar(String carId) async {
    await _firebaseService.deleteCar(carId);
  }

  Future<void> addRental(String carId, String customerId, String startDate,
      String endDate, String destination, int revenue) async {
    await _firebaseService.addRental(
        carId, customerId, startDate, endDate, destination, revenue);
  }

  Future<List<RentalMonitoring>> getRentalMonitoringData(
      {required String carID}) async {
    return await _firebaseService.fetchRentalMonitoringData();
  }

  Future<void> addCustomer(String customerName, String nik, String phoneNum,
      String birthDate, String emailAddress, String status) async {
    await _firebaseService.addCustomer(
        customerName, nik, phoneNum, birthDate, emailAddress, status);
  }

  Future<void> updateCustomer(
      String customerId,
      String customerName,
      String nik,
      String phoneNum,
      String birthDate,
      String emailAddress,
      String status) async {
    await _firebaseService.updateCustomer(customerId, customerName, nik,
        phoneNum, birthDate, emailAddress, status);
  }

  Future<void> deleteCustomer(String customerId) async {
    await _firebaseService.deleteCustomer(customerId);
  }

  Future<void> finishBooking(String carId, String id) async {
    await _firebaseService.finishBooking(carId, id);
  }

  @override
  void onInit() {
    fetchCars();
    fetchCustomers();
    super.onInit();
  }
}
