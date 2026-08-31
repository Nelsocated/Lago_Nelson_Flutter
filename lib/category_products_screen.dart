import 'package:flutter/material.dart';
import 'package:flutter_act/product.dart';
import 'package:flutter_act/product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final List<Product> filteredProducts = allProducts
        .where((product) => product.category == category)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return ListTile(
            leading: Icon(product.icon),
            title: Text(product.name),
            trailing: Text('₱${product.price.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
