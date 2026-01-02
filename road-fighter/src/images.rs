use std::rc::Rc;

use macroquad::{rand::RandomRange, texture::{load_texture, Texture2D}};

 pub struct Images {
     road: Rc<Texture2D>,
     player: Rc<Texture2D>,
     enemies: Vec<Rc<Texture2D>>
 }

impl Images {

    pub async fn new() -> Self {
        let enemies_files = vec!["enemy1.png", "enemy2.png", "enemy3.png"];
        let mut enemies: Vec<Rc<Texture2D>> =Vec::new();

        for ef in enemies_files {
            let path = "./assets/images/".to_string() + ef;
            let texture = load_texture(&path).await.unwrap();
            enemies.push(Rc::new(texture));
        }

        let road = load_texture("./assets/images/road.png")
            .await
            .unwrap();

        let player = load_texture("./assets/images/red-car.png")
            .await
            .unwrap();

        Images {
            road: Rc::new(road),
            player: Rc::new(player),
            enemies: enemies
        }
    }

    pub fn get_road(&self) -> Rc<Texture2D> {
        return self.road.clone();
    }

    pub fn get_player(&self) -> Rc<Texture2D> {
        return self.player.clone();
    }

    pub fn get_enemy(&self) -> Rc<Texture2D>{
        let index = RandomRange::gen_range(0, self.enemies.len());
        let texture = &self.enemies[index];
        return texture.clone();
    }

}
