import 'package:flutter/material.dart';
import '../models/models.dart';

TenantConfig defaultTenant() => TenantConfig(
      shopName: 'Mercado Full',
      logoEmoji: '🛒',
      primaryColor: const Color(0xFF2E7D32),
      secondaryColor: const Color(0xFFFFA000),
      tagline: 'Tu supermercado de confianza',
    );

const List<String> categories = [
  'Todos',
  'Frutas y Verduras',
  'Carnes',
  'Lácteos',
  'Despensa',
  'Bebidas',
  'Limpieza',
];

final List<Product> mockProducts = [
  Product(
    id: 'p1',
    name: 'Palta Hass',
    category: 'Frutas y Verduras',
    price: 1990,
    unit: 'kg',
  ),
  Product(
    id: 'p2',
    name: 'Plátano Cavendish',
    category: 'Frutas y Verduras',
    price: 990,
    unit: 'kg',
  ),
  Product(
    id: 'p3',
    name: 'Tomate Larga Vida',
    category: 'Frutas y Verduras',
    price: 1490,
    oldPrice: 1790,
    unit: 'kg',
  ),
  Product(
    id: 'p4',
    name: 'Pechuga de Pollo',
    category: 'Carnes',
    price: 4990,
    unit: 'kg',
  ),
  Product(
    id: 'p5',
    name: 'Lomo Liso Vacuno',
    category: 'Carnes',
    price: 8990,
    unit: 'kg',
  ),
  Product(
    id: 'p6',
    name: 'Leche Entera 1L',
    category: 'Lácteos',
    price: 1190,
    unit: 'un',
  ),
  Product(
    id: 'p7',
    name: 'Yogurt Natural',
    category: 'Lácteos',
    price: 1490,
    oldPrice: 1890,
    unit: 'un',
  ),
  Product(
    id: 'p8',
    name: 'Queso Gauda Laminado',
    category: 'Lácteos',
    price: 3290,
    unit: 'un',
  ),
  Product(
    id: 'p9',
    name: 'Arroz Grado 1',
    category: 'Despensa',
    price: 1390,
    unit: 'kg',
  ),
  Product(
    id: 'p10',
    name: 'Fideos Spaghetti',
    category: 'Despensa',
    price: 890,
    unit: 'un',
  ),
  Product(
    id: 'p11',
    name: 'Aceite de Oliva',
    category: 'Despensa',
    price: 5990,
    unit: 'un',
  ),
  Product(
    id: 'p12',
    name: 'Agua Mineral 1.5L',
    category: 'Bebidas',
    price: 890,
    unit: 'un',
  ),
  Product(
    id: 'p13',
    name: 'Bebida Cola 1.5L',
    category: 'Bebidas',
    price: 1590,
    oldPrice: 1990,
    unit: 'un',
  ),
  Product(
    id: 'p14',
    name: 'Jugo Natural Naranja',
    category: 'Bebidas',
    price: 2190,
    unit: 'un',
  ),
  Product(
    id: 'p15',
    name: 'Detergente Líquido',
    category: 'Limpieza',
    price: 4490,
    unit: 'un',
  ),
  Product(
    id: 'p16',
    name: 'Papel Higiénico x12',
    category: 'Limpieza',
    price: 5990,
    unit: 'un',
  ),
];
