<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

a simple package to create a directionaly accurate text field in the web, as a fix for [this issue](https://github.com/flutter/flutter/issues/78550).

## Features

this package implements `DirectionalTextField` and `DirectionalTextFormField` which behav simmilarly to the flutter ones.
it uses `<input>` tag behind the scenes to give a real web experience. 

## Getting started

before using any of the widgets, be sure to put the line
```dart
DirectionalTextField.initialize();
```
in the main function!

## Usage

a simple example:

```dart
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
          children: const [
            DirectionalTextField(
              decoration: InputDecoration(label: Text("hey")),
            ),
            TextField(
              decoration: InputDecoration(label: Text("hey")),
            ),
          ],
        ),
      ),
    );
  }
}
```
