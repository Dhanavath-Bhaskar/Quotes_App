import 'package:flutter/material.dart';

const kQuoteTextStyle = TextStyle(
  fontSize: 28,
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'Roboto',
  shadows: [
    Shadow(blurRadius: 3, color: Colors.black, offset: Offset(2, 2)),
  ],
);

const kAuthorTextStyle = TextStyle(
  color: Colors.white, // <-- Now white
  fontSize: 20,
  fontStyle: FontStyle.italic,
  fontFamily: 'Roboto',
);
