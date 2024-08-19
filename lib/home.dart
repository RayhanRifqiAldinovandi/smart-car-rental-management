import 'dart:io';

import 'package:car/car_details.dart';
import 'package:car/controller/controller.dart';
import 'package:car/firebase/firebase_controller.dart';
import 'package:car/location.dart';
import 'package:car/models/car_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Controller controller = Get.put(Controller());

  final FirebaseController firebaseController = Get.put(FirebaseController());

  final _formKey = GlobalKey<FormState>();

  final storage = FirebaseStorage.instance;
  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _rentPriceController = TextEditingController();
  final TextEditingController _barndController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

//Variables to hold image
  Reference? upload;
  String fileName = "";
  XFile? imageFile;

  @override
  Widget build(BuildContext context) {
    firebaseController.fetchCars();
    return Scaffold(
      floatingActionButton: IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: () {
          Get.bottomSheet(
            isScrollControlled: true,
            SingleChildScrollView(
              child: Container(
                decoration: boxDecorationWithRoundedCorners(
                  backgroundColor: Colors.white,
                  borderRadius: radiusOnly(topLeft: 20, topRight: 20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextFormField(
                          controller: _carTypeController,
                          decoration: const InputDecoration(
                              labelText: 'Car Type',
                              labelStyle: TextStyle(color: Colors.grey)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter car type';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _carNameController,
                          decoration: const InputDecoration(
                              labelText: 'Car Name',
                              labelStyle: TextStyle(color: Colors.grey)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter car name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _licensePlateController,
                          decoration: const InputDecoration(
                              labelText: 'License Plate',
                              labelStyle: TextStyle(color: Colors.grey)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter license plate';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _rentPriceController,
                          decoration: const InputDecoration(
                              labelText: 'Rent Price',
                              labelStyle: TextStyle(color: Colors.grey)),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter rent price';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            ImagePicker imgPick = ImagePicker();
                            imageFile = await imgPick.pickImage(
                                source: ImageSource.gallery);

                            Reference refRoot = storage.ref();
                            Reference referenceDir = refRoot.child('car_image');
                            if (imageFile?.path == null) {
                              return;
                            }
                            //File name is based on the time it was uploaded
                            fileName = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            upload = referenceDir.child(fileName);
                            fileName = await upload!.getDownloadURL();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: boxDecorationWithRoundedCorners(
                              borderRadius: radius(30),
                            ),
                            child: Center(
                              child: Text(
                                'Add Image',
                                style: primaryTextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _barndController,
                          decoration: const InputDecoration(
                              labelText: 'Brand',
                              labelStyle: TextStyle(color: Colors.grey)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter brand name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                              labelText: 'Location',
                              labelStyle: TextStyle(color: Colors.grey)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            if (imageFile! == null) {
                              return;
                            } else {
                              await upload!.putFile(File(imageFile!.path));
                              fileName = await upload!.getDownloadURL();
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, add the car
                                await firebaseController.addCar(
                                  _carTypeController.text,
                                  _carNameController.text,
                                  _licensePlateController.text,
                                  _rentPriceController.text,
                                  fileName,
                                  _barndController.text,
                                  _locationController.text,
                                );

                                setState(() {});
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: boxDecorationWithRoundedCorners(
                                borderRadius: radius(30),
                                backgroundColor: Colors.blue),
                            child: Center(
                              child: Text(
                                'Add Car',
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
        },
        icon: const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
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
                    Text(
                      'Cars',
                      style:
                          primaryTextStyle(weight: FontWeight.bold, size: 25),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CarList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarList extends StatelessWidget {
  final FirebaseController controller = Get.put(FirebaseController());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Car>>(
      future: controller.fetchCars(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Car> cars = snapshot.data!;
          return ListView.builder(
              itemCount: cars.length, // Define the number of items
              itemBuilder: (context, index) {
                Car car = cars[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: Get.width * 0.9,
                  height: Get.width * 0.6,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,

                        // left: 0,
                        child: Container(
                          height: Get.width * .55,
                          width: Get.width * .9,
                          padding: const EdgeInsets.all(20),
                          decoration: boxDecorationWithRoundedCorners(
                              borderRadius: radius(20)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      car.carName,
                                      style: primaryTextStyle(
                                          size: 18, weight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '${car.licensePlate} | ${car.carName} | ${car.carType} | ${car.availability ? 'Available' : 'Rented'}',
                                    style: primaryTextStyle(
                                        size: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              5.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_pin,
                                    color: Colors.grey.shade400,
                                  ),
                                  Center(
                                    child: Text(
                                      car.location,
                                      style: primaryTextStyle(
                                          size: 16, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              20.height,
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9, vertical: 12),
                                      decoration:
                                          boxDecorationWithRoundedCorners(
                                        borderRadius: radius(12),
                                        backgroundColor: Colors.blue.shade600,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Get.to(LocationPage(
                                            car: car,
                                          ));
                                        },
                                        child: Text(
                                          'Show Location',
                                          style: primaryTextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    20.width,
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      decoration:
                                          boxDecorationWithRoundedCorners(
                                        borderRadius: radius(12),
                                        border: Border.all(
                                            color: Colors.blue.shade600),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Get.to(CarDetails(
                                            car: car,
                                          ));
                                        },
                                        child: Text(
                                          'Show Details',
                                          style: primaryTextStyle(
                                              color: Colors.blue.shade600),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 30,
                            ),
                            Image.network(
                              car.imgUrl,
                              width: Get.width * .5,
                              height: Get.width * .24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
