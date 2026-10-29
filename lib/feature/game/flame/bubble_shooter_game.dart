import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../levels/model/level_data.dart';
import 'models/game_bubble_data.dart';

typedef OnScoreUpdated = void Function(int scoreAdd);
typedef OnMoveUsed = void Function();
typedef OnLevelWon = void Function();
typedef OnLevelLost = void Function(String reason);

class BubbleShooterGame extends FlameGame with TapCallbacks, DragCallbacks {
  final LevelData levelData;
  final OnScoreUpdated onScoreUpdated;
  final OnMoveUsed onMoveUsed;
  final OnLevelWon onLevelWon;
  final OnLevelLost onLevelLost;

  BubbleShooterGame({
    required this.levelData,
    required this.onScoreUpdated,
    required this.onMoveUsed,
    required this.onLevelWon,
    required this.onLevelLost,
  });

  // Dimensions
  static const int cols = 8;
  static const int maxRows = 12;
  double bubbleRadius = 22.0;
  double bubbleDiameter = 44.0;
  double gridTopOffset = 80.0;
  double playWidth = 0.0;
  double playHeight = 0.0;

  // Grid storage: row -> col -> bubble
  late List<List<GameBubbleData?>> grid;

  // Falling & popping animation lists
  final List<GameBubbleData> _fallingBubbles = [];
  final List<GameBubbleData> _poppingBubbles = [];

  // Shooter & current bubble
  late Vector2 shooterPosition;
  double aimAngle = -math.pi / 2; // Pointing upwards
  bool isAiming = false;
  BubbleType? currentBulletType;
  BubbleType? nextBulletType;
  GameBubbleData? activeBullet;
  bool isBulletMoving = false;

