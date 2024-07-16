import 'package:flutter/material.dart';

class Requests extends StatefulWidget {
  const Requests({super.key});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(   title: Text("Requests"),actions: [],),

      body: Column(
        children: [
          Row(
            children: [
              
            ],
          )

        ],
      ),
    );
  }
}