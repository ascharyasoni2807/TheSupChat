

import 'package:flutter/material.dart';
import 'package:thegorgeousotp/theme.dart';






class CustomprogressIndicator  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(strokeWidth: 2, backgroundColor: MyColors.maincolor, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),);
  }
}
