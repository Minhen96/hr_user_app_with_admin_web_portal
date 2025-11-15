import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantityField extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;

  const QuantityField({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _QuantityFieldState createState() => _QuantityFieldState();
}

class _QuantityFieldState extends State<QuantityField> {
  late TextEditingController _controller;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialValue;
    _controller = TextEditingController(text: _quantity.toString());
  }

  void _updateQuantity(int value) {
    if (value >= 1) {
      setState(() {
        _quantity = value;
        _controller.text = _quantity.toString();
        widget.onChanged(_quantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
              color: Colors.black.withOpacity(0.7),
            ),
            onPressed: () => _updateQuantity(_quantity - 1),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: '1',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
              ),
              onChanged: (value) {
                final newValue = int.tryParse(value);
                if (newValue != null && newValue >= 1) {
                  _updateQuantity(newValue);
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.black.withOpacity(0.7),
            ),
            onPressed: () => _updateQuantity(_quantity + 1),
          ),
        ],
      ),
    );
  }
}
