mod consts;
mod images;
mod components;

use std::rc::Rc;

use macroquad::{prelude::*, rand::RandomRange};

use crate::{components::{Cactus, Desert, Dinosaur}, consts::{CACTUS_EVERY, CACTUS_HEIGHT}, images::Images};

#[macroquad::main("MyGame")]
async fn main() {
    let mut game = Game::new().await;
    loop {
        clear_background(RED);

        if is_key_pressed(KeyCode::Space) {
            game.jump();
        }

        game.draw();

        next_frame().await
    }
}

struct Game {
    images: Images,
    desert: Desert,
    dinosaur: Dinosaur,
    cactus: Vec<Cactus>,
    cactus_every: usize,
    last_cactus: usize,
    game_over: bool
}

impl Game {

    async fn new() -> Self {
        let images = Images::new().await;
        
        let mut game = Game {
            desert: Desert::new(images.get_desert()),
            dinosaur: Dinosaur::new(images.get_dinosaurs()),
            cactus: Vec::new(),
            images: images,
            cactus_every: CACTUS_EVERY[0],
            last_cactus: 0,
            game_over: false
        };

        game.add_cactus();

        return game;
    }

    fn draw(&mut self) {

        if self.game_over {
            self.desert.draw();
            Game::show_game_over();
            return;
        }

        self.desert.draw();
        self.dinosaur.draw();
        self.draw_cactus();
        self.add_cactus_condition();
        self.handle_crash();
    }

    fn draw_cactus(&mut self) {
        for c in &mut self.cactus {
            c.draw();
        }
    }

    fn add_cactus(&mut self) {
        let image = self.images.get_cactus();
        let cactus = Cactus::new(image);
        self.cactus.push(cactus);
    }

    fn add_cactus_condition(&mut self) {
        if self.last_cactus >= self.cactus_every {
            self.last_cactus = 0;
            let index = RandomRange::gen_range(0, CACTUS_EVERY.len());
            self.cactus_every = CACTUS_EVERY[index];
            self.add_cactus();
        }

        self.last_cactus += 1;
    }

    fn jump(&mut self) {
       self.dinosaur.jump(); 
    }

    fn handle_crash(&mut self) {
        if self.is_crash() {
            self.game_over = true;
        }
    }

    fn show_game_over() {
        draw_text("GAME OVER", screen_width() / 2. - 100., screen_height() / 2. -100., 40., MAGENTA);
    }

    fn is_crash(&self) -> bool {
        let vertices = self.dinosaur.get_vertices();
        for c in &self.cactus {
            for v in &vertices {
                if c.overlaps(&v) {
                    return true;
                }
            }
        }
        return false;
    }
}
    
