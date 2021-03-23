

import 'package:flutter/material.dart';
import 'package:thegorgeousotp/theme.dart';

class CircularIndi {

   final Widget progressIndicator = Container(
    width: 200,
    height: 100,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      color: MyColors.maincolor.withOpacity(0.7),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );
}