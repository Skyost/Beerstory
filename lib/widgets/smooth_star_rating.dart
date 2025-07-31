import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Thanks [`smooth_star_rating`](https://raw.githubusercontent.com/thangmam/smoothratingbar/master/lib/smooth_star_rating.dart) !
class SmoothStarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final Function(double)? onRatingChanged;
  final Color? color;
  final Color? borderColor;
  final double size;
  final bool allowHalfRating;
  final IconData filledIconData;
  final IconData halfFilledIconData;
  final IconData defaultIconData; //this is needed only when having fullRatedIconData && halfRatedIconData
  final double spacing;

  const SmoothStarRating({
    super.key,
    this.starCount = 5,
    this.spacing = 0.0,
    this.rating = 0.0,
    this.defaultIconData = Icons.star_border,
    this.onRatingChanged,
    this.color,
    this.borderColor,
    this.size = 25,
    this.filledIconData = Icons.star,
    this.halfFilledIconData = Icons.star_half,
    this.allowHalfRating = true,
  });

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = Icon(
        defaultIconData,
        color: borderColor ?? context.theme.colors.primary,
        size: size,
      );
    } else if (index > rating - (allowHalfRating ? 0.5 : 1.0) && index < rating) {
      icon = Icon(
        halfFilledIconData,
        color: color ?? context.theme.colors.primary,
        size: size,
      );
    } else {
      icon = Icon(
        filledIconData,
        color: color ?? context.theme.colors.primary,
        size: size,
      );
    }

    return GestureDetector(
      onTap: () {
        onRatingChanged?.call(index + 1.0);
      },
      onHorizontalDragUpdate: (dragDetails) {
        RenderBox box = context.findRenderObject() as RenderBox;
        var pos = box.globalToLocal(dragDetails.globalPosition);
        var i = pos.dx / size;
        var newRating = allowHalfRating ? i : i.round().toDouble();
        if (newRating > starCount) {
          newRating = starCount.toDouble();
        }
        if (newRating < 0) {
          newRating = 0.0;
        }
        onRatingChanged?.call(newRating);
      },
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.start,
    spacing: spacing,
    children: [
      for (int i = 0; i < starCount; i++) buildStar(context, i),
    ],
  );
}
