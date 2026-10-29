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

  // Ball switch / rotate animation
  bool isSwapping = false;
  double swapTime = 0.0;
  static const double swapDuration = 0.24;
  double switchIconRotation = 0.0;

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
    grid = List.generate(maxRows, (_) => List.generate(cols, (_) => null));

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
    return levelData.availableColors[_random.nextInt(
      levelData.availableColors.length,
    )];
  }

  void _reloadShooter() {
    currentBulletType = nextBulletType ?? _getRandomAvailableColor();
    nextBulletType = _getRandomAvailableColor();
  }

  // Switch between current and reserve bubble with rotation animation
  void switchBubbles() {
    if (isBulletMoving ||
        isSwapping ||
        currentBulletType == null ||
        nextBulletType == null) {
      return;
    }
    isSwapping = true;
    swapTime = 0.0;
  }

  bool _isTapInsideSwitchArea(Vector2 tapPos) {
    final nextPos = Offset(
      shooterPosition.x - bubbleRadius * 2.8,
      shooterPosition.y + 6,
    );
    final switchPos = Offset(
      (shooterPosition.x + nextPos.dx) / 2,
      shooterPosition.y - bubbleRadius * 1.3,
    );
    final distToNext = (Vector2(nextPos.dx, nextPos.dy) - tapPos).length;
    final distToSwitch = (Vector2(switchPos.dx, switchPos.dy) - tapPos).length;
    return distToNext <= bubbleRadius * 1.8 ||
        distToSwitch <= bubbleRadius * 1.5;
  }

  // -------------------------------------------------------------
  // Touch & Hold Aiming Controls (Release to Shoot)
  // -------------------------------------------------------------

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isBulletMoving || isSwapping) return;

    if (_isTapInsideSwitchArea(event.canvasPosition)) {
      switchBubbles();
      return;
    }

    if (event.canvasPosition.y > shooterPosition.y + 15) return;

    // Start aiming on hold - DO NOT shoot yet!
    isAiming = true;
    _updateAimAngle(event.canvasPosition);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    // Release from hold to shoot!
    if (isAiming && !isBulletMoving && !isSwapping) {
      isAiming = false;
      _updateAimAngle(event.canvasPosition);
      _shootBubble();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    isAiming = false;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (isBulletMoving || isSwapping) return;

    if (_isTapInsideSwitchArea(event.canvasPosition)) {
      switchBubbles();
      return;
    }

    if (event.canvasPosition.y > shooterPosition.y + 15) return;

    isAiming = true;
    _updateAimAngle(event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isBulletMoving || isSwapping) return;

    // Cancel aim if dragged below cannon
    if (event.canvasEndPosition.y > shooterPosition.y + 35) {
      isAiming = false;
      return;
    }

    isAiming = true;
    _updateAimAngle(event.canvasEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    // Release from hold to shoot!
    if (isAiming && !isBulletMoving && !isSwapping) {
      isAiming = false;
      _shootBubble();
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    isAiming = false;
  }

  void _updateAimAngle(Vector2 touchPoint) {
    final diff = touchPoint - shooterPosition;
    var angle = math.atan2(diff.y, diff.x);
    // Clamp so player cannot shoot downwards
    const minAngle = -math.pi + 0.12;
    const maxAngle = -0.12;
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

    // Swap rotation update
    if (isSwapping) {
      swapTime += dt;
      switchIconRotation += dt * (math.pi / swapDuration);
      if (swapTime >= swapDuration) {
        final temp = currentBulletType;
        currentBulletType = nextBulletType;
        nextBulletType = temp;
        isSwapping = false;
        swapTime = 0.0;
      }
    } else {
      switchIconRotation += dt * 0.9;
    }

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
      if (newY - bubbleRadius <= gridTopOffset ||
          _checkGridCollision(activeBullet!)) {
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
      b.position = Offset(
        pos.dx + vel.dx * dt,
        pos.dy + (vel.dy + 800 * dt) * dt,
      );
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
          final distSq =
              (bullet.position.dx - b.position.dx) *
                  (bullet.position.dx - b.position.dx) +
              (bullet.position.dy - b.position.dy) *
                  (bullet.position.dy - b.position.dy);
          if (distSq <= (bubbleDiameter * 0.9) * (bubbleDiameter * 0.9)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _snapBulletToGrid(GameBubbleData bullet) {
    int bestRow = 0;
    int bestCol = 0;
    double minDistance = double.infinity;

    for (int r = 0; r < maxRows; r++) {
      final colsInRow = (r % 2 == 1) ? cols - 1 : cols;
      for (int c = 0; c < colsInRow; c++) {
        if (grid[r][c] == null) {
          if (r == 0 || _hasExistingNeighbor(r, c)) {
            final center = _getGridBubblePosition(r, c);
            final distSq =
                (bullet.position.dx - center.dx) *
                    (bullet.position.dx - center.dx) +
                (bullet.position.dy - center.dy) *
                    (bullet.position.dy - center.dy);
            if (distSq < minDistance) {
              minDistance = distSq;
              bestRow = r;
              bestCol = c;
            }
          }
        }
      }
    }

    final targetPos = _getGridBubblePosition(bestRow, bestCol);
    final newBubble = GameBubbleData(
      row: bestRow,
      col: bestCol,
      type: bullet.type,
      position: targetPos,
    );
    grid[bestRow][bestCol] = newBubble;

    _resolveMatches(bestRow, bestCol, bullet.type);

    if (bestRow >= maxRows - 2) {
      onLevelLost('Bubbles reached the danger line!');
      return;
    }

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
        ? [(0, -1), (0, 1), (-1, 0), (-1, 1), (1, 0), (1, 1)]
        : [(0, -1), (0, 1), (-1, -1), (-1, 0), (1, -1), (1, 0)];

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
      for (final m in matched) {
        final b = grid[m.$1][m.$2];
        if (b != null) {
          b.isPopping = true;
          _poppingBubbles.add(b);
          grid[m.$1][m.$2] = null;
        }
      }

      onScoreUpdated(matched.length * 100);
      _dropFloatingBubbles();
    }
  }

  void _dropFloatingBubbles() {
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

    // 5. Draw Aim Line & Target Helper across half the screen while holding
    if (isAiming && !isBulletMoving) {
      _drawAimTrajectory(canvas);
    }

    // 6. Draw Shooter Base, Cannons & Rotate Switch
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

  // -------------------------------------------------------------
  // Target Helper & Trajectory Raycasting (Half Screen Helper)
  // -------------------------------------------------------------

  Offset? _findGridImpact(Offset start, Offset dir, double maxDist) {
    const step = 6.0;
    double dist = 0.0;
    while (dist < maxDist) {
      dist += step;
      final p = start + dir * dist;
      if (p.dy - bubbleRadius <= gridTopOffset) return p;

      for (int r = 0; r < maxRows; r++) {
        for (int c = 0; c < cols; c++) {
          final b = grid[r][c];
          if (b != null) {
            final dx = p.dx - b.position.dx;
            final dy = p.dy - b.position.dy;
            if (dx * dx + dy * dy <=
                (bubbleDiameter * 0.92) * (bubbleDiameter * 0.92)) {
              return p;
            }
          }
        }
      }
    }
    return null;
  }

  void _drawAimTrajectory(Canvas canvas) {
    if (currentBulletType == null) return;
    final bulletColor = currentBulletType!.color;

    // Extend helper across at least half of screen height
    final targetHelperDistance = playHeight * 0.54;
    var remainingDistance = targetHelperDistance;
    var start = Offset(shooterPosition.x, shooterPosition.y);
    var dir = Offset(math.cos(aimAngle), math.sin(aimAngle));

    final segments = <(Offset, Offset)>[];

    for (int segment = 0; segment < 3; segment++) {
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

      final wallLimit = math.min(tx, ty);
      final segmentLimit = math.min(wallLimit, remainingDistance);

      final hit = _findGridImpact(start, dir, segmentLimit);
      if (hit != null) {
        segments.add((start, hit));
        break;
      }

      final end = Offset(
        start.dx + dir.dx * segmentLimit,
        start.dy + dir.dy * segmentLimit,
      );
      segments.add((start, end));

      remainingDistance -= segmentLimit;
      if (remainingDistance <= 0 || wallLimit == ty) {
        break;
      }

      // Bounce off wall
      start = end;
      dir = Offset(-dir.dx, dir.dy);
    }

    // Draw fading laser line & beads from bottom (high opacity) to top (low opacity)
    double accumulatedDist = 0.0;
    const dashLength = 11.0;
    const gapLength = 8.0;
    const beadSpacing = 20.0;

    final dashPaint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final beadGlowPaint = Paint()..style = PaintingStyle.fill;
    final beadCorePaint = Paint()..style = PaintingStyle.fill;

    for (final seg in segments) {
      final segLength = (seg.$2 - seg.$1).distance;
      if (segLength <= 0) continue;
      final segDir = (seg.$2 - seg.$1) / segLength;

      // 1. Draw dashed laser line fading from bottom to top
      double curDash = 0.0;
      while (curDash < segLength) {
        final dStart = seg.$1 + segDir * curDash;
        final actualDash = math.min(dashLength, segLength - curDash);
        final dEnd = dStart + segDir * actualDash;

        final distFromShooter = accumulatedDist + curDash;
        final progress = (distFromShooter / targetHelperDistance).clamp(0.0, 1.0);
        // High opacity at bottom (0.80), fading down to low opacity at top (0.08)
        final alpha = (1.0 - progress * 0.90).clamp(0.08, 0.80);

        dashPaint.color = bulletColor.withValues(alpha: alpha);
        canvas.drawLine(dStart, dEnd, dashPaint);

        curDash += dashLength + gapLength;
      }

      // 2. Draw glowing trajectory beads fading from bottom to top
      double curBead = 0.0;
      while (curBead < segLength) {
        final pt = seg.$1 + segDir * curBead;
        final distFromShooter = accumulatedDist + curBead;
        final progress = (distFromShooter / targetHelperDistance).clamp(0.0, 1.0);
        // High opacity at bottom (0.90), fading down to low opacity at top (0.09)
        final alpha = (1.0 - progress * 0.90).clamp(0.09, 0.90);
        final dotRadius = (3.5 - progress * 1.5).clamp(1.8, 3.5);

        // Outer glow
        beadGlowPaint.color = bulletColor.withValues(alpha: alpha * 0.60);
        canvas.drawCircle(pt, dotRadius + 1.5, beadGlowPaint);

        // Core dot
        beadCorePaint.color = Colors.white.withValues(alpha: alpha * 0.95);
        canvas.drawCircle(pt, dotRadius * 0.65, beadCorePaint);

        curBead += beadSpacing;
      }

      accumulatedDist += segLength;
    }
  }

  // -------------------------------------------------------------
  // Shooter, Cannon & Rotating Ball Switch Rendering
  // -------------------------------------------------------------

  void _drawShooter(Canvas canvas) {
    final shooterCenter = Offset(shooterPosition.x, shooterPosition.y);
    final nextCenter = Offset(
      shooterPosition.x - bubbleRadius * 2.8,
      shooterPosition.y + 6,
    );

    // Reserve bubble base ring
    final reserveBase = Paint()
      ..color = AppColors.cardBgElevated.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final reserveBorder = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(nextCenter, bubbleRadius * 1.05, reserveBase);
    canvas.drawCircle(nextCenter, bubbleRadius * 1.05, reserveBorder);

    // Rotating Switch/Swap Badge
    final switchCenter = Offset(
      (shooterCenter.dx + nextCenter.dx) / 2,
      shooterCenter.dy - bubbleRadius * 1.25,
    );
    _drawRotateSwitchBadge(canvas, switchCenter);

    // Cannon Base Ring
    final basePaint = Paint()
      ..color = AppColors.cardBgElevated
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(shooterCenter, bubbleRadius * 1.55, basePaint);
    canvas.drawCircle(shooterCenter, bubbleRadius * 1.55, borderPaint);

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

    // Render balls with orbital swap animation
    if (isSwapping && currentBulletType != null && nextBulletType != null) {
      final t = (swapTime / swapDuration).clamp(0.0, 1.0);
      final mid = Offset(
        (shooterCenter.dx + nextCenter.dx) / 2,
        (shooterCenter.dy + nextCenter.dy) / 2,
      );
      final orbitR = (shooterCenter - nextCenter).distance / 2;
      final angle = math.pi * t;

      final curPos = Offset(
        mid.dx + orbitR * math.cos(angle),
        mid.dy - orbitR * math.sin(angle) * 0.8,
      );
      final curRadius = bubbleRadius * (1.0 - 0.25 * t);

      final nxtPos = Offset(
        mid.dx - orbitR * math.cos(angle),
        mid.dy + orbitR * math.sin(angle) * 0.8,
      );
      final nxtRadius = bubbleRadius * (0.75 + 0.25 * t);

      _drawBubble(canvas, nxtPos, nextBulletType!.color, nxtRadius);
      _drawBubble(canvas, curPos, currentBulletType!.color, curRadius);
    } else {
      // Next loaded bubble indicator (smaller preview to the left)
      if (nextBulletType != null) {
        _drawBubble(
          canvas,
          nextCenter,
          nextBulletType!.color,
          bubbleRadius * 0.75,
        );
      }

      // Current shooter bubble
      if (currentBulletType != null && !isBulletMoving) {
        _drawBubble(
          canvas,
          shooterCenter,
          currentBulletType!.color,
          bubbleRadius,
        );
      }
    }
  }

  void _drawRotateSwitchBadge(Canvas canvas, Offset center) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(switchIconRotation);

    // Glowing badge circle
    final badgePaint = Paint()
      ..color = AppColors.cardBgElevated
      ..style = PaintingStyle.fill;
    final badgeBorder = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset.zero, 13, badgePaint);
    canvas.drawCircle(Offset.zero, 13, badgeBorder);

    // Two curved arrows
    final arrowPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillArrow = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    // Top arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 7.5),
      -math.pi * 0.85,
      math.pi * 0.7,
      false,
      arrowPaint,
    );
    // Arrowhead 1
    final path1 = Path()
      ..moveTo(5.5, -4.5)
      ..lineTo(8.5, -7.5)
      ..lineTo(5.5, -10.5)
      ..close();
    canvas.drawPath(path1, fillArrow);

    // Bottom arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 7.5),
      math.pi * 0.15,
      math.pi * 0.7,
      false,
      arrowPaint,
    );
    // Arrowhead 2
    final path2 = Path()
      ..moveTo(-5.5, 4.5)
      ..lineTo(-8.5, 7.5)
      ..lineTo(-5.5, 10.5)
      ..close();
    canvas.drawPath(path2, fillArrow);

    canvas.restore();
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
