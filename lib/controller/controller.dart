import 'package:get/get.dart';

class Controller extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        // Navigate to Home Page
        Get.offAllNamed('/'); // Assuming Home page is defined as '/'
        break;
      case 1:
        // Navigate to Profile Page
        Get.offAllNamed('/profile'); // Assuming Profile page is defined as '/profile'
        break;
      // Add cases for other tabs if needed
    }
  }
}
