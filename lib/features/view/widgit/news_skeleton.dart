import 'package:flutter/material.dart';

class NewsSkeleton extends StatefulWidget {
  const NewsSkeleton({super.key});

  @override
  State<NewsSkeleton> createState() => _NewsSkeletonState();
}

class _NewsSkeletonState extends State<NewsSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget skeletonBox({
    required double width,
    required double height,
    required Color baseColor,
    required Color highlightColor,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Color.lerp(
              baseColor,
              highlightColor,
              animationController.value,
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

  Widget buildSkeletonCard({
    required Color baseColor,
    required Color highlightColor,
    required Color cardColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          skeletonBox(
            width: double.infinity,
            height: 200,
            baseColor: baseColor,
            highlightColor: highlightColor,
            radius: 16,
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                skeletonBox(
                  width: 120,
                  height: 14,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),

                const SizedBox(height: 10),

                skeletonBox(
                  width: double.infinity,
                  height: 20,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),

                const SizedBox(height: 7),

                skeletonBox(
                  width: 250,
                  height: 20,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),

                const SizedBox(height: 10),

                skeletonBox(
                  width: double.infinity,
                  height: 13,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),

                const SizedBox(height: 7),

                skeletonBox(
                  width: 200,
                  height: 13,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    skeletonBox(
                      width: 100,
                      height: 12,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),

                    const Spacer(),

                    skeletonBox(
                      width: 110,
                      height: 12,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color cardColor = Theme.of(context).cardColor;

    final Color baseColor = isDark
        ? const Color(0xff303030)
        : const Color(0xffE1E5EC);

    final Color highlightColor = isDark
        ? const Color(0xff454545)
        : const Color(0xffF5F7FA);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return buildSkeletonCard(
          baseColor: baseColor,
          highlightColor: highlightColor,
          cardColor: cardColor,
        );
      },
    );
  }
}
