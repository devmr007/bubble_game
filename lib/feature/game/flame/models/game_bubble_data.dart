import 'package:flutter/material.dart';
import '../../../levels/model/level_data.dart';

class GameBubbleData {
  int row;
  int col;
  BubbleType type;
  Offset position;
  bool isPopping;
  bool isFalling;
  Offset velocity;
  double popScale;

  GameBubbleData({
    required this.row,
    required this.col,
    required this.type,
    required this.position,
    this.isPopping = false,
    this.isFalling = false,
    this.velocity = Offset.zero,
    this.popScale = 1.0,
  });

  Color get color => type.color;
}
