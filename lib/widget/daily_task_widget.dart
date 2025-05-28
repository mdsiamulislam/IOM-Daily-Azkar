import 'package:flutter/material.dart';
import '../const/constants.dart';

class DailyTaskWidget extends StatelessWidget {
  const DailyTaskWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Daily Azkar Tasks",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        Icon(
          Icons.arrow_forward,
          color: AppColors.white,
        ),
      ],
    );
  }
}