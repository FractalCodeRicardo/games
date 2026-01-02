use macroquad::{
    color::WHITE, file::load_string, math::{vec2, Rect}, texture::{draw_texture, draw_texture_ex, load_texture, DrawTextureParams, Texture2D}
};
use macroquad_tiled::{self as tiled, Map, TilesIterator};

pub struct MapDrawer {
    map: Map,
    background: Texture2D,
}

impl MapDrawer {
    pub async fn new() -> Self {
        let background = load_texture("./assets/background.png")
            .await
            .unwrap();

        let json_map = load_string("./assets/map.json")
            .await
            .unwrap();

        let texture_tile = load_texture("./assets/tiles.png")
            .await
            .unwrap();
        
        let texture_param = ("tiles.png", texture_tile);

        let map = tiled::load_map(
            &json_map, 
            &[texture_param], 
            &[])
            .unwrap();


        MapDrawer { 
            map: map,
            background: background 
        }
    }

    pub fn draw(&self) {
        draw_texture_ex(
            &self.background,
            0.,
            0.,
            WHITE,
            DrawTextureParams {
                dest_size: Some(vec2(self.background.width(), self.background.height())),
                ..Default::default()
            },
        );

        let width = self.px_width();
        let height = self.px_height();

        let area = Rect::new(0., 0., width, height);
        self.map.draw_tiles("obstacles", area, None);
    }


    pub fn px_width(&self) -> f32 {
        let width = self.map.raw_tiled_map.width * 
            self.map.raw_tiled_map.tilewidth;

        return width as f32;
    }

    pub fn px_height(&self) -> f32 {
        let height = self.map.raw_tiled_map.height * 
            self.map.raw_tiled_map.tileheight;

        return height as f32;
    }

    pub fn get_tiles(&self) -> TilesIterator {
        self.map.tiles("obstacles", None)
    }

    pub fn tile_width(&self) -> f32 {
        return self.map.raw_tiled_map.tilewidth as f32;
    }

    pub fn tile_height(&self) -> f32 {
        return self.map.raw_tiled_map.tileheight as f32;
    }

    pub fn width(&self) -> f32 {
        return self.map.raw_tiled_map.width as f32;
    }
}
