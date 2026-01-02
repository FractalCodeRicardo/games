mod consts;
mod images;
mod models;
mod audio;

use macroquad::prelude::*;

use crate::{audio::Audio, consts::{ADD_ENEMY_EVERY, CAR_SIZE, ROAD_BORDE}, images::Images, models::{Enemy, Player, Road}};

struct Game {
    road: Road,
    player: Player,
    enemies: Vec<Enemy>,
    images: Images,
    audio: Audio,
    last_enemy: usize,
    is_game_over: bool
}

impl Game {

    async fn new() -> Self {
        let images = Images::new().await;
        let mut game = Game {
            road: Road::new(images.get_road()),
            player: Player::new(images.get_player()),
            enemies: Vec::new(),
            images: images,
            last_enemy: 0,
            is_game_over: false,
            audio: Audio::new().await
        };

        game.add_enemy();
        game.audio.play_background();

        return game;
    }

    fn add_enemy(&mut self) {
        let image = self.images.get_enemy();
        let enemy = Enemy::new(image);
        
        self.enemies.push(enemy);
    }

    fn add_enemy_conditional(&mut self) {
        if self.last_enemy > ADD_ENEMY_EVERY {
            self.last_enemy = 0;
            self.add_enemy();
            return;
        }

        self.last_enemy += 1;
    }

    fn draw_enemies(&mut self) {
        for e in &mut self.enemies {
            e.draw();
        }

    }

    fn draw(&mut self) {
        if self.is_game_over {
            Game::show_game_over();
            return;
        }

        self.handle_road_crash();
        self.handle_car_crash();
        self.add_enemy_conditional();
        self.road.draw();
        self.player.draw();
        self.draw_enemies();
    }

    fn left(&mut self) {
        self.player.left();
    }

    fn right(&mut self) {
        self.player.right();
    }

    fn is_road_crash(&self) -> bool {

        if self.player.pos.x <= ROAD_BORDE {
            return true;
        }

        if self.player.pos.x + CAR_SIZE >= screen_width() - ROAD_BORDE {
            return true;
        }

        return false;
    }

    fn is_car_crash(&self) -> bool {

        for e in &self.enemies {

            let p1 = self.player.top_left();
            let p2 = self.player.top_right();

            if e.overlaps(&p1) {
                println!("P1 {} {} {} {}", e.pos.x, e.pos.y, p1.x, p1.y );
                return true;
            }

            if e.overlaps(&p2) {
                println!("P2 {} {} {} {}", e.pos.x, e.pos.y, p1.x, p1.y );
                return true;
            }
        }

        return false;

    }


    fn handle_car_crash(&mut self) {
        if self.is_car_crash() {
            self.audio.play_explosion();
            self.is_game_over = true;
        }
    }

    fn handle_road_crash(&mut self) {
        if self.is_road_crash() {
            self.audio.play_explosion();
            self.is_game_over = true;
        }
    }

    fn show_game_over() {
        draw_text("GAME OVER", screen_width() / 2. - 100. ,screen_height() / 2. , 40., MAGENTA);
    }

}

#[macroquad::main("MyGame")]
async fn main() {
    let mut game = Game::new().await;
    loop {
        clear_background(BLACK);

        events(&mut game);
        game.draw();

        next_frame().await
    }
}

fn events(game: &mut Game) {

    if is_key_down(KeyCode::L) {
        game.right();
    }

    if is_key_down(KeyCode::H) {
        game.left();
    }
}
      
