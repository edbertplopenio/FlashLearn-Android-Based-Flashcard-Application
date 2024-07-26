import 'package:flutter/material.dart';

class GradientColorOption {
  final LinearGradient gradient;

  GradientColorOption(this.gradient);

  Map<String, dynamic> toJson() => {
        'colors': gradient.colors.map((color) => color.value).toList(),
        'begin': {
          'dx': (gradient.begin as Alignment).x,
          'dy': (gradient.begin as Alignment).y,
        },
        'end': {
          'dx': (gradient.end as Alignment).x,
          'dy': (gradient.end as Alignment).y,
        },
      };

  static GradientColorOption fromJson(Map<String, dynamic> json) {
    return GradientColorOption(
      LinearGradient(
        colors: (json['colors'] as List<dynamic>).map((color) => Color(color as int)).toList(),
        begin: Alignment(json['begin']['dx'], json['begin']['dy']),
        end: Alignment(json['end']['dx'], json['end']['dy']),
      ),
    );
  }
}
