import 'package:flutter/material.dart';

class GalleryButton extends StatelessWidget {
  final VoidCallback onTap;

  const GalleryButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate sizes based on available space
          final availableWidth = constraints.maxWidth;
          final availableHeight = constraints.maxHeight;

          // Make icon container size responsive but not too large
          final iconContainerSize = availableWidth * 0.6;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: iconContainerSize,
                height: iconContainerSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFD5EE),
                        borderRadius: BorderRadius.circular(iconContainerSize / 2),
                      ),
                      child: Stack(
                        children: [
                          // Image icon
                          Center(
                            child: Icon(
                              Icons.image,
                              size: iconContainerSize * 0.65,
                              color: Color(0xFFE861CD),
                            ),
                          ),

                          // Info badge - made smaller and proportional
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.all(iconContainerSize * 0.05),
                              decoration: BoxDecoration(
                                color: Color(0xFFE861CD),
                                borderRadius: BorderRadius.circular(iconContainerSize * 0.15),
                              ),
                              child: Icon(
                                Icons.people,
                                size: iconContainerSize * 0.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4), // Reduced spacing

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  'Moments',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: availableWidth * 0.145, // Responsive font size
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
