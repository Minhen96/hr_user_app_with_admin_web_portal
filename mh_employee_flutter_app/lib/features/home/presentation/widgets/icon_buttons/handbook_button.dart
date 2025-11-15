import 'package:flutter/material.dart';

class HandbookButton extends StatelessWidget {
  final VoidCallback onTap;
  final int unreadCount; // Total unread count from SOP and Policy

  const HandbookButton({
    Key? key,
    required this.onTap,
    required this.unreadCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
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
                        color: Color(0xFFD9FFD9),
                        borderRadius: BorderRadius.circular(iconContainerSize / 2),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.menu_book,
                              size: iconContainerSize * 0.7,
                              color: Color(0xFF50BF1D),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.all(iconContainerSize * 0.05),
                              decoration: BoxDecoration(
                                color: Color(0xFF50BF1D),
                                borderRadius: BorderRadius.circular(iconContainerSize * 0.15),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                size: iconContainerSize * 0.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  'Handbook',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: availableWidth * 0.145,
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
