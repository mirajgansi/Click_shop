// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_test/flutter_test.dart';

// import 'package:click_shop/core/widgets/my_card_widgets.dart';
// import 'package:click_shop/features/item/presentation/pages/product_screen.dart';

// class IgnoreAssetsBundle extends CachingAssetBundle {
//   static const String _validSvg = '''
// <svg xmlns="http://www.w3.org/2000/svg" width="10" height="10" viewBox="0 0 10 10">
//   <rect width="10" height="10" fill="#000000"/>
// </svg>
// ''';

//   // tiny valid PNG (1x1)
//   static final Uint8List _png = Uint8List.fromList(<int>[
//     0x89,
//     0x50,
//     0x4E,
//     0x47,
//     0x0D,
//     0x0A,
//     0x1A,
//     0x0A,
//     0x00,
//     0x00,
//     0x00,
//     0x0D,
//     0x49,
//     0x48,
//     0x44,
//     0x52,
//     0x00,
//     0x00,
//     0x00,
//     0x01,
//     0x00,
//     0x00,
//     0x00,
//     0x01,
//     0x08,
//     0x06,
//     0x00,
//     0x00,
//     0x00,
//     0x1F,
//     0x15,
//     0xC4,
//     0x89,
//     0x00,
//     0x00,
//     0x00,
//     0x0A,
//     0x49,
//     0x44,
//     0x41,
//     0x54,
//     0x78,
//     0x9C,
//     0x63,
//     0x00,
//     0x01,
//     0x00,
//     0x00,
//     0x05,
//     0x00,
//     0x01,
//     0x0D,
//     0x0A,
//     0x2D,
//     0xB4,
//     0x00,
//     0x00,
//     0x00,
//     0x00,
//     0x49,
//     0x45,
//     0x4E,
//     0x44,
//     0xAE,
//     0x42,
//     0x60,
//     0x82,
//   ]);

//   @override
//   Future<ByteData> load(String key) async {
//     // ✅ JSON manifest (fine)
//     if (key == 'AssetManifest.json') {
//       final bytes = utf8.encode(jsonEncode(<String, dynamic>{}));
//       return ByteData.view(Uint8List.fromList(bytes).buffer);
//     }

//     // ✅ BIN manifest (MUST be encoded with StandardMessageCodec)
//     if (key == 'AssetManifest.bin') {
//       final encoded = const StandardMessageCodec().encodeMessage(
//         <String, Object?>{},
//       )!;
//       return encoded;
//     }

//     // ✅ SVG icons
//     if (key.endsWith('.svg')) {
//       final bytes = Uint8List.fromList(utf8.encode(_validSvg));
//       return ByteData.view(bytes.buffer);
//     }

//     // ✅ Images
//     if (key.endsWith('.png') || key.endsWith('.jpg') || key.endsWith('.jpeg')) {
//       return ByteData.view(_png.buffer);
//     }

//     // fallback
//     return ByteData.view(Uint8List.fromList([0]).buffer);
//   }

//   @override
//   Future<String> loadString(String key, {bool cache = true}) async {
//     if (key.endsWith('.svg')) return _validSvg;
//     if (key == 'AssetManifest.json') return jsonEncode(<String, dynamic>{});
//     return '';
//   }
// }

// @override
// Future<String> loadString(
//   String key,
//   Future<String> _validSvg, {
//   bool cache = true,
// }) async {
//   if (key.endsWith('.svg')) return _validSvg;
//   if (key == 'AssetManifest.json') return jsonEncode(<String, dynamic>{});
//   return '';
// }

// void main() {
//   Future<void> pumpCard(WidgetTester tester) async {
//     await tester.pumpWidget(
//       DefaultAssetBundle(
//         bundle: IgnoreAssetsBundle(),
//         child: const MaterialApp(
//           home: Scaffold(
//             body: Center(child: SizedBox(width: 260, child: CardWidget())),
//           ),
//         ),
//       ),
//     );
//     await tester.pumpAndSettle();
//   }

//   testWidgets('shows title and price text', (tester) async {
//     await tester.pumpWidget(
//       DefaultAssetBundle(
//         bundle: IgnoreAssetsBundle(),
//         child: const MaterialApp(
//           home: Scaffold(
//             body: Center(child: SizedBox(width: 320, child: CardWidget())),
//           ),
//         ),
//       ),
//     );

//     await tester.pumpAndSettle();

//     expect(find.text('Happy Cookie'), findsOneWidget);
//     expect(find.text('Rs 299 / kg'), findsOneWidget);
//   });

//   testWidgets('tap title navigates to ProductDetailScreen', (tester) async {
//     await tester.pumpWidget(
//       DefaultAssetBundle(
//         bundle: IgnoreAssetsBundle(),
//         child: const MaterialApp(
//           home: Scaffold(
//             body: Center(child: SizedBox(width: 320, child: CardWidget())),
//           ),
//         ),
//       ),
//     );

//     await tester.pumpAndSettle();

//     await tester.tap(find.text('Happy Cookie'));
//     await tester.pumpAndSettle();

//     expect(find.byType(ProductDetailScreen), findsOneWidget);
//   });
// }
