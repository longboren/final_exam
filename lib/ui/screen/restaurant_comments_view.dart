import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../models/restaurant_comment.dart';
import 'restaurant_comments_forms.dart';
import '../widgets/chip/stars_chip.dart';
import '../theme.dart';

class RestaurantCommentsView extends StatefulWidget {
  const RestaurantCommentsView({
    Key? key,
    required this.restaurant,
    this.initialComments = const [],
    this.averageRatingOverride,
    this.onAddComment,
  }) : super(key: key);

  final Restaurant restaurant;
  final List<RestaurantComment> initialComments;
  final double? averageRatingOverride;
  final ValueChanged<RestaurantComment>? onAddComment;

  @override
  State<RestaurantCommentsView> createState() => _RestaurantCommentsViewState();
}

class _RestaurantCommentsViewState extends State<RestaurantCommentsView> {
  late List<RestaurantComment> _comments;
  double? _averageOverride;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
    _averageOverride = widget.averageRatingOverride;
  }

  double get averageRating {
    if (_averageOverride != null) return _averageOverride!;
    if (_comments.isEmpty) return widget.restaurant.rating;
    final avg =
        _comments.map((c) => c.stars).fold<int>(0, (a, b) => a + b) /
        _comments.length;
    return avg.toDouble();
  }

  Future<void> _addComment() async {
    final comment = await showRestaurantCommentForm(context);
    if (comment == null) return;
    setState(() {
      _comments.add(comment);
      _averageOverride =
          _comments.map((c) => c.stars).fold<int>(0, (a, b) => a + b) /
          _comments.length;
    });
    widget.onAddComment?.call(comment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        backgroundColor: AppColor.main,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addComment,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColor.main,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              children: [
                Text(
                  widget.restaurant.name,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StarsChip(rating: averageRating),
                    const SizedBox(width: 12),
                    Chip(
                      label: Text(widget.restaurant.cuisine.toUpperCase()),
                      backgroundColor: _cuisineColor(widget.restaurant.cuisine),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _comments.isEmpty
                ? const Center(child: Text('No comments yet'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final c = _comments[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StarsChip(rating: c.stars.toDouble()),
                            const SizedBox(width: 10),
                            Expanded(child: Text(c.feedback)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _cuisineColor(String cuisine) {
    final c = cuisine.toLowerCase();
    if (c.contains('khmer')) return Colors.teal;
    if (c.contains('ital')) return Colors.green;
    if (c.contains('mex')) return Colors.deepOrange;
    if (c.contains('fren')) return Colors.blue;
    return Colors.grey;
  }
}
