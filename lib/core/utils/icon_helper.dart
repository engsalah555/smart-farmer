import 'package:flutter/material.dart';

class IconHelper {
  /// Maps a string identifier to a Material IconData.
  /// Used to unify icons across Marketplace, Community, and Home.
  static IconData getIconByName(String? name) {
    if (name == null) return Icons.category_rounded;
    
    switch (name.toLowerCase()) {
      // Marketplace & Categories
      case 'eco':
      case 'leaf':
        return Icons.eco_rounded;
      case 'opacity':
      case 'water':
        return Icons.opacity_rounded;
      case 'bug_report':
      case 'insect':
        return Icons.bug_report_rounded;
      case 'grass':
      case 'crops':
        return Icons.grass_rounded;
      case 'construction':
      case 'tools':
        return Icons.construction_rounded;
      case 'store':
      case 'storefront':
        return Icons.storefront_rounded;
      case 'apps':
        return Icons.apps_rounded;
      case 'category':
        return Icons.category_rounded;
      case 'landscape':
        return Icons.landscape_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'inventory':
        return Icons.inventory_2_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'chat':
        return Icons.chat_bubble_rounded;
      case 'person':
        return Icons.person_rounded;
      case 'location':
        return Icons.location_on_rounded;
      case 'star':
        return Icons.star_rounded;
        
      // Default
      default:
        return Icons.category_rounded;
    }
  }
}
