import 'package:flutter/material.dart';
import 'skeleton_box.dart';

class SkeletonPill extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonPill({super.key, required this.width, this.height = 24});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: height / 2,
      hasBorder: false,
    );
  }
}
