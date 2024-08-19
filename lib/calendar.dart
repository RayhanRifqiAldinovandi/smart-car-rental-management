import 'package:car/firebase/firebase_controller.dart';
import 'package:car/models/car_model.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirebaseController firebaseController = Get.put(FirebaseController());
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCarId;
  String? _selectedCustomerId;
  String? _selectedCarRentPrice;
  List<Rental> rentals = [];
  List<Car> car = [];
  final TextEditingController _destinationController = TextEditingController();
  bool isButtonVisible = true;

  late int _revenue;

  @override
  void initState() {
    fetchRentalsAndUpdateState();
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  void fetchRentalsAndUpdateState() async {
    try {
      if (!mounted) return;

      // Fetch rentals using your Firebase controller
      List<Rental> fetchedRentals =
          await Get.find<FirebaseController>().fetchAllRentals();

      List<Car> fetchedCar = await Get.find<FirebaseController>().fetchCars();
      // Update the state with the fetched rentals and calculate total revenue
      setState(() {
        car = fetchedCar;
        rentals = fetchedRentals;
      });
    } catch (e) {
      // Handle potential errors that might occur during the fetch operation
      print('Error fetching rentals: $e');
      setState(() {
        car = [];
        rentals = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchRentalsAndUpdateState();
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calendar Rental',
                      style:
                          primaryTextStyle(weight: FontWeight.bold, size: 25),
                    ),
                    TableCalendar(
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay; // Update `_selectedDay`
                          _focusedDay =
                              focusedDay; // Update `_focusedDay` to control the calendar view
                        });
                        _startDateController.text =
                            DateFormat('yyyy-MM-dd').format(_selectedDay);
                        // Open the bottom sheet with the form after a day is selected
                        _openFormBottomSheet(context);
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    )
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _openFormBottomSheet(context),
                child: Text("Add Schedule"),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: rentals.length,
                    itemBuilder: (context, index) {
                      final rental = rentals[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1.0,
                              blurRadius: 5.0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rental.customerName,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  rental.carName,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  rental.destination,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  '${DateFormat('dd MMM yyyy').format(rental.startDate)} - ${DateFormat('dd MMM yyyy').format(rental.endDate)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                StatefulBuilder(builder: (context, setStateSB) {
                                  return Container(
                                    margin: EdgeInsets.only(top: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    decoration: boxDecorationWithRoundedCorners(
                                      borderRadius: radius(12),
                                      backgroundColor: Colors.blue.shade600,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setStateSB(() {
                                          isButtonVisible = false;
                                        });
                                        firebaseController.finishBooking(
                                            rental.carId, rental.id);
                                      },
                                      child: Text(
                                        'Finish Booking',
                                        style: primaryTextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  );
                                })
                              ],
                            )
                          ],
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openFormBottomSheet(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FutureBuilder<List<Car>>(
                    future: firebaseController
                        .fetchCars(), // Assume _firebaseService is initialized and has fetchCars() method
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Car>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Or another widget for loading state
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Handle error state
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        List<Car> cars = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                              labelText: 'Select Car',
                              labelStyle: TextStyle(color: Colors.grey)),
                          items: cars.map((Car car) {
                            return DropdownMenuItem<String>(
                              value: car.id, // Store car ID as value
                              child: Text(
                                  car.carName), // Display car name to the user
                            );
                          }).toList(),
                          onChanged: (value) {
                            // Update the state with the new selected car ID
                            setState(() {
                              _selectedCarId = value;
                              _selectedCarRentPrice = cars
                                  .firstWhere((car) => car.id == value)
                                  .rentPrice;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a car' : null,
                          value: _selectedCarId, // Initial selected value
                        );
                      } else {
                        return Text(
                            'No cars found'); // Handle case with no cars
                      }
                    },
                  ),
                  FutureBuilder<List<Customer>>(
                    future: firebaseController
                        .fetchCustomers(), // Assume _firebaseService is initialized and has fetchCars() method
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Customer>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Or another widget for loading state
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Handle error state
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        List<Customer> customers = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                              labelText: 'Select Customer',
                              labelStyle: TextStyle(color: Colors.grey)),
                          items: customers.map((Customer customer) {
                            return DropdownMenuItem<String>(
                              value: customer.id, // Store car ID as value
                              child: Text(customer
                                  .customerName), // Display car name to the user
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCustomerId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a car' : null,
                          value: _selectedCustomerId,
                        );
                      } else {
                        return Text('No customers found');
                      }
                    },
                  ),
                  TextFormField(
                    controller: _startDateController,
                    readOnly: true, // Prevent manual editing
                    decoration: const InputDecoration(
                        labelText: 'Start Date',
                        labelStyle: TextStyle(color: Colors.grey)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please pick a start date';
                      }
                      return null;
                    },
                    onTap: () => _selectDate(context,
                        isStartDate: true), // For start date selection
                  ),
                  TextFormField(
                    controller: _endDateController,
                    readOnly: true, // Prevent manual editing
                    decoration: const InputDecoration(
                        labelText: 'End Date',
                        labelStyle: TextStyle(color: Colors.grey)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please pick an end date';
                      }
                      return null;
                    },
                    onTap: () => _selectDate(context,
                        isStartDate: false), // For end date selection
                  ),
                  TextFormField(
                    controller: _destinationController,
                    // Prevent manual editing
                    decoration: const InputDecoration(
                        labelText: 'Set Destination',
                        labelStyle: TextStyle(color: Colors.grey)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a destination';
                      }
                      return null;
                    },
                    // For end date selection
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, add the car
                        _revenue = _calculateRevenue()!;
                        await firebaseController.addRental(
                          _selectedCarId!,
                          _selectedCustomerId!,
                          _startDateController.text,
                          _endDateController.text,
                          _destinationController.text,
                          _revenue,
                        );

                        setState(() {});
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: boxDecorationWithRoundedCorners(
                          borderRadius: radius(30),
                          backgroundColor: Colors.blue),
                      child: Center(
                        child: Text(
                          'Add Rental Schedule',
                          style: primaryTextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int? _calculateRevenue() {
    if (_startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty &&
        _selectedCarRentPrice != null) {
      DateTime startDate =
          DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      DateTime endDate =
          DateFormat('yyyy-MM-dd').parse(_endDateController.text);
      int days = endDate.difference(startDate).inDays +
          1; // +1 if you count both start and end dates

      int rentPrice = int.parse(_selectedCarRentPrice!);
      int revenue = days * rentPrice;

      return revenue;
    } else {
      return null;
    }
  }

  void _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      if (isStartDate) {
        setState(() {
          _selectedDay = picked;
          _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        });
      } else {
        setState(() {
          _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        });
      }
    }
  }
}
