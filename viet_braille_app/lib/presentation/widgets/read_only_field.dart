import 'package:flutter/material.dart';

/// Trường text chỉ đọc, hiển thị kết quả với label.
class ReadOnlyField extends StatefulWidget {
  const ReadOnlyField({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  State<ReadOnlyField> createState() => _ReadOnlyFieldState();
}

class _ReadOnlyFieldState extends State<ReadOnlyField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant ReadOnlyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: widget.label,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
