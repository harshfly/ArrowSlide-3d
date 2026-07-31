/// Represents a movable arrow block or multi-cell bar in the puzzle.
///
/// Features:
/// - Fixed cardinal direction (up, down, left, right).
/// - 1x1 single cell tiles or multi-cell bars (1x2, 1x3, 2x1, 3x1).
/// - Special flags: rotatable, hidden, key, player.
class ArrowBlock {
  final String id;
  final int x;
  final int y;
  final int width;
  final int height;
  final Direction direction;
  final bool isRotatable;
  final bool isHidden;
  final bool isKey;
  final bool isPlayer;

  const ArrowBlock({
    required this.id,
    required this.x,
    required this.y,
    this.width = 1,
    this.height = 1,
    required this.direction,
    this.isRotatable = false,
    this.isHidden = false,
    this.isKey = false,
    this.isPlayer = false,
  });

  /// All grid coordinates occupied by this block.
  List<(int x, int y)> get occupiedCells {
    final cells = <(int, int)>[];
    for (int dx = 0; dx < width; dx++) {
      for (int dy = 0; dy < height; dy++) {
        cells.add((x + dx, y + dy));
      }
    }
    return cells;
  }

  /// Does this block occupy grid cell (cx, cy)?
  bool occupiesCell(int cx, int cy) {
    return cx >= x && cx < x + width && cy >= y && cy < y + height;
  }

  factory ArrowBlock.fromJson(Map<String, dynamic> json) {
    return ArrowBlock(
      id: json['id'] as String,
      x: json['x'] as int,
      y: json['y'] as int,
      width: json['width'] as int? ?? 1,
      height: json['height'] as int? ?? 1,
      direction: Direction.fromString(json['direction'] as String),
      isRotatable: json['rotatable'] as bool? ?? false,
      isHidden: json['hidden'] as bool? ?? false,
      isKey: json['isKey'] as bool? ?? false,
      isPlayer: json['isPlayer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'x': x,
        'y': y,
        if (width > 1) 'width': width,
        if (height > 1) 'height': height,
        'direction': direction.name,
        if (isRotatable) 'rotatable': true,
        if (isHidden) 'hidden': true,
        if (isKey) 'isKey': true,
        if (isPlayer) 'isPlayer': true,
      };

  ArrowBlock copyWith({
    String? id,
    int? x,
    int? y,
    int? width,
    int? height,
    Direction? direction,
    bool? isRotatable,
    bool? isHidden,
    bool? isKey,
    bool? isPlayer,
  }) {
    return ArrowBlock(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      direction: direction ?? this.direction,
      isRotatable: isRotatable ?? this.isRotatable,
      isHidden: isHidden ?? this.isHidden,
      isKey: isKey ?? this.isKey,
      isPlayer: isPlayer ?? this.isPlayer,
    );
  }
}

/// Cardinal direction for arrow blocks and one-way gates.
enum Direction {
  up,
  down,
  left,
  right;

  static Direction fromString(String value) {
    switch (value) {
      case 'up': return Direction.up;
      case 'down': return Direction.down;
      case 'left': return Direction.left;
      case 'right': return Direction.right;
      default: return Direction.up;
    }
  }

  /// Returns the offset delta for this direction.
  (int dx, int dy) get delta {
    switch (this) {
      case Direction.up: return (0, -1);
      case Direction.down: return (0, 1);
      case Direction.left: return (-1, 0);
      case Direction.right: return (1, 0);
    }
  }

  /// Returns the rotated direction (90° clockwise).
  Direction get rotatedCW {
    switch (this) {
      case Direction.up: return Direction.right;
      case Direction.right: return Direction.down;
      case Direction.down: return Direction.left;
      case Direction.left: return Direction.up;
    }
  }
}
