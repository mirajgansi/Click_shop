class HiveTableConstants {
  HiveTableConstants._();

  static const String dbName = 'Click_shop';

  // ================= AUTH =================
  static const int authtypeId = 0;
  static const String authTable = 'auth_table';

  // ================= PRODUCTS =================
  static const int productTypeId = 1;
  static const String productTable = 'product_table';

  // ================= CART =================
  static const int cartTypeId = 2;
  static const String cartTable = 'cart_table';

  // ================= CATEGORY =================
  static const int categoryTypeId = 3;
  static const String categoryTable = 'category_table';

  // ================= ORDERS =================
  // ✅ Use NEW, UNIQUE typeIds
  static const int orderTypeId = 30;
  static const int orderItemTypeId = 31;
  static const int shippingAddressTypeId = 32;

  static const String orderTable = 'orders_table';
}
