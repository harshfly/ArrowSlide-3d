/// Represents a power-up placed on the grid.
class PowerUp {
  final PowerUpType type;
  final int x;
  final int y;
  final Map<String, dynamic> metadata;
  final bool isActive;

  const PowerUp({
    required this.type,
    required this.x,
    required this.y,
    this.metadata = const {},
    this.isActive = true,
  });

  factory PowerUp.fromJson(Map<String, dynamic> json) {
    return PowerUp(
      type: PowerUpType.fromString(json['type'] as String),
      x: json['x'] as int,
      y: json['y'] as int,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'x': x,
        'y': y,
        if (metadata.isNotEmpty) 'metadata': metadata,
      };

  PowerUp copyWith({PowerUpType? type, int? x, int? y, Map<String, dynamic>? metadata, bool? isActive}) {
    return PowerUp(
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
    );
  }
}

enum PowerUpType {
  teleporter,
  iceTile,
  lock,
  key,
  movingObstacle,
  switchToggle,
  portal,
  oneWayGate;

  static PowerUpType fromString(String value) {
    switch (value) {
      case 'teleporter': return PowerUpType.teleporter;
      case 'iceTile': return PowerUpType.iceTile;
      case 'lock': return PowerUpType.lock;
      case 'key': return PowerUpType.key;
      case 'movingObstacle': return PowerUpType.movingObstacle;
      case 'switch': return PowerUpType.switchToggle;
      case 'portal': return PowerUpType.portal;
      case 'oneWayGate': return PowerUpType.oneWayGate;
      default: return PowerUpType.teleporter;
    }
  }
}
