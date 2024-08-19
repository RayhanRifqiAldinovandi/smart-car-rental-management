import 'dart:io';

import 'package:car/models/car_model.dart';
import 'package:car/controller/controller.dart';
import 'package:car/firebase/firebase_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

class CarDetails extends StatefulWidget {
  final Car car;

  CarDetails({Key? key, required this.car}) : super(key: key);

  @override
  State<CarDetails> createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  final Controller controller = Get.put(Controller());

  FirebaseStorage storage = FirebaseStorage.instance;

  final FirebaseController firebaseController = Get.put(FirebaseController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _carIdController = TextEditingController();
  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _rentPriceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _barndController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _availability = 'Available';

  Reference? upload;
  String fileName = "";
  XFile? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: Get.width,
              height: Get.height * .45,
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: Colors.grey.shade200,
                borderRadius: radiusOnly(bottomLeft: 40, bottomRight: 40),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: boxDecorationWithRoundedCorners(
                          borderRadius: radius(20)),
                      child: const Icon(CupertinoIcons.chevron_back),
                    ),
                  ),
                  30.height,
                  Text(
                    widget.car.carName,
                    style: primaryTextStyle(weight: FontWeight.bold, size: 25),
                  ),
                  40.height,
                  Align(
                    alignment: Alignment.topRight,
                    child: Image.network(
                      widget.car.imgUrl,
                      height: Get.width * .4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Specs',
                      style:
                          primaryTextStyle(size: 20, weight: FontWeight.bold),
                    ),
                    210.width,
                    Container(
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          _carIdController.text = widget.car.id;
                          _carTypeController.text = widget.car.carType;
                          _carNameController.text = widget.car.carName;
                          _licensePlateController.text =
                              widget.car.licensePlate;
                          _rentPriceController.text = widget.car.rentPrice;
                          _imageController.text = widget.car.imgUrl;
                          _barndController.text = widget.car.brand;
                          _locationController.text = widget.car.location;
                          _availability = widget.car.availability
                              ? 'Available'
                              : 'Unavailable';
                          Get.bottomSheet(
                            isScrollControlled: true,
                            SingleChildScrollView(
                              child: Container(
                                decoration: boxDecorationWithRoundedCorners(
                                  backgroundColor: Colors.white,
                                  borderRadius:
                                      radiusOnly(topLeft: 20, topRight: 20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        TextFormField(
                                          controller: _carTypeController,
                                          decoration: const InputDecoration(
                                              labelText: 'Car Type',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter car type';
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          controller: _carNameController,
                                          decoration: const InputDecoration(
                                              labelText: 'Car Name',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter car name';
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          controller: _licensePlateController,
                                          decoration: const InputDecoration(
                                              labelText: 'License Plate',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter license plate';
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          controller: _rentPriceController,
                                          decoration: const InputDecoration(
                                              labelText: 'Rent Price',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
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
                                            Reference referenceDir =
                                                refRoot.child('car_image');
                                            if (imageFile?.path == null) {
                                              return;
                                            }
                                            // File name is based on the time it was uploaded
                                            fileName = DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString();
                                            upload =
                                                referenceDir.child(fileName);
                                            fileName =
                                                await upload!.getDownloadURL();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            decoration:
                                                boxDecorationWithRoundedCorners(
                                              borderRadius: radius(30),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Add Image',
                                                style: primaryTextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextFormField(
                                          controller: _barndController,
                                          decoration: const InputDecoration(
                                              labelText: 'Brand',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter brand name';
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          controller: _locationController,
                                          decoration: const InputDecoration(
                                              labelText: 'Location',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter location';
                                            }
                                            return null;
                                          },
                                        ),
                                        DropdownButtonFormField<String>(
                                          value: _availability,
                                          items: ['Available', 'Unavailable']
                                              .map((label) => DropdownMenuItem(
                                                    child: Text(label),
                                                    value: label,
                                                  ))
                                              .toList(),
                                          decoration: const InputDecoration(
                                              labelText: 'Availability',
                                              labelStyle: TextStyle(
                                                  color: Colors.grey)),
                                          onChanged: (value) {
                                            setState(() {
                                              _availability = value!;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please select availability status';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        InkWell(
                                          onTap: () async {
                                            if (imageFile == null) {
                                              fileName = widget.car.imgUrl;
                                            } else {
                                              if (upload != null) {
                                                await upload!.putFile(
                                                    File(imageFile!.path));
                                                fileName = await upload!
                                                    .getDownloadURL(); // Get new image URL
                                              }
                                            }
                                            if (_formKey.currentState!
                                                .validate()) {
                                              bool availability =
                                                  _availability == 'Available';
                                              await firebaseController
                                                  .updateCar(
                                                      _carIdController.text,
                                                      _carTypeController.text,
                                                      _carNameController.text,
                                                      _licensePlateController
                                                          .text,
                                                      _rentPriceController.text,
                                                      fileName,
                                                      _barndController.text,
                                                      _locationController.text,
                                                      availability);

                                              setState(() {});
                                              // ignore: use_build_context_synchronously
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            decoration:
                                                boxDecorationWithRoundedCorners(
                                                    borderRadius: radius(30),
                                                    backgroundColor:
                                                        Colors.blue),
                                            child: Center(
                                              child: Text(
                                                'Update Car',
                                                style: primaryTextStyle(
                                                    color: Colors.white),
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
                        icon: const Icon(
                          Icons.edit,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        padding: EdgeInsets.only(right: 10),
                        visualDensity: VisualDensity.compact,
                        onPressed: () async {
                          _carIdController.text = widget.car.id;

                          // Show confirmation dialog
                          final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text(
                                      'Are you sure you want to delete this car?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;

                          // If confirmed, delete the car
                          if (confirm) {
                            await firebaseController
                                .deleteCar(_carIdController.text);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                20.height,
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  childAspectRatio: 3,
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 15,
                  children: [
                    SpecCard(title: 'Type', text: widget.car.carType),
                    SpecCard(
                        title: 'License Plate', text: widget.car.licensePlate),
                    SpecCard(title: 'Brand', text: widget.car.brand),
                  ],
                ),
                40.height,
                Text(
                  'Availability',
                  style: primaryTextStyle(size: 20, weight: FontWeight.bold),
                ),
                10.height,
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: radius(14),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_pin,
                        size: 18,
                      ),
                      10.width,
                      Text(widget.car.availability
                          ? "Available"
                          : 'Unavailable'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SpecCard extends StatelessWidget {
  SpecCard({
    super.key,
    required this.title,
    required this.text,
  });

  String title;
  String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * .4,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(14),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: primaryTextStyle(weight: FontWeight.bold, size: 14),
          ),
          5.height,
          Text(
            text,
            style: primaryTextStyle(size: 13),
          ),
        ],
      ),
    );
  }
}
