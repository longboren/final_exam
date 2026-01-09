import 'package:flutter/material.dart';
import '../../models/restaurant_comment.dart';

/// Shows the comment form as a bottom modal and returns a RestaurantComment
Future<RestaurantComment?> showRestaurantCommentForm(BuildContext context) {
  return showModalBottomSheet<RestaurantComment?>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: const _RestaurantCommentForm(),
    ),
  );
}

class _RestaurantCommentForm extends StatefulWidget {
  const _RestaurantCommentForm({Key? key}) : super(key: key);

  @override
  State<_RestaurantCommentForm> createState() => _RestaurantCommentFormState();
}

class _RestaurantCommentFormState extends State<_RestaurantCommentForm> {
  final _formKey = GlobalKey<FormState>();
  int _stars = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final feedback = _feedbackController.text.trim();
    Navigator.of(
      context,
    ).pop(RestaurantComment(stars: _stars, feedback: feedback));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'How was your dinner?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<int?>(
                    value: _stars,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric( 
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: const UnderlineInputBorder(),
                    ),
                    items: List.generate(
                      6,
                      (i) => DropdownMenuItem<int>(
                        value: i == 0 ? null : i, // Make 0 null to allow initial empty state
                        child: Text(i.toString()),
                      ),
                    ),
                    onChanged: (v) => setState(() => _stars = v ?? 0),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _feedbackController,
                    maxLength: 50,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Any feedback?',
                      hintText: 'Enter your feedback',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter your feedback';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Comment'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
