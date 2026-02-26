import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/product/presentation/view_model/product_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductCommentSection extends ConsumerStatefulWidget {
  final String productId;

  const ProductCommentSection({super.key, required this.productId});

  @override
  ConsumerState<ProductCommentSection> createState() =>
      _ProductCommentSectionState();
}

class _ProductCommentSectionState extends ConsumerState<ProductCommentSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(productViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= ADD COMMENT =================
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Write a comment...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: state.isProductActionLoading
                    ? null
                    : () async {
                        final text = _controller.text.trim();
                        if (text.isEmpty) {
                          SnackbarUtils.showError(
                            context,
                            "Comment cannot be empty",
                          );
                          return;
                        }

                        await ref
                            .read(productViewModelProvider.notifier)
                            .addComment(
                              productId: widget.productId,
                              comment: text,
                            );

                        _controller.clear();
                        SnackbarUtils.showSuccess(context, "Comment added");
                      },
                child: state.isProductActionLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ================= COMMENTS LIST =================
        if (state.isCommentsLoading)
          const Center(child: CircularProgressIndicator())
        else if (state.comments.isEmpty)
          Text(
            "No comments yet.",
            style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
          )
        else
          Column(
            children: state.comments.map((c) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.username.isEmpty ? "User" : c.username,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.comment,
                      style: TextStyle(color: cs.onSurface.withOpacity(0.8)),
                    ),
                    if (c.createdAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        "${c.createdAt!.year}-${c.createdAt!.month.toString().padLeft(2, '0')}-${c.createdAt!.day.toString().padLeft(2, '0')}",
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
