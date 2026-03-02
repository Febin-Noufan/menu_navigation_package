import 'package:flutter/material.dart';

extension OverflowTooltipTextExtension on Text {
  Widget withOverflowTooltip({
    String? tooltipText,
    Decoration? decoration,
    TextStyle? tooltipTextStyle,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Duration? waitDuration,
    Duration? showDuration,
  }) {
    return _OverflowTooltipText(
      text: this,
      tooltipText: tooltipText,
      decoration: decoration,
      tooltipTextStyle: tooltipTextStyle,
      padding: padding,
      margin: margin,
      waitDuration: waitDuration,
      showDuration: showDuration,
    );
  }
}

class _OverflowTooltipText extends StatefulWidget {
  final Text text;
  final String? tooltipText;
  final Decoration? decoration;
  final TextStyle? tooltipTextStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Duration? waitDuration;
  final Duration? showDuration;

  const _OverflowTooltipText({
    required this.text,
    this.tooltipText,
    this.decoration,
    this.tooltipTextStyle,
    this.padding,
    this.margin,
    this.waitDuration,
    this.showDuration,
  });

  @override
  State<_OverflowTooltipText> createState() => _OverflowTooltipTextState();
}

class _OverflowTooltipTextState extends State<_OverflowTooltipText> {
  bool _isOverflowing = false;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  @override
  void didUpdateWidget(covariant _OverflowTooltipText oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  void _checkOverflow() {
    final textRenderBox = _textKey.currentContext?.findRenderObject();
    if (textRenderBox is RenderBox) {
      final availableWidth = textRenderBox.size.width;

      final textPainter = TextPainter(
        text: TextSpan(
          text: widget.text.data ?? '',
          style: widget.text.style,
        ),
        textDirection: widget.text.textDirection ?? TextDirection.ltr,
        maxLines: widget.text.maxLines,
      )..layout();

      final textWidth = textPainter.size.width;

      final overflowing = textWidth > availableWidth;

      if (_isOverflowing != overflowing) {
        setState(() {
          _isOverflowing = overflowing;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text.data ?? '',
      key: _textKey,
      style: widget.text.style,
      maxLines: widget.text.maxLines,
      overflow: widget.text.overflow,
      textAlign: widget.text.textAlign,
      textDirection: widget.text.textDirection,
      softWrap: widget.text.softWrap,
    );

    return _isOverflowing
        ? Tooltip(
            message: widget.tooltipText ?? widget.text.data ?? '',
            decoration: widget.decoration,
            textStyle: widget.tooltipTextStyle,
            padding: widget.padding,
            margin: widget.margin,
            waitDuration: widget.waitDuration,
            showDuration: widget.showDuration,
            child: textWidget,
          )
        : textWidget;
  }
}
