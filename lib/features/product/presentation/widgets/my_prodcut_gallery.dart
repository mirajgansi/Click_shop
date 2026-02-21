import 'package:click_shop/core/config/api_endpoints.dart';
import 'package:flutter/material.dart';

class ProductGallery extends StatefulWidget {
  const ProductGallery({
    required this.image,
    required this.images,
    required this.height,
    required this.onIndexChanged,
  });

  final String image;
  final List<String> images;
  final double height;
  final ValueChanged<int> onIndexChanged;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _buildUrls() {
    // combine main image + images list, remove empties & duplicates
    final all = <String>[
      if (widget.image.trim().isNotEmpty) widget.image.trim(),
      ...widget.images.map((e) => e.trim()),
    ].where((e) => e.isNotEmpty).toList();

    final seen = <String>{};
    return all.where((e) => seen.add(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final raw = _buildUrls();

    // Map to full URLs
    final urls = raw.map((p) => ApiEndpoints.buildFileUrl(p)).toList();

    // fallback if no images at all
    if (urls.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cs.surfaceContainerHighest,
        ),
        child: Center(
          child: Image.asset("assets/images/happy.png", fit: BoxFit.contain),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            height: widget.height,
            color: cs.surfaceContainerHighest,
            child: PageView.builder(
              controller: _controller,
              itemCount: urls.length,
              onPageChanged: (i) {
                setState(() => _index = i);
                widget.onIndexChanged(i);
              },
              itemBuilder: (_, i) {
                final url = urls[i];
                return GestureDetector(
                  onTap: () => _openFullScreen(context, urls, i),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Image.asset(
                        "assets/images/happy.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                );
              },
            ),
          ),

          // Dots indicator (only if multiple)
          if (urls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 7,
                    width: active ? 18 : 7,
                    decoration: BoxDecoration(
                      color: active
                          ? cs.primary
                          : cs.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  );
                }),
              ),
            ),

          // Small counter (top-right)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                "${_index + 1}/${urls.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(BuildContext context, List<String> urls, int initial) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenGallery(urls: urls, initialIndex: initial),
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  const _FullScreenGallery({required this.urls, required this.initialIndex});

  final List<String> urls;
  final int initialIndex;

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text("${_index + 1}/${widget.urls.length}"),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Image.network(widget.urls[i], fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
