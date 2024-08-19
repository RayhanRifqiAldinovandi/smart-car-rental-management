import 'package:car/firebase/firebase_controller.dart';
import 'package:car/controller/controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:nik_validator/nik_validator.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Controller controller = Get.put(Controller());

  final FirebaseController firebaseController = Get.put(FirebaseController());

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _NameController = TextEditingController();
  final TextEditingController _NIKController = TextEditingController();
  final TextEditingController _PhoneNumberController = TextEditingController();
  final TextEditingController _BirthDateController = TextEditingController();
  final TextEditingController _EmailController = TextEditingController();
  final TextEditingController _StatusController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  NIKModel? model;

  void validate() async {
    if (_NIKController.text.isNotEmpty) {
      NIKModel result =
          await NIKValidator.instance.parse(nik: _NIKController.text);

      ///use result.valid to check if the nik is valid
      setState(() {
        model = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    firebaseController.fetchCustomers();
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
                          controller: _NameController,
                          decoration: const InputDecoration(
                              labelText: 'Customer Name',
                              labelStyle: TextStyle(color: Colors.grey)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Customer Name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _NIKController,
                          decoration: const InputDecoration(
                              labelText: 'NIK',
                              labelStyle: TextStyle(color: Colors.grey)),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(16),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Customer NIK';
                            }

                            if (value.length != 16) {
                              return 'NIK needs to be have a length of 16 numbers';
                            }
                            if (value.isNotEmpty && value.length == 16) {
                              validate();
                              if (model!.valid == false) {
                                return 'NIK is invalid';
                              }
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _PhoneNumberController,
                          decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(color: Colors.grey)),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(11),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Customer Phone Number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _BirthDateController,
                          decoration: const InputDecoration(
                              labelText: 'Birth Date',
                              labelStyle: TextStyle(color: Colors.grey)),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now());

                            if (pickedDate != null &&
                                pickedDate != _selectedDate) {
                              setState(() {
                                _selectedDate = pickedDate;
                                _BirthDateController.text =
                                    "${_selectedDate.toLocal().day}/${_selectedDate.toLocal().month}/${_selectedDate.toLocal().year}";
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Customer Birth Date';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _EmailController,
                          decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.grey)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Customer Email';
                            }
                            if (!value.contains("@")) {
                              return 'Email format is wrong';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _StatusController,
                          decoration: const InputDecoration(
                              labelText: 'Status',
                              labelStyle: TextStyle(color: Colors.grey)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Customer Status';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, add the car
                              validate();
                              await firebaseController.addCustomer(
                                  _NameController.text,
                                  _NIKController.text,
                                  _PhoneNumberController.text,
                                  _BirthDateController.text,
                                  _EmailController.text,
                                  _StatusController.text);

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
                                'Add Customer',
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
                      'Customers',
                      style:
                          primaryTextStyle(weight: FontWeight.bold, size: 25),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomerList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerList extends StatefulWidget {
  CustomerList({super.key});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  final Controller controller = Get.put(Controller());

  final FirebaseController firebaseController = Get.put(FirebaseController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _NameController = TextEditingController();
  final TextEditingController _NIKController = TextEditingController();
  final TextEditingController _PhoneNumberController = TextEditingController();
  final TextEditingController _BirthDateController = TextEditingController();
  final TextEditingController _EmailController = TextEditingController();
  final TextEditingController _StatusController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return GetX<FirebaseController>(
        init: FirebaseController(),
        initState: (s) {
          s.controller?.fetchCustomers();
        },
        builder: (controller) {
          if (controller.customers.value.isEmpty &&
              controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount:
                controller.customers.value.length, // Assuming you have 10 cars
            itemBuilder: (context, index) {
              var customer = controller.customers.value[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(20),
                  backgroundColor: context.cardColor,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            _customerIdController.text = customer.id;
                            _NameController.text = customer.customerName;
                            _NIKController.text = customer.nik;
                            _PhoneNumberController.text = customer.phoneNum;
                            _BirthDateController.text = customer.birthDate;
                            _EmailController.text = customer.emailAddress;
                            _StatusController.text = customer.status;
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
                                            controller: _NameController,
                                            decoration: const InputDecoration(
                                                labelText: 'Customer Name',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey)),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter Customer Name';
                                              }
                                              return null;
                                            },
                                          ),
                                          TextFormField(
                                            controller: _NIKController,
                                            decoration: const InputDecoration(
                                                labelText: 'NIK',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey)),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter Customer NIK';
                                              }
                                              return null;
                                            },
                                          ),
                                          TextFormField(
                                            controller: _PhoneNumberController,
                                            decoration: const InputDecoration(
                                                labelText: 'Phone Number',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey)),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              LengthLimitingTextInputFormatter(
                                                  11),
                                            ],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter Customer Phone Number';
                                              }
                                              return null;
                                            },
                                          ),
                                          TextFormField(
                                            controller: _BirthDateController,
                                            decoration: const InputDecoration(
                                                labelText: 'Birth Date',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey)),
                                            onTap: () async {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          _selectedDate,
                                                      firstDate: DateTime(1900),
                                                      lastDate: DateTime.now());

                                              if (pickedDate != null &&
                                                  pickedDate != _selectedDate) {
                                                setState(() {
                                                  _selectedDate = pickedDate;
                                                  _BirthDateController.text =
                                                      "${_selectedDate.toLocal().day}/${_selectedDate.toLocal().month}/${_selectedDate.toLocal().year}";
                                                });
                                              }
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter Customer Birth Date';
                                              }
                                              return null;
                                            },
                                          ),
                                          TextFormField(
                                            controller: _EmailController,
                                            decoration: const InputDecoration(
                                                labelText: 'Email',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey)),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter Customer Email';
                                              }
                                              if (!value.contains("@")) {
                                                return 'Email format is wrong';
                                              }
                                              return null;
                                            },
                                          ),
                                          TextFormField(
                                            controller: _StatusController,
                                            decoration: const InputDecoration(
                                                labelText: 'Status',
                                                labelStyle: TextStyle(
                                                    color: Colors.grey)),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter Customer Status';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          InkWell(
                                            onTap: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                // If the form is valid, add the car
                                                await firebaseController
                                                    .updateCustomer(
                                                        _customerIdController
                                                            .text,
                                                        _NameController.text,
                                                        _NIKController.text,
                                                        _PhoneNumberController
                                                            .text,
                                                        _BirthDateController
                                                            .text,
                                                        _EmailController.text,
                                                        _StatusController.text);
                                                setState(() {});
                                                // ignore: use_build_context_synchronously
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              decoration:
                                                  boxDecorationWithRoundedCorners(
                                                      borderRadius: radius(30),
                                                      backgroundColor:
                                                          Colors.blue),
                                              child: Center(
                                                child: Text(
                                                  'Update Customer',
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
                            size: 25,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          visualDensity: VisualDensity.compact,
                          onPressed: () async {
                            _customerIdController.text = customer.id;
                            // Show confirmation dialog
                            final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text(
                                        'Are you sure you want to delete this customer?'),
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

                            // If confirmed, delete the customer
                            if (confirm) {
                              if (_customerIdController.text.isNotEmpty) {
                                await firebaseController
                                    .deleteCustomer(_customerIdController.text);
                              } else {
                                Get.snackbar('Error', 'Customer ID is Empty',
                                    snackPosition: SnackPosition.BOTTOM);
                              }
                            }
                          },
                        ),
                        10.width,
                        Text(
                          customer.customerName,
                          style: primaryTextStyle(
                              weight: FontWeight.bold, size: 18),
                        ),
                      ],
                    ),
                    12.height,
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(bottom: 5),
                      childAspectRatio: 3,
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 30,
                      children: [
                        SpecCard(title: 'NIK', text: customer.nik),
                        SpecCard(
                            title: 'Phone Number', text: customer.phoneNum),
                        SpecCard(title: 'Birth Date', text: customer.birthDate),
                        SpecCard(title: 'Email', text: customer.emailAddress),
                        SpecCard(title: 'Status', text: customer.status),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        });
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
      width: Get.width * .2,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
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
          Expanded(
            child: Text(
              text,
              maxLines: null,
              overflow: TextOverflow.clip,
              style: primaryTextStyle(size: 13),
            ),
          ),
        ],
      ),
    );
  }
}
