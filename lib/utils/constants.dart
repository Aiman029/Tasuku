import 'package:flutter/material.dart';
import '../theme/anime_theme.dart';

class AppColors {
  static Color priorityColor(String priority) {
    return AnimeColors.getPriorityColor(priority);
  }
}