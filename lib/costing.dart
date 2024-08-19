import 'dart:ffi';

import 'package:car/firebase/firebase_controller.dart';
import 'package:car/costing_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';
import 'models/car_model.dart';

class CostingPage extends StatefulWidget {
  CostingPage({super.key});

  @override
  State<CostingPage> createState() => _CostingPageState();
}

class _CostingPageState extends State<CostingPage> {
  DateTime selectedDate = DateTime.now();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double totalRev = 0.0;

  Car? car;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    var selectedYear = selectedDate.year;
    var selectedMonth = selectedDate.month;

    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Picker for Month
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedMonth - 1,
                    ),
                    itemExtent: 32.0,
                    backgroundColor: Colors.white,
                    onSelectedItemChanged: (int index) {
                      selectedMonth = index + 1;
                    },
                    children: List<Widget>.generate(12, (int index) {
                      return Center(
                        child: Text(
                          DateFormat('MMMM').format(DateTime(0, index + 1)),
                        ),
                      );
                    }),
                  ),
                ),
                // Picker for Year
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedYear -
                          DateTime.now().year +
                          100, // adjust for the range of years
                    ),
                    itemExtent: 32.0,
                    backgroundColor: Colors.white,
                    onSelectedItemChanged: (int index) {
                      selectedYear = DateTime.now().year -
                          100 +
                          index; // adjust for the range of years
                    },
                    children: List<Widget>.generate(200, (int index) {
                      // 200 years range
                      return Center(
                        child: Text(
                          '${DateTime.now().year - 100 + index}', // adjust for the range of years
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        });
    setState(() {
      selectedDate = DateTime(selectedYear, selectedMonth);
    });
  }

  String formatNumberWithThousandSeparator(num number) {
    var parts = number.toStringAsFixed(2).split('.');
    var integerPart = parts[0];
    var decimalPart = parts[1];

    var withSeparator =
        RegExp(r'\B(?=(\d{3})+(?!\d))').allMatches(integerPart).length;
    for (var i = 0; i < withSeparator; i++) {
      integerPart = integerPart.replaceAllMapped(
          RegExp(r'(\d+)(\d{3})'), (Match m) => '${m[1]},${m[2]}');
    }

    return '$integerPart.$decimalPart';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Text('SCReMS',
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        )),
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Revenue',
                          style: primaryTextStyle(
                              weight: FontWeight.bold, size: 25),
                        ),
                        // Date Picker Button
                        GestureDetector(
                          onTap: () => _selectMonthYear(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.calendar_today,
                                  size: 20), // Calendar icon
                              SizedBox(width: 4),
                              Text(
                                "${DateFormat('MM/yyyy').format(selectedDate)}", // Show selected month and year
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.arrow_drop_down,
                                  size: 24), // Dropdown icon
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: SingleChildScrollView(
                            child: Container(
                                height: MediaQuery.of(context).size.height * .7,
                                child: CarList(selectedDate: selectedDate)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarList extends StatelessWidget {
  final DateTime selectedDate;
  final FirebaseController controller = Get.put(FirebaseController());

  CarList({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Car>>(
      future: controller.fetchRentedCars(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          List<Car> cars = snapshot.data ?? [];
          if (cars.isEmpty) {
            return Center(child: Text('No revenue available'));
          }
          return ListView.builder(
            itemCount: cars.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              Car car = cars[index];
              return Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          car.carName,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${car.licensePlate} | ${car.carName} | ${car.carType} | ${car.availability ? 'Available' : 'Rented'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_pin, color: Colors.grey.shade400),
                          Text(
                            car.location,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.calculate, color: Colors.white),
                        onPressed: () {
                          Get.to(CostingDetails(
                            car: car,
                            monthYear:
                                DateFormat('MM/yyyy').format(selectedDate),
                          ));
                        },
                        label: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Calculate',
                              style: primaryTextStyle(color: Colors.white)),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }
}
