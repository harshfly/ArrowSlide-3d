import 'tile.dart';
import 'arrow_block.dart';
import 'power_up.dart';

/// Represents a complete puzzle level configuration.
class Level {
  final int id;
  final int gridWidth;
  final int gridHeight;
  final int parMoves;
  final int timeLimitSeconds;
  final int threeStarSec; // Complete within this many seconds → 3 stars
  final int twoStarSec; // Complete within this many seconds → 2 stars
  final String difficulty;
  final List<Tile> tiles;
  final List<ArrowBlock> blocks;
  final List<PowerUp> powerUps;

  const Level({
    required this.id,
    required this.gridWidth,
    required this.gridHeight,
    required this.parMoves,
    this.timeLimitSeconds = 120,
    this.threeStarSec = 15,
    this.twoStarSec = 30,
    required this.difficulty,
    required this.tiles,
    required this.blocks,
    this.powerUps = const [],
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as int,
      gridWidth: json['gridWidth'] as int,
      gridHeight: json['gridHeight'] as int,
      parMoves: json['parMoves'] as int,
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 120,
      threeStarSec: json['threeStarSec'] as int? ?? 15,
      twoStarSec: json['twoStarSec'] as int? ?? 30,
      difficulty: json['difficulty'] as String? ?? 'easy',
      tiles: (json['tiles'] as List<dynamic>)
          .map((t) => Tile.fromJson(t as Map<String, dynamic>))
          .toList(),
      blocks: (json['blocks'] as List<dynamic>)
          .map((b) => ArrowBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
      powerUps:
          (json['powerUps'] as List<dynamic>?)
              ?.map((p) => PowerUp.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gridWidth': gridWidth,
    'gridHeight': gridHeight,
    'parMoves': parMoves,
    'timeLimitSeconds': timeLimitSeconds,
    'threeStarSec': threeStarSec,
    'twoStarSec': twoStarSec,
    'difficulty': difficulty,
    'tiles': tiles.map((t) => t.toJson()).toList(),
    'blocks': blocks.map((b) => b.toJson()).toList(),
    'powerUps': powerUps.map((p) => p.toJson()).toList(),
  };

  List<Tile> get exitTiles =>
      tiles.where((t) => t.type == TileType.exit).toList();

  ArrowBlock? get playerBlock {
    try {
      return blocks.firstWhere((b) => b.isPlayer);
    } catch (_) {
      return blocks.isNotEmpty ? blocks.first : null;
    }
  }
}
