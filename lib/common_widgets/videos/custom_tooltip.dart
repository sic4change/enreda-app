import 'package:flutter/material.dart';

class CustomTooltip extends StatefulWidget {
  final Widget child;
  final Widget tooltip;

  const CustomTooltip({Key? key, required this.child, required this.tooltip})
      : super(key: key);

  @override
  _CustomTooltipState createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip> {
  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        // Position the tooltip relative to the widget
        top: MediaQuery.of(context).size.height * 0.4,
        right: MediaQuery.of(context).size.width * 0.25,
        child: widget.tooltip,
      );
    });
  }

  @override
  void dispose() {
    _overlayEntry.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_overlayEntry.mounted) {
          _overlayEntry.remove();
        } else {
          Overlay.of(context).insert(_overlayEntry);
        }
      },
      child: widget.child,
    );
  }

}


