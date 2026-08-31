import 'package:flutter/material.dart';

class Product {
  final String name;
  final String category;
  final double price;
  final IconData icon;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
  });
}

const List<Product> allProducts = [
  Product(
    name: 'Wireless Mouse',
    category: 'Electronics',
    price: 599.00,
    icon: Icons.mouse,
  ),
  Product(
    name: 'Bluetooth Speaker',
    category: 'Electronics',
    price: 1299.00,
    icon: Icons.speaker,
  ),
  Product(
    name: 'Running Shoes',
    category: 'Sportswear',
    price: 1899.00,
    icon: Icons.directions_run,
  ),
  Product(
    name: 'Yoga Mat',
    category: 'Sportswear',
    price: 450.00,
    icon: Icons.fitness_center,
  ),
  Product(
    name: 'Notebook Set',
    category: 'Stationery',
    price: 120.00,
    icon: Icons.book,
  ),
  Product(
    name: 'Gel Pens (Set of 10)',
    category: 'Stationery',
    price: 85.00,
    icon: Icons.edit,
  ),
];
