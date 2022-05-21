import 'package:flutter/material.dart';
import 'package:web_directional_text_field/web_directional_text_field.dart';

void main() {
  DirectionalTextField.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? currentValue;
  TextEditingController controller = TextEditingController(text: "hello");
  String? textError;
  GlobalKey<FormState> key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Column(
          children: [
            const DirectionalTextField(
              decoration: InputDecoration(label: const Text("hey")),
              initialValue: "initial value even for DirectionalTextField",
            ),
            DirectionalTextFormField(
              decoration: const InputDecoration(label: Text("hey")),
              initialValue: "initial value",
            ),
            const TextField(
              decoration: InputDecoration(label: Text("hey")),
            ),
          ],
        ),
      ),
    );
  }
}
