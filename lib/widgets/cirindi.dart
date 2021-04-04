

import 'package:flutter/material.dart';
import 'package:theproject/theme.dart';






class CustomprogressIndicator  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: CircularProgressIndicator(strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),),
    );
  }
}
