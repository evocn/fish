// Dayne
// Game
// August 2024

Level :: struct {
    // State
    using grid : struct {
        width   :: 14;
        height  :: 8;

        tiles : [height * width] Tile;
    }

    pixel_extents :: Collider.{
        width  = grid.width *  TILE_SIZE_IN_PIXELS,
        height = grid.height * TILE_SIZE_IN_PIXELS,
        x = 0,
        y = 0,
    };
}
