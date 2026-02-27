import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/auth/domain/usecases/get_currentuacase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:click_shop/features/order/presentation/view_model/order_view_model.dart';

Future<bool?> showCheckoutSheet({
  required BuildContext context,
  required WidgetRef ref,
  required num total,
  Map<String, dynamic>? initialShippingJson,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CheckoutBottomSheet(
      total: total,
      initialShippingJson: initialShippingJson,
    ),
  );
}

class _CheckoutBottomSheet extends ConsumerStatefulWidget {
  final num total;
  final Map<String, dynamic>? initialShippingJson;

  const _CheckoutBottomSheet({required this.total, this.initialShippingJson});

  @override
  ConsumerState<_CheckoutBottomSheet> createState() =>
      _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends ConsumerState<_CheckoutBottomSheet> {
  bool showShippingForm = false;

  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController address1Ctrl;
  late final TextEditingController address2Ctrl;
  late final TextEditingController cityCtrl;
  late final TextEditingController zipCtrl;
  String? nameError;
  String? phoneError;
  String? address1Error;
  @override
  void initState() {
    super.initState();

    final j = widget.initialShippingJson ?? {};
    nameCtrl = TextEditingController(text: (j["userName"] ?? "") as String);
    phoneCtrl = TextEditingController(text: (j["phone"] ?? "") as String);
    address1Ctrl = TextEditingController(text: (j["address1"] ?? "") as String);
    address2Ctrl = TextEditingController(text: (j["address2"] ?? "") as String);
    cityCtrl = TextEditingController(text: (j["city"] ?? "") as String);
    zipCtrl = TextEditingController(text: (j["zip"] ?? "") as String);
    Future.microtask(_loadCurrentUserAndPrefill);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    address1Ctrl.dispose();
    address2Ctrl.dispose();
    cityCtrl.dispose();
    zipCtrl.dispose();
    super.dispose();
  }

  bool _validShipping() {
    bool ok = true;

    setState(() {
      nameError = null;
      phoneError = null;
      address1Error = null;

      if (nameCtrl.text.trim().length < 2) {
        nameError = "Please enter your name";
        ok = false;
      }
      if (phoneCtrl.text.trim().length < 7) {
        phoneError = "Please enter a valid phone number";
        ok = false;
      }
      if (address1Ctrl.text.trim().length < 3) {
        address1Error = "Please enter delivery address";
        ok = false;
      }
    });

    return ok;
  }

  Map<String, dynamic> _shippingToJson() {
    final map = <String, dynamic>{
      "userName": nameCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
      "address1": address1Ctrl.text.trim(),
      "address2": address2Ctrl.text.trim(),
      "city": cityCtrl.text.trim(),
      "zip": zipCtrl.text.trim(),
    };

    map.removeWhere(
      (key, value) =>
          value == null || (value is String && value.trim().isEmpty),
    );

    return map;
  }

  Future<void> _loadCurrentUserAndPrefill() async {
    final result = await ref.read(getCurrentUserUsecaseProvider)();

    if (!mounted) return;

    result.fold((_) {}, (user) {
      if (!mounted) return;

      if (nameCtrl.text.trim().isEmpty) {
        nameCtrl.text = user.username ?? "";
      }
      if (phoneCtrl.text.trim().isEmpty) {
        phoneCtrl.text = user.phoneNumber ?? "";
      }
      if (address1Ctrl.text.trim().isEmpty) {
        address1Ctrl.text = user.location ?? "";
      }

      setState(() {
        showShippingForm = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderViewModelProvider);
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          initialChildSize: 0.58,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          builder: (context, scrollCtrl) {
            return Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Header
                    Row(
                      children: [
                        Text(
                          "Checkout",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => Navigator.pop(context, true),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: cs.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Delivery row (tap -> show form)
                    _RowItem(
                      title: "Delivery",
                      trailing: showShippingForm
                          ? "Edit Address"
                          : "Select Method",
                      onTap: () {
                        setState(() => showShippingForm = !showShippingForm);
                      },
                      leadingIcon: Icons.local_shipping_outlined,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: showShippingForm
                          ? Padding(
                              key: const ValueKey("shippingForm"),
                              padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 4,
                              ),
                              child: _ShippingForm(
                                nameCtrl: nameCtrl,
                                phoneCtrl: phoneCtrl,
                                address1Ctrl: address1Ctrl,
                                address2Ctrl: address2Ctrl,
                                cityCtrl: cityCtrl,
                                zipCtrl: zipCtrl,
                                nameError: nameError,
                                phoneError: phoneError,
                                address1Error: address1Error,
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey("noForm")),
                    ),

                    const SizedBox(height: 8),

                    _RowItem(
                      title: "Payment",
                      trailing: "Cash",
                      onTap: () {
                        // open payment picker later
                      },
                      leadingIcon: Icons.payments_outlined,
                      trailingWidget: Container(
                        width: 18,
                        height: 12,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Rs",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    _RowItem(
                      title: "Promo Code",
                      trailing: "Pick discount",
                      onTap: () {
                        // open promo page later
                      },
                      leadingIcon: Icons.local_offer_outlined,
                    ),

                    _RowItem(
                      title: "Total Cost",
                      trailing: "Rs.${widget.total}",
                      onTap: () {},
                      leadingIcon: Icons.receipt_long_outlined,
                      showChevron: false,
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    Text(
                      "By placing an order you agree to our Terms & Conditions.",
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withOpacity(0.6),
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: orderState.isLoading
                            ? null
                            : () async {
                                if (!_validShipping()) return;

                                // OPTIONAL: save address to user profile first
                                // await ref.read(authViewModelProvider.notifier).updateShippingAddress(_shippingToJson());

                                await ref
                                    .read(orderViewModelProvider.notifier)
                                    .createOrderFromCart(_shippingToJson());

                                final st = ref.read(orderViewModelProvider);
                                if (!mounted) return;

                                if (st.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(st.errorMessage!)),
                                  );
                                  return;
                                }

                                if (st.actionSuccess) {
                                  ref
                                      .read(orderViewModelProvider.notifier)
                                      .clearActionSuccess();
                                  Navigator.pop(context); // close sheet
                                  SnackbarUtils.showSuccess(
                                    context,
                                    'Order created successfully',
                                  );
                                }
                              },
                        child: orderState.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Place Order",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: cs.surface,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String title;
  final String trailing;
  final VoidCallback onTap;
  final IconData leadingIcon;
  final bool showChevron;
  final Widget? trailingWidget;

  const _RowItem({
    required this.title,
    required this.trailing,
    required this.onTap,
    required this.leadingIcon,
    this.showChevron = true,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(leadingIcon, size: 18, color: cs.onSurface.withOpacity(0.6)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              trailing,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 8),
            if (trailingWidget != null) trailingWidget!,
            if (showChevron) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.4)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShippingForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController address1Ctrl;
  final TextEditingController address2Ctrl;
  final TextEditingController cityCtrl;
  final TextEditingController zipCtrl;
  final String? nameError;
  final String? phoneError;
  final String? address1Error;
  const _ShippingForm({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.address1Ctrl,
    required this.address2Ctrl,
    required this.cityCtrl,
    required this.zipCtrl,
    this.nameError,
    this.phoneError,
    this.address1Error,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          _field(
            context,
            "Full Name",
            nameCtrl,
            TextInputType.name,
            errorText: nameError,
          ),
          const SizedBox(height: 10),

          _field(
            context,
            "Phone",
            phoneCtrl,
            TextInputType.phone,
            errorText: phoneError,
          ),
          const SizedBox(height: 10),

          _field(
            context,
            "Address Line 1",
            address1Ctrl,
            TextInputType.streetAddress,
            errorText: address1Error,
          ),
          const SizedBox(height: 10),

          const SizedBox(height: 10),
          _field(
            context,
            "Address Line 2 (optional)",
            address2Ctrl,
            TextInputType.streetAddress,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _field(
                  context,
                  "City (optional)",
                  cityCtrl,
                  TextInputType.text,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  context,
                  "ZIP (optional)",
                  zipCtrl,
                  TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(
    BuildContext context,
    String label,
    TextEditingController c,
    TextInputType type, {
    String? errorText,
  }) {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: c,
      keyboardType: type,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText, // ✅ shows warning below the field
        labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
        isDense: true,
        filled: true,
        fillColor: cs.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.4),
        ),
      ),
    );
  }
}
