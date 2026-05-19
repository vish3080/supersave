import 'package:flutter/material.dart';

// Replace these with your actual Supabase credentials.
// Supabase Dashboard → your project → Settings → API
const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

class PresetCategory {
  final String name;
  final String icon;
  final String colorHex;
  const PresetCategory(this.name, this.icon, this.colorHex);
}

const List<PresetCategory> defaultCategories = [
  PresetCategory('Housing', 'house', '5B8DEF'),
  PresetCategory('Food & Dining', 'restaurant', 'FF6B6B'),
  PresetCategory('Transport', 'directions_car', 'FFD93D'),
  PresetCategory('Health', 'favorite', '6BCB77'),
  PresetCategory('Entertainment', 'sports_esports', 'C77DFF'),
  PresetCategory('Shopping', 'shopping_bag', 'FF9A3C'),
  PresetCategory('Education', 'menu_book', '4ECDC4'),
  PresetCategory('Utilities', 'bolt', 'A8DADC'),
  PresetCategory('Travel', 'flight', 'F7B731'),
  PresetCategory('Other', 'more_horiz', 'B0B0B0'),
];

const List<Map<String, dynamic>> categoryIcons = [
  {'label': 'House', 'icon': Icons.house},
  {'label': 'Food', 'icon': Icons.restaurant},
  {'label': 'Car', 'icon': Icons.directions_car},
  {'label': 'Health', 'icon': Icons.favorite},
  {'label': 'Games', 'icon': Icons.sports_esports},
  {'label': 'Shopping', 'icon': Icons.shopping_bag},
  {'label': 'Book', 'icon': Icons.menu_book},
  {'label': 'Bolt', 'icon': Icons.bolt},
  {'label': 'Flight', 'icon': Icons.flight},
  {'label': 'More', 'icon': Icons.more_horiz},
  {'label': 'Card', 'icon': Icons.credit_card},
  {'label': 'Gift', 'icon': Icons.card_giftcard},
  {'label': 'Music', 'icon': Icons.music_note},
  {'label': 'Camera', 'icon': Icons.camera_alt},
  {'label': 'Pets', 'icon': Icons.pets},
  {'label': 'Sports', 'icon': Icons.fitness_center},
];

const List<Color> paletteColors = [
  Color(0xFF5B8DEF),
  Color(0xFFFF6B6B),
  Color(0xFFFFD93D),
  Color(0xFF6BCB77),
  Color(0xFFC77DFF),
  Color(0xFFFF9A3C),
  Color(0xFF4ECDC4),
  Color(0xFFA8DADC),
  Color(0xFFF7B731),
  Color(0xFF1DB954),
  Color(0xFFE91E63),
  Color(0xFF9C27B0),
];
