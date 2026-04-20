import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../core/app_theme.dart';

class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // 1. KHI ĐANG TẢI: Hiện hiệu ứng nhấp nháy Shimmer
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppTheme.shimmerBase,
        highlightColor: AppTheme.shimmerHighlight,
        child: Container(
          width: width,
          height: height,
          color: Colors.white, // Cần có màu nền để Shimmer có thể nhấp nháy lên
        ),
      ),
      // 2. KHI LỖI MẠNG / LINK CHẾT: Hiện icon cảnh báo
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: AppTheme.shimmerBase,
        child: const Icon(Icons.broken_image, color: Colors.grey, size: 30),
      ),
    );
  }
}