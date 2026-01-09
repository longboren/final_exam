import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../models/restaurant_type.dart';
import '../../models/restaurant_comment.dart';
import 'restaurant_comments_forms.dart';
import 'restaurant_detail.dart';
import '../widgets/chip/stars_chip.dart';

class RestaurantsView extends StatefulWidget {
  const RestaurantsView({super.key, required this.restaurants});

  final List<Restaurant> restaurants;

  @override
  State<RestaurantsView> createState() => _RestaurantsViewState();
}

class _RestaurantsViewState extends State<RestaurantsView> {
  bool _onlyKhmer = false;

  // local comment storage keyed by restaurant index to avoid modifying model
  final Map<int, List<RestaurantComment>> _comments = {};
  final Map<int, double> _ratingOverrides = {};

  void _addCommentToRestaurant(int originalIndex, RestaurantComment comment) {
    final list = _comments.putIfAbsent(originalIndex, () => []);
    list.add(comment);
    final avg =
        list.map((c) => c.stars).fold<int>(0, (a, b) => a + b) / list.length;
    _ratingOverrides[originalIndex] = avg.toDouble();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.restaurants
        .where((r) => !_onlyKhmer || (r.type == RestaurantType.khmer))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Miam')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show only Khmer restaurants'),
              value: _onlyKhmer,
              onChanged: (v) => setState(() => _onlyKhmer = v ?? false),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = filtered[index];
                  // find original index in widget.restaurants to store comments reliably
                  final originalIndex = widget.restaurants.indexOf(r);
                  final displayRating = _ratingOverrides[originalIndex] ?? 0.0;
                  return InkWell(
                    onTap: () async {
                      // open detail view and pass callbacks so detail can add comments
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetail(
                            restaurant: r,
                            initialComments: List<RestaurantComment>.from(
                              _comments[originalIndex] ?? [],
                            ),
                            averageRatingOverride:
                                _ratingOverrides[originalIndex],
                            onAddComment: (comment) =>
                                _addCommentToRestaurant(originalIndex, comment),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.pink.shade100),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              StarsChip(rating: displayRating),
                              const SizedBox(width: 12),
                              Chip(
                                label: Text(r.type.name.toUpperCase()),
                                backgroundColor: _cuisineColor(r.cuisine),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _cuisineColor(RestaurantType type) {
    return type.color;
  }
}
