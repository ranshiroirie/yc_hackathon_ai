import 'package:flutter/material.dart';

class ModalCloseButton extends StatelessWidget {
  final VoidCallback onClose;

  const ModalCloseButton({required this.onClose, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: onClose,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.close,
            size: 24,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
