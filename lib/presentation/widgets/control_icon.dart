import 'package:flutter/material.dart';

class ControlIcon extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final double height;
  final double width;
  final double iconSize;
  final IconData? icon;
  final Color? color;

  const ControlIcon({
    Key? key,
    required this.onTap,
    this.isPlaying = false,
    this.height = 56,
    this.width = 56,
    this.iconSize = 36,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color widgetColor = color ?? Theme.of(context).primaryColor;

    BorderSide borderSide = BorderSide(
      color: widgetColor.withOpacity(.7),
      width: 1,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border(
            top: borderSide,
            bottom: borderSide,
            left: borderSide,
            right: borderSide,
          ),
        ),
        child: Icon(
          icon ?? (isPlaying ? Icons.pause : Icons.play_arrow),
          color: widgetColor.withOpacity(.9),
          size: iconSize,
        ),
      ),
    );
  }
}
