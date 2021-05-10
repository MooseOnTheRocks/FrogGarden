static final int TILE_SIZE = 4; // In units of PIXEL_SIZE
static PImage[] TILES_DIRT;
static PImage[] TILES_GRASS;
static PImage[] TILES_GRASS_DARK;
static PImage[] TILES_STONE;

enum TileType {
    EMPTY(null),
    DIRT(TILES_DIRT),
    GRASS(TILES_GRASS),
    GRASS_DARK(TILES_GRASS_DARK),
    STONE(TILES_STONE);
    
    final PImage[] alternatives;
    private TileType(PImage[] alternatives) {
        this.alternatives = alternatives;
    }
}