  final math.Random _random = math.Random();

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _initGameDimensions();
    _initGrid();
    _reloadShooter();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _initGameDimensions();
  }

  void _initGameDimensions() {
    playWidth = size.x;
    playHeight = size.y;
    bubbleDiameter = playWidth / cols;
    bubbleRadius = bubbleDiameter / 2.0;
    shooterPosition = Vector2(playWidth / 2, playHeight - 65.0);
  }

  void _initGrid() {
    grid = List.generate(
      maxRows,
      (_) => List.generate(cols, (_) => null),
    );

    // Populate initial rows with level colors
    for (int r = 0; r < levelData.rowCount; r++) {
      final colsInRow = (r % 2 == 1) ? cols - 1 : cols;
      for (int c = 0; c < colsInRow; c++) {
        final randomColor = levelData
            .availableColors[_random.nextInt(levelData.availableColors.length)];
        final pos = _getGridBubblePosition(r, c);
        grid[r][c] = GameBubbleData(
          row: r,
          col: c,
          type: randomColor,
          position: pos,
        );
      }
    }
  }

  Offset _getGridBubblePosition(int row, int col) {
    final isOddRow = (row % 2 == 1);
    final xOffset = isOddRow ? bubbleRadius : 0.0;
    final x = (col * bubbleDiameter) + bubbleRadius + xOffset;
    final y = gridTopOffset + (row * bubbleDiameter * 0.866) + bubbleRadius;
    return Offset(x, y);
  }

  BubbleType _getRandomAvailableColor() {
    // Pick from remaining colors in grid if possible
    final remainingColors = <BubbleType>{};
    for (final row in grid) {
      for (final b in row) {
        if (b != null) remainingColors.add(b.type);
      }
    }
    if (remainingColors.isNotEmpty) {
      final list = remainingColors.toList();
      return list[_random.nextInt(list.length)];
    }
    return levelData.availableColors[_random.nextInt(levelData.availableColors.length)];
  }

  void _reloadShooter() {
    currentBulletType = nextBulletType ?? _getRandomAvailableColor();
    nextBulletType = _getRandomAvailableColor();
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (isBulletMoving) return;
    isAiming = true;
    _updateAimAngle(event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!isAiming || isBulletMoving) return;
    _updateAimAngle(event.canvasEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (isAiming && !isBulletMoving) {
      isAiming = false;
      _shootBubble();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isBulletMoving) return;
    _updateAimAngle(event.canvasPosition);
    _shootBubble();
  }

  void _updateAimAngle(Vector2 touchPoint) {
    final diff = touchPoint - shooterPosition;
    // Calculate angle towards touch
    var angle = math.atan2(diff.y, diff.x);
    // Clamp so player cannot shoot downwards
    const minAngle = -math.pi + 0.15;
    const maxAngle = -0.15;
    angle = angle.clamp(minAngle, maxAngle);
    aimAngle = angle;
  }

  void _shootBubble() {
    if (currentBulletType == null || isBulletMoving) return;

    const speed = 950.0;
    final vx = math.cos(aimAngle) * speed;
    final vy = math.sin(aimAngle) * speed;

    activeBullet = GameBubbleData(
      row: -1,
      col: -1,
      type: currentBulletType!,
      position: Offset(shooterPosition.x, shooterPosition.y),
      velocity: Offset(vx, vy),
    );

    isBulletMoving = true;
    onMoveUsed();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 1. Update active bullet
    if (activeBullet != null && isBulletMoving) {
      final pos = activeBullet!.position;
      final vel = activeBullet!.velocity;

      var newX = pos.dx + vel.dx * dt;
      var newY = pos.dy + vel.dy * dt;
      var newVx = vel.dx;

      // Wall bounce
      if (newX - bubbleRadius <= 0) {
        newX = bubbleRadius;
        newVx = -vel.dx;
      } else if (newX + bubbleRadius >= playWidth) {
        newX = playWidth - bubbleRadius;
        newVx = -vel.dx;
      }

      activeBullet!.position = Offset(newX, newY);
      activeBullet!.velocity = Offset(newVx, vel.dy);

      // Collision check with ceiling or existing bubbles
      if (newY - bubbleRadius <= gridTopOffset || _checkGridCollision(activeBullet!)) {
        _snapBulletToGrid(activeBullet!);
        activeBullet = null;
        isBulletMoving = false;
        _reloadShooter();
      }
    }

    // 2. Update popping bubbles
    for (int i = _poppingBubbles.length - 1; i >= 0; i--) {
      final b = _poppingBubbles[i];
      b.popScale += dt * 6.0;
      if (b.popScale > 1.8) {
        _poppingBubbles.removeAt(i);
      }
    }

    // 3. Update falling bubbles
    for (int i = _fallingBubbles.length - 1; i >= 0; i--) {
      final b = _fallingBubbles[i];
      final pos = b.position;
      final vel = b.velocity;
      b.position = Offset(pos.dx + vel.dx * dt, pos.dy + (vel.dy + 800 * dt) * dt);
      b.velocity = Offset(vel.dx, vel.dy + 800 * dt);

      if (b.position.dy > playHeight + 50) {
        _fallingBubbles.removeAt(i);
      }
    }
  }

  bool _checkGridCollision(GameBubbleData bullet) {
    for (int r = 0; r < maxRows; r++) {
      for (int c = 0; c < cols; c++) {
        final b = grid[r][c];
        if (b != null) {
          final distSq = (bullet.position.dx - b.position.dx) * (bullet.position.dx - b.position.dx) +
              (bullet.position.dy - b.position.dy) * (bullet.position.dy - b.position.dy);
          if (distSq <= (bubbleDiameter * 0.9) * (bubbleDiameter * 0.9)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _snapBulletToGrid(GameBubbleData bullet) {
    // Find closest valid empty cell
    int bestRow = 0;
    int bestCol = 0;
    double minDistance = double.infinity;

    for (int r = 0; r < maxRows; r++) {
      final colsInRow = (r % 2 == 1) ? cols - 1 : cols;
      for (int c = 0; c < colsInRow; c++) {
        if (grid[r][c] == null) {
          // A cell is attachable if it's top row (r==0) or neighbor to an existing bubble
          if (r == 0 || _hasExistingNeighbor(r, c)) {
            final center = _getGridBubblePosition(r, c);
            final distSq = (bullet.position.dx - center.dx) * (bullet.position.dx - center.dx) +
                (bullet.position.dy - center.dy) * (bullet.position.dy - center.dy);
            if (distSq < minDistance) {
              minDistance = distSq;
              bestRow = r;
              bestCol = c;
            }
          }
        }
      }
    }

    // Place bullet
    final targetPos = _getGridBubblePosition(bestRow, bestCol);
    final newBubble = GameBubbleData(
      row: bestRow,
      col: bestCol,
      type: bullet.type,
      position: targetPos,
    );
    grid[bestRow][bestCol] = newBubble;

    // Check match-3
    _resolveMatches(bestRow, bestCol, bullet.type);

    // Check danger limit (if bubbles touch bottom)
    if (bestRow >= maxRows - 2) {
      onLevelLost('Bubbles reached the danger line!');
      return;
    }

    // Check if level cleared
    if (_isGridEmpty()) {
      onLevelWon();
    }
  }

  bool _hasExistingNeighbor(int row, int col) {
    final neighbors = _getNeighbors(row, col);
    for (final n in neighbors) {
      if (grid[n.$1][n.$2] != null) return true;
    }
    return false;
  }

  List<(int, int)> _getNeighbors(int r, int c) {
    final isOdd = (r % 2 == 1);
    final neighbors = <(int, int)>[];

    final deltas = isOdd
        ? [
            (0, -1), (0, 1), // Left, Right
            (-1, 0), (-1, 1), // Up-Left, Up-Right
            (1, 0), (1, 1), // Down-Left, Down-Right
          ]
        : [
            (0, -1), (0, 1), // Left, Right
            (-1, -1), (-1, 0), // Up-Left, Up-Right
            (1, -1), (1, 0), // Down-Left, Down-Right
          ];

    for (final d in deltas) {
      final nr = r + d.$1;
      final nc = c + d.$2;
      final colsInNeighborRow = (nr % 2 == 1) ? cols - 1 : cols;
      if (nr >= 0 && nr < maxRows && nc >= 0 && nc < colsInNeighborRow) {
        neighbors.add((nr, nc));
      }
    }
    return neighbors;
  }

  void _resolveMatches(int startRow, int startCol, BubbleType matchType) {
    // BFS search
    final queue = <(int, int)>[(startRow, startCol)];
    final visited = <(int, int)>{(startRow, startCol)};
    final matched = <(int, int)>[(startRow, startCol)];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      for (final neighbor in _getNeighbors(current.$1, current.$2)) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          final b = grid[neighbor.$1][neighbor.$2];
          if (b != null && b.type == matchType) {
            matched.add(neighbor);
            queue.add(neighbor);
          }
        }
      }
    }

    if (matched.length >= 3) {
      // Pop matches
      for (final m in matched) {
        final b = grid[m.$1][m.$2];
        if (b != null) {
          b.isPopping = true;
          _poppingBubbles.add(b);
          grid[m.$1][m.$2] = null;
        }
      }

      onScoreUpdated(matched.length * 100);

      // Check and drop disconnected / floating bubbles
      _dropFloatingBubbles();
    }
  }

  void _dropFloatingBubbles() {
    // BFS from row 0 to find all connected bubbles
    final connected = <(int, int)>{};
    final queue = <(int, int)>[];

    for (int c = 0; c < cols; c++) {
      if (grid[0][c] != null) {
        connected.add((0, c));
        queue.add((0, c));
      }
    }

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      for (final neighbor in _getNeighbors(current.$1, current.$2)) {
        if (!connected.contains(neighbor)) {
          final b = grid[neighbor.$1][neighbor.$2];
          if (b != null) {
            connected.add(neighbor);
            queue.add(neighbor);
          }
        }
      }
    }

    // Any bubble not connected to ceiling drops down!
    int droppedCount = 0;
    for (int r = 0; r < maxRows; r++) {
      final colsInRow = (r % 2 == 1) ? cols - 1 : cols;
      for (int c = 0; c < colsInRow; c++) {
        final b = grid[r][c];
        if (b != null && !connected.contains((r, c))) {
          b.isFalling = true;
          b.velocity = Offset((_random.nextDouble() - 0.5) * 150, -50);
          _fallingBubbles.add(b);
          grid[r][c] = null;
          droppedCount++;
        }
      }
    }

    if (droppedCount > 0) {
      onScoreUpdated(droppedCount * 250);
    }
  }

  bool _isGridEmpty() {
    for (final row in grid) {
      for (final b in row) {
        if (b != null) return false;
      }
    }
    return true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Draw ceiling line
    final ceilingPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(0, gridTopOffset),
      Offset(playWidth, gridTopOffset),
      ceilingPaint,
    );

    // 2. Draw Grid Bubbles
    for (int r = 0; r < maxRows; r++) {
      final colsInRow = (r % 2 == 1) ? cols - 1 : cols;
      for (int c = 0; c < colsInRow; c++) {
        final b = grid[r][c];
        if (b != null) {
          _drawBubble(canvas, b.position, b.color, bubbleRadius);
        }
      }
    }

    // 3. Draw Popping Bubbles
    for (final b in _poppingBubbles) {
      final paint = Paint()
        ..color = b.color.withValues(alpha: (1.8 - b.popScale).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(b.position, bubbleRadius * b.popScale, paint);
    }

    // 4. Draw Falling Bubbles
    for (final b in _fallingBubbles) {
      _drawBubble(canvas, b.position, b.color, bubbleRadius);
    }

    // 5. Draw Aim Line with Trajectory and Wall Bounce
    if (isAiming && !isBulletMoving) {
      _drawAimTrajectory(canvas);
    }

    // 6. Draw Shooter Base & Loaded Bullet
    _drawShooter(canvas);

    // 7. Draw Active Bullet
    if (activeBullet != null) {
      _drawBubble(
        canvas,
        activeBullet!.position,
        activeBullet!.color,
        bubbleRadius,
      );
    }
  }

  void _drawAimTrajectory(Canvas canvas) {
    final trajectoryPaint = Paint()
      ..color = (currentBulletType?.color ?? Colors.white).withValues(alpha: 0.75)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    var start = Offset(shooterPosition.x, shooterPosition.y);
    var dir = Offset(math.cos(aimAngle), math.sin(aimAngle));
    double remainingDistance = 600.0;

    for (int segment = 0; segment < 2; segment++) {
      // Find intersection with wall or top ceiling
      double tx = double.infinity;
      double ty = double.infinity;

      if (dir.dx > 0) {
        tx = (playWidth - bubbleRadius - start.dx) / dir.dx;
      } else if (dir.dx < 0) {
        tx = (bubbleRadius - start.dx) / dir.dx;
      }

      if (dir.dy < 0) {
        ty = (gridTopOffset + bubbleRadius - start.dy) / dir.dy;
      }

      final t = math.min(tx, ty);
      final stepDistance = math.min(t, remainingDistance);

      final end = Offset(
        start.dx + dir.dx * stepDistance,
        start.dy + dir.dy * stepDistance,
      );

      // Draw dashed trajectory segment
      _drawDashedLine(canvas, start, end, trajectoryPaint);

      remainingDistance -= stepDistance;
      if (remainingDistance <= 0 || t == ty) break;

      // Bounce off wall
      start = end;
      dir = Offset(-dir.dx, dir.dy);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLength = 10.0;
    const gapLength = 8.0;
    final totalDistance = (p2 - p1).distance;
    final direction = (p2 - p1) / totalDistance;

    double currentDist = 0.0;
    while (currentDist < totalDistance) {
      final start = p1 + direction * currentDist;
      final end = p1 + direction * math.min(currentDist + dashLength, totalDistance);
      canvas.drawLine(start, end, paint);
      currentDist += dashLength + gapLength;
    }
  }

  void _drawShooter(Canvas canvas) {
    // Cannon Base Ring
    final basePaint = Paint()
      ..color = AppColors.cardBgElevated
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(
      Offset(shooterPosition.x, shooterPosition.y),
      bubbleRadius * 1.55,
      basePaint,
    );
    canvas.drawCircle(
      Offset(shooterPosition.x, shooterPosition.y),
      bubbleRadius * 1.55,
      borderPaint,
    );

    // Rotating Cannon Barrel Arrow
    canvas.save();
    canvas.translate(shooterPosition.x, shooterPosition.y);
    canvas.rotate(aimAngle + math.pi / 2);

    final arrowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final arrowPath = Path()
      ..moveTo(-12, -bubbleRadius * 1.4)
      ..lineTo(0, -bubbleRadius * 2.1)
      ..lineTo(12, -bubbleRadius * 1.4)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);
    canvas.restore();

    // Next loaded bubble indicator (smaller preview to the left)
    if (nextBulletType != null) {
      final nextPos = Offset(shooterPosition.x - bubbleRadius * 2.8, shooterPosition.y + 6);
      _drawBubble(canvas, nextPos, nextBulletType!.color, bubbleRadius * 0.7);
    }

    // Current shooter bubble
    if (currentBulletType != null && !isBulletMoving) {
      _drawBubble(
        canvas,
        Offset(shooterPosition.x, shooterPosition.y),
        currentBulletType!.color,
        bubbleRadius,
      );
    }
  }

  void _drawBubble(Canvas canvas, Offset pos, Color color, double radius) {
    // Outer 3D Sphere Glow
    final mainPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.9,
        colors: [
          Color.lerp(color, Colors.white, 0.45)!,
          color,
          Color.lerp(color, Colors.black, 0.35)!,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: radius));

    canvas.drawCircle(pos, radius, mainPaint);

    // Sheen reflection
    final sheenPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(pos.dx - radius * 0.35, pos.dy - radius * 0.35),
      radius * 0.28,
      sheenPaint,
    );
  }
}

