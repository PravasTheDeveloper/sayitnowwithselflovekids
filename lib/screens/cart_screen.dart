import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Sample cart items - in a real app, this would come from a cart service or provider
  final List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      title: 'Kyle & Baby Danielle Dolls',
      price: 79.95,
      imageUrl: 'assets/images/product1.jpg',
      quantity: 1,
    ),
    CartItem(
      id: '3',
      title: 'Pre-Order – SAY IT NOW WITH SELF-LOVE KIDS LLC MOTIVATIONAL WAKE-UP MUSICAL PLUSH CLOCK',
      price: 33.95,
      imageUrl: 'assets/images/product3.png',
      quantity: 2,
    ),
  ];

  double get _totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _updateQuantity(CartItem item, int change) {
    setState(() {
      final index = _cartItems.indexOf(item);
      final newQuantity = item.quantity + change;
      
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index] = CartItem(
          id: item.id,
          title: item.title,
          price: item.price,
          imageUrl: item.imageUrl,
          quantity: newQuantity,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8E8D0),
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFF9A826),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(),
      bottomNavigationBar: _cartItems.isEmpty
          ? null
          : _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to start shopping',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF9A826),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._cartItems.map((item) => CartItemCard(
              item: item,
              onIncrement: () => _updateQuantity(item, 1),
              onDecrement: () => _updateQuantity(item, -1),
              onRemove: () => _updateQuantity(item, -item.quantity),
            )),
        const SizedBox(height: 16),
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
              ),
              Text(
                '\$${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shipping',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF718096),
                ),
              ),
              const Text(
                'Free',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF38A169),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                '\$${_totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to checkout screen
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF6B6B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Checkout (\$${_totalAmount.toStringAsFixed(2)})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: onDecrement,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: onIncrement,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Remove Button
                      InkWell(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
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

class CartItem {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });
}