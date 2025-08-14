import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class PopularCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic>) onTap;

  const PopularCarousel({
    required this.items,
    required this.onTap,
  });

  @override
  State<PopularCarousel> createState() => PopularCarouselState();
}

class PopularCarouselState extends State<PopularCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return CarouselSlider.builder(
      options: CarouselOptions(
        height: 150,
        autoPlay: true,
        viewportFraction: 1, // ✅ Only one item at a time
        autoPlayInterval: const Duration(seconds: 4),
        aspectRatio: 2.0,
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index, realIdx) {
        final t = widget.items[index];
        return Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: GestureDetector(
            onTap: () => widget.onTap(t),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: (t['logo'] ?? '').toString().isNotEmpty
                              ? NetworkImage(t['logo'])
                              : null,
                          child: (t['logo'] ?? '').toString().isEmpty
                              ? const Icon(Icons.extension)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['name'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t['description'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Badge in top-right
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: t['isFree'] ? Colors.green : Colors.red,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      t['isFree'] ? 'Free' : 'Paid',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
        );
      },
    );
  }
}

