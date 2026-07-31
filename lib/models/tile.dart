/// Represents a single tile in the puzzle grid.
///
/// Each tile has a position and a type that determines how blocks
/// interact with it (e.g., walls block movement, ice causes sliding).
class Tile {
  final int x;
  final int y;
  final TileType type;
  final Map<String, dynamic> metadata;

  const Tile({
    required this.x,
    required this.y,
    required this.type,
    this.metadata = const {},
  });

  factory Tile.fromJson(Map<String, dynamic> json) {
    return Tile(
      x: json['x'] as int,
      y: json['y'] as int,
      type: TileType.fromString(json['type'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'type': type.name,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  Tile copyWith({int? x, int? y, TileType? type, Map<String, dynamic>? metadata}) {
    return Tile(
      x: x ?? this.x,
      y: y ?? this.y,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Types of tiles in the puzzle grid.
enum TileType {
  empty,
  floor,
  wall,
  ice,
  teleporter,
  portal,
  oneWayGate,
  switchTile,
  lock,
  exit;

  static TileType fromString(String value) {
    switch (value) {
      case 'empty': return TileType.empty;
      case 'floor': return TileType.floor;
      case 'wall': return TileType.wall;
      case 'ice': return TileType.ice;
      case 'teleporter': return TileType.teleporter;
      case 'portal': return TileType.portal;
      case 'oneWayGate': return TileType.oneWayGate;
      case 'switch': return TileType.switchTile;
      case 'lock': return TileType.lock;
      case 'exit': return TileType.exit;
      default: return TileType.floor;
    }
  }
}
