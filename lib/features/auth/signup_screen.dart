import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.shopping_cart),
          //   tooltip: 'Open shopping cart',
          //   onPressed: () {

          //   },
          // ),
        ],
      ),
      body: SafeArea(child: Center(child: Text("Signup"))),
    );
  }
}
