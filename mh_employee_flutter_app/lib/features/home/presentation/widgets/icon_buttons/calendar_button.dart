import 'package:flutter/material.dart';

class CalenderButton extends StatelessWidget {
  final VoidCallback onTap;

  const CalenderButton({
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
                        color: Color(0xFFBECCFF),
                        borderRadius: BorderRadius.circular(iconContainerSize / 2),
                      ),
                      child: Stack(
                        children: [
                          // Book icon
                          Center(
                            child: Icon(
                              Icons.calendar_month_sharp,
                              size: iconContainerSize * 0.7,
                              color: Color(0xFF4C60AF),
                            ),
                          ),

                          // Info badge - made smaller and proportional
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.all(iconContainerSize * 0.05),
                              decoration: BoxDecoration(
                                color: Color(0xFF4C60AF),
                                borderRadius: BorderRadius.circular(iconContainerSize * 0.15),
                              ),
                              child: Icon(
                                Icons.access_time_filled,
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
                  'Calendar',
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
