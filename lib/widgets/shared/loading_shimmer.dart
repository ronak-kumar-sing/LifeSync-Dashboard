import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class LoadingShimmer extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;
  final int count;
  final Axis direction;
  final EdgeInsets padding;

  const LoadingShimmer({
    super.key,
    this.height = 100,
    this.width,
    this.borderRadius = 12,
    this.count = 3,
    this.direction = Axis.vertical,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.elevatedSurface,
      child: direction == Axis.vertical
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: count,
              itemBuilder: (_, __) => _buildItem(),
            )
          : Row(
              children: List.generate(
                count,
                (_) => Expanded(child: _buildItem()),
              ),
            ),
    );
  }

  Widget _buildItem() {
    return Container(
      height: height,
      width: width,
      margin: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
