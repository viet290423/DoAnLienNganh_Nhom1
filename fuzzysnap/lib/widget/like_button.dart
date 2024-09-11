import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final ValueNotifier<bool> isFavoriteNotifier;
  final void Function(bool) onFavoriteChanged;

  const LikeButton({
    Key? key,
    required this.isFavoriteNotifier,
    required this.onFavoriteChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isFavoriteNotifier,
      builder: (context, isFavorite, child) {
        return IconButton(
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black, size: 30),
          onPressed: () {
            bool newValue = !isFavorite;
            isFavoriteNotifier.value = newValue;
            onFavoriteChanged(newValue);
          },
        );
      },
    );
  }
}
