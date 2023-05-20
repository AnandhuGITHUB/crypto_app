import 'package:crypto_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileScreen extends StatelessWidget {
  UpdateProfileScreen({super.key});
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  Future<void> saveData(String key, String value) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    await _pref.setString(key, value);
  }

  void saveUserDetails() async {
    await saveData("name", nameController.text);
    await saveData("email", emailController.text);
    await saveData("mobile", mobileNumberController.text);
    print("Data Saved");
  }

  bool isDarkModeEnabled = AppTheme.isDarkModeEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkModeEnabled ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Profile Update"),
      ),
      body: Column(
        children: [
          customTextFiled("Name", nameController, false),
          customTextFiled("Email", emailController, false),
          customTextFiled("Mobile", mobileNumberController, true),
          ElevatedButton(
            onPressed: () {
              saveUserDetails();
            },
            child: const Text("Save Details"),
          )
        ],
      ),
    );
  }

  Widget customTextFiled(
      String hintText, TextEditingController controller, bool keyboardType) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        keyboardType: keyboardType == true ? TextInputType.number : null,
        controller: controller,
        decoration: InputDecoration(
          hintStyle: TextStyle(color: isDarkModeEnabled ? Colors.white : null),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: isDarkModeEnabled ? Colors.white : Colors.grey),
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
