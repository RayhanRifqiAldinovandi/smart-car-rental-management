import 'package:car/firebase/firebase_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'models/car_model.dart';
import 'package:intl/intl.dart';

class CostingDetails extends StatefulWidget {
  final Car car;
  final String monthYear;

  CostingDetails({
    Key? key,
    required this.car,
    required this.monthYear,
  }) : super(key: key);

  @override
  State<CostingDetails> createState() => _CostingDetailsState();
}

class _CostingDetailsState extends State<CostingDetails> {
  final FirebaseController firebaseController = Get.put(FirebaseController());

  List<Rental> rentals = [];
  int totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    fetchRentalsAndUpdateState();
  }

  void fetchRentalsAndUpdateState() async {
    try {
      if (!mounted) return;

      // Fetch rentals using your Firebase controller
      List<Rental> fetchedRentals = await Get.find<FirebaseController>()
          .fetchRentals(widget.car.id, widget.monthYear);

      // Update the state with the fetched rentals and calculate total revenue
      setState(() {
        rentals = fetchedRentals;
        totalRevenue =
            fetchedRentals.fold(0, (sum, rental) => sum + rental.revenue);
      });
    } catch (e) {
      // Handle potential errors that might occur during the fetch operation
      print('Error fetching rentals: $e');
      setState(() {
        rentals = [];
        totalRevenue = 0;
      });
    }
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
    var newlyTotalRev = formatNumberWithThousandSeparator(totalRevenue);

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(children: [
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: Get.width,
            height: Get.height * .95,
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: Colors.grey.shade200,
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration:
                      boxDecorationWithRoundedCorners(borderRadius: radius(20)),
                  child: const Icon(CupertinoIcons.chevron_back),
                ),
              ),
              30.height,
              Text(
                "\Rp ${newlyTotalRev}",
                style: primaryTextStyle(weight: FontWeight.bold, size: 25),
              ),
              SizedBox(height: 20.0),
              Text(
                widget.car.carName,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Revenues',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Expanded(
                  child: ListView.builder(
                      itemCount: rentals.length,
                      itemBuilder: (context, index) {
                        final rental = rentals[index];
                        var revenue =
                            formatNumberWithThousandSeparator(rental.revenue);
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
                                ],
                              ),
                              Expanded(
                                child: Text(
                                  '\Rp ${revenue}',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      })),
            ]),
          ),
        ),
      ]),
    );
  }
}
