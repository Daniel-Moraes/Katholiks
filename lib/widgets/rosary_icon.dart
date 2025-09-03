import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RosaryIcon extends StatelessWidget {
  final double? size;
  final Color? color;

  const RosaryIcon({
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/rosary_icon.svg',
      width: size ?? 24,
      height: size ?? 24,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
