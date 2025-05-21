import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradientOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final List<Color> gradientColors;
  final Color fillColor; 

  const GradientOutlinedButton({super.key, 
    required this.onPressed,
    required this.text,
    required this.gradientColors,
    this.fillColor = Colors.black, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.sp,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(1), 
      child: Container(
        decoration: BoxDecoration(
          color: fillColor, 
          borderRadius: BorderRadius.circular(8), 
        ),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.transparent), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.transparent, 
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
