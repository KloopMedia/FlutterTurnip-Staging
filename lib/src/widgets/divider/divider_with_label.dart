import 'package:flutter/material.dart';


class DividerWithLabel extends StatelessWidget {
  final String label;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final double thickness;

  const DividerWithLabel({
    Key? key,
    required this.label,
    this.padding,
    this.thickness = 1.5,
    this.color = const Color(0x0A0E222F),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color.withOpacity(0.6),
    );

    final divider = Expanded(
      child: Divider(thickness: thickness, color: color),
    );

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          divider,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: Text(label, style: style),
          ),
          divider,
        ],
      ),
    );
  }
}
