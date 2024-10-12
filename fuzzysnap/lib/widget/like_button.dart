import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final ValueNotifier<bool> isFavoriteNotifier;
  final void Function(bool) onFavoriteChanged;

  const LikeButton({
    super.key,
    required this.isFavoriteNotifier,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isFavoriteNotifier,
      builder: (context, isFavorite, child) {
        return IconButton(
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSecondary,
              size: 30),
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
