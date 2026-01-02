use macroquad::file::load_string;
use macroquad::math::Rect;
use macroquad::texture::load_texture;
use macroquad_tiled::{Map, TilesIterator};
use macroquad_tiled as tiled;

use crate::sprites::Player;

pub struct MapDrawer {
    map: Map
}

impl MapDrawer {

    pub async fn new() -> Self {
        let json = load_string("./assets/map.json")
            .await
            .unwrap();

        let texture = load_texture("./assets/tileset.png")
            .await
            .unwrap();

        let param_texture = ( "tileset.png", texture);

        let map = tiled::load_map(
            &json, 
            &[param_texture], 
            &[])
            .unwrap();

        MapDrawer {
            map: map,
        }

    }

    pub fn draw(&self) {
        let area = self.px_area();
        self.map.draw_tiles("ground", area, None);
        self.map.draw_tiles("background", area, None);
    }
 
    pub fn px_width(&self) -> f32{
        let tile = &self.map.raw_tiled_map;
        return (tile.tilewidth * tile.width) as f32;
    }

    pub fn px_height(&self) -> f32{
        let tile = &self.map.raw_tiled_map;
        return (tile.tileheight * tile.height) as f32;
    }

    pub fn tile_height(&self) -> f32{
        let tile = &self.map.raw_tiled_map;
        return tile.tileheight as f32; 
    }

    pub fn tile_width(&self) -> f32{
        let tile = &self.map.raw_tiled_map;
        return tile.tilewidth as f32; 
    }

    pub fn width(&self) -> f32{
        let tile = &self.map.raw_tiled_map;
        return tile.width as f32; 
    }

    pub fn px_area(&self) -> Rect {
        return Rect::new(0., 0., self.px_width(), self.px_height())
    }

    pub fn get_tiles(&self) -> TilesIterator {
        self.map.tiles("ground", None)
    }
}
