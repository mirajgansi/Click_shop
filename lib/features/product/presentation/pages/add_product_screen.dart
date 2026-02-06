import 'package:click_shop/core/utils/snackbar_utils.dart';
import 'package:click_shop/features/auth/presentation/widgets/my_button_widgets.dart';
import 'package:click_shop/features/product/presentation/widgets/my_product_text_fied_widgets.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _nutritionController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = [
    "Beverages",
    "Snacks",
    "Dairy",
    "Fruits",
    "Vegetables",
  ];
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _nutritionController.dispose();
    _detailsController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _submitProduct() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        SnackbarUtils.showError(context, 'Please select a category');

        return;
      }
      final product = {
        "name": _nameController.text,
        "price": double.parse(_priceController.text),
        "nutrition": _nutritionController.text,
        "details": _detailsController.text,
        "image": _imageController.text,
        "category": _selectedCategory!,
      };

      debugPrint(product.toString());

      SnackbarUtils.showSuccess(context, 'Product added successfully');

      _formKey.currentState!.reset();
      setState(() {
        _selectedCategory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              MyProductTextFieldWidget(
                controller: _nameController,
                label: "Product Name",
                icon: Icons.shopping_bag,
              ),
              MyProductTextFieldWidget(
                controller: _priceController,
                label: "Price",
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              MyProductTextFieldWidget(
                controller: _nutritionController,
                label: "Nutrition",
                icon: Icons.health_and_safety,
              ),
              MyProductTextFieldWidget(
                controller: _detailsController,
                label: "Product Details",
                icon: Icons.description,
                maxLines: 3,
              ),
              MyProductTextFieldWidget(
                controller: _imageController,
                label: "Image URL",
                icon: Icons.image,
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Category",
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) return "Please select a category";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: MyButtonWidgets(
                  onPressed: _submitProduct,
                  text: 'Add Product',
                  height: 54,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
