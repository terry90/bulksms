import 'package:flutter/material.dart';

Padding padY(Widget w) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: w,
    );

Padding pad(Widget w) => Padding(
      padding: const EdgeInsets.all(16),
      child: w,
    );

Padding padX(Widget w) => Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: w,
    );

Padding padRight(Widget w) => Padding(
      padding: const EdgeInsets.only(right: 16),
      child: w,
    );
