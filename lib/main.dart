import 'package:flutter/material.dart';

import 'HomePage.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.red),
        home: HomePage(),
      ),
    );
