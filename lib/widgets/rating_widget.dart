import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int rating; // 0-5
  final ValueChanged<int> onChanged;

  const RatingWidget({super.key, required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = rating >= starIndex;
        return IconButton(
          iconSize: 32,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          onPressed: () => onChanged(starIndex),
          icon: Icon(
            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
            color: isFilled ? Colors.amber : Colors.grey[400],
          ),
        );
      }),
    );
  }
}

