import 'package:flutter/material.dart';
import 'package:hero_container/flutter_hero_container.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Example(),
      ),
    );
  }
}

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HeroContainer(
        // Shape for the closed state with rounded corners
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        // Builder for the expanded/opened state - shows a full screen scaffold.
        openedBuilder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(title: Text("Expanded View")),
            body: Center(
              child: Text("Hello, World!", style: TextStyle(fontSize: 32)),
            ),
          );
        },

        // Builder for the collapsed/closed state -
        // shows a button that triggers the transition.
        closedBuilder: (BuildContext context, VoidCallback action) {
          return TextButton(
            // Call this to trigger the hero container transition.
            onPressed: action,
            child: Text("Tap to expand", style: TextStyle(fontSize: 50)),
          );
        },
      ),
    );
  }
}
