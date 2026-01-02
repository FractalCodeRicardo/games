use crate::constants::*;
use std::{collections::HashMap, rc::Rc};
use macroquad::{color::WHITE, math::Vec2, rand::RandomRange, texture::{draw_texture_ex, load_texture, DrawTextureParams, Texture2D}, window::{screen_height, screen_width}};


pub struct ImageHandler {
    images: HashMap<String, Rc<Texture2D>>,
}

impl ImageHandler {
    pub fn new() -> Self {
        ImageHandler {
            images: HashMap::new(),
        }
    }

    fn get_enemies_names() -> Vec<String> {
        let enemies = ENEMIES_IMAGES
            .split(",")
            .map(|i| i.to_string())
            .collect();

        return enemies;
    }

    fn get_all_names() -> Vec<String> {
        let mut names = ImageHandler::get_enemies_names();
        names.push(PLAYER_IMAGE.to_string());
        names.push(BULLET_IMAGE.to_string());
        names.push(BG_IMAGE.to_string());
        return names;
    }

    pub async fn load_images(&mut self) {
        let names = ImageHandler::get_all_names();
        for img in &names {
            let path = "./assets/".to_string() + img;
            let picture = load_texture(&path).await.unwrap();
            let rc_picture = Rc::new(picture);

            self.images.insert(img.to_string(), rc_picture);
        }
    }

    pub fn get_image_player(&self) -> Rc<Texture2D> {
        return self.images[PLAYER_IMAGE].clone();
    }

    pub fn get_image_bullet(&self) -> Rc<Texture2D> {
        return self.images[BULLET_IMAGE].clone();
    }

    pub fn get_image_enemy(&self) -> Rc<Texture2D> {
        let enemy_names = ImageHandler::get_enemies_names();
        let image_index = RandomRange::gen_range(0, enemy_names.len());
        let image_name = enemy_names[image_index].to_string();
        return self.images[&image_name].clone();
    }

    pub fn set_background(&self) {
        let picture= &self.images[BG_IMAGE];
        draw_texture_ex(
            picture,
            0.,
            0.,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(screen_width(), screen_height())),
                ..Default::default()
            },
        );
    }
}
