import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/review_card.dart';
import '../../widgets/common/loading_indicator.dart';

class ReviewsListScreen extends StatefulWidget {
  const ReviewsListScreen({super.key});
  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  bool _initDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initDone) {
      _initDone = true;
      final id = ModalRoute.of(context)!.settings.arguments as String;
      context.read<ReviewProvider>().loadReviews(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = context.watch<ReviewProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('All Reviews')),
      body: reviewState.isLoading
          ? const LoadingIndicator()
          : reviewState.reviews.isEmpty
              ? const Center(child: Text('No reviews yet. Be the first!'))
              : ListView.builder(
                  itemCount: reviewState.reviews.length,
                  itemBuilder: (_, i) => ReviewCard(review: reviewState.reviews[i]),
                ),
    );
  }
}
