use macroquad::miniquad::native::linux_x11::libx11::EnterWindowMask;
use macroquad::{prelude::*, rand::RandomRange};
use std::{collections::HashMap, rc::Rc};

mod constants;
mod models;
mod image;
mod audio;

use models::GameObject;
use image::ImageHandler;
use audio::AudioHandler;
use models::Position;
use uuid::Uuid;
use constants::*;

struct Domination {
    enemies: Vec<GameObject>,
    player: GameObject,
    bullets: Vec<GameObject>,
    image_handler: Rc<ImageHandler>,
    audio_handler: Rc<AudioHandler>,
    last_enemy: usize,
    score: usize
}

impl Domination {
    fn new(
        image_handler: Rc<ImageHandler>,
        audio_handler: Rc<AudioHandler>
    ) -> Self {
        Domination {
            enemies: Vec::new(),
            bullets: Vec::new(),
            player: Domination::create_player(&image_handler),
            audio_handler: audio_handler,
            image_handler: image_handler,
            last_enemy: 0,
            score: 0
        }
    }

    fn create_player(image_handler: &ImageHandler) -> GameObject {
        let x = screen_width() / 2.;
        let y = screen_height() - 100.;
        let image = image_handler.get_image_player();

        return GameObject {
            id: Uuid::new_v4().to_string(),
            picture: image,
            pos: Position { x: x, y: y },
        };
    }

    fn mov(&mut self) {
        self.mov_enemies();
        self.add_enemy_conditional();
        self.mov_bullets();
        self.handle_crash();
        self.last_enemy += 1;
    }

    fn mov_enemies(&mut self) {
        for e in &mut self.enemies {
            e.mov_down(ENEMY_STEP);
        }
    }

    fn add_enemy_conditional(&mut self) {
        if self.last_enemy < ENEMY_EVERY {
            return;
        }

        self.add_enemy();
        self.last_enemy = 0;
    }

    fn add_enemy(&mut self) {
        let enemy = self.create_enemy();
        self.enemies.push(enemy);
    }

    fn create_enemy(&self) -> GameObject {
        let x = RandomRange::gen_range(0., screen_width());
        let y = 10.;
        let image = self.image_handler.get_image_enemy();

        return GameObject {
            id: Uuid::new_v4().to_string(),
            picture: image,
            pos: Position { x: x, y: y },
        };
    }

    fn add_bullet(&mut self) {
        let bullet = self.create_bullet();
        self.bullets.push(bullet);
    }

    fn create_bullet(&self) -> GameObject {
        let x = self.player.pos.x;
        let y = self.player.pos.y - 50.;
        let image = self.image_handler.get_image_bullet();

        return GameObject {
            id: Uuid::new_v4().to_string(),
            picture: image,
            pos: Position { x: x, y: y },
        };
    }

    fn mov_bullets(&mut self) {
        for b in &mut self.bullets {
            b.mov_up(BULLET_STEP);
        }
    }

    fn draw_player(&self) {
        self.player.draw();
    }

    fn draw_enemies(&self) {
        for e in &self.enemies {
            e.draw();
        }
    }

    fn draw_bullets(&self) {
        for b in &self.bullets {
            b.draw();
        }
    }

    fn draw(&self) {
        self.draw_background();
        self.draw_player();
        self.draw_enemies();
        self.draw_bullets();
        self.draw_score();
    }

    fn draw_background(&self) {
        self.image_handler.set_background();
    }

    fn left(&mut self) {
        self.player.mov_left(PLAYER_STEP);
    }

    fn right(&mut self) {
        self.player.mov_right(PLAYER_STEP);
    }

    fn shot(&mut self) {
        self.add_bullet();
        self.audio_handler.play_shoot();
    }

    fn is_crash(enemy: &GameObject, bullet: &GameObject) -> bool {
       let size = PLAYER_SIZE;

        if enemy.pos.y + size < bullet.pos.y {
            return false;
        }

       let enemy_r = enemy.pos.x + size;
       let enemy_l = enemy.pos.x;

       let bullet_r = bullet.pos.x + size;
       let bullet_l = bullet.pos.x;

      if enemy_l < bullet_l && enemy_r >= bullet_l {
          return true;
      } 

      if bullet_l < enemy_l &&  bullet_r >= enemy_l {
          return true;
      } 
       return false;

    }

    fn handle_crash(&mut self) {
        let mut enemies: Vec<String> = Vec::new();
        let mut bullets: Vec<String> = Vec::new();

        for e in &self.enemies {
            for b in &self.bullets {
                if Domination::is_crash(e, b) {
                    enemies.push(e.id.clone());
                    bullets.push(b.id.clone());
                }
            }
        }

        if enemies.len() > 0 {
            self.audio_handler.play_explosion();
        }

        self.score += enemies.len();
        self.remove_enemies(&enemies);
        self.remove_bullets(&bullets);
    }

    fn remove_enemies(&mut self, enemies: &Vec<String>) {
        self.enemies = self
            .enemies
            .drain(..) // take ownership of all elements
            .filter(|i| !enemies.contains(&i.id))
            .collect();
    }

    fn remove_bullets(&mut self, bullets: &Vec<String>){
        self.bullets = self
            .bullets
            .drain(..) // take ownership of all elements
            .filter(|i| !bullets.contains(&i.id))
            .collect();
    }

    fn draw_score(&self) {
        let text = format!("Score: {}", self.score.to_string());
        draw_text(&text, 0., screen_height() -50.,35., BLUE);
    }
}

#[macroquad::main("World domination")]
async fn main() {
    let mut time = get_time();
    let mut game = init_game().await;

    loop {
        clear_background(BLACK);
        draw(&game);
        events(&mut game);

        if get_time() - time > DELAY {
            time = get_time();
            mov(&mut game);
        }

        next_frame().await
    }
}

async fn init_game() -> Domination {
    let mut images = ImageHandler::new();
    images.load_images().await;

    let audio = AudioHandler::new().await;
    audio.play_background();

    let mut game = Domination::new(
        Rc::new(images), 
        Rc::new(audio)
    );

    game.add_enemy();

    return game;
}

fn draw(game: &Domination) {
    game.draw();
}

fn mov(game: &mut Domination) {
    game.mov();
}

fn events(game: &mut Domination) {
    if is_key_down(KeyCode::H) {
        game.left();
    }

    if is_key_down(KeyCode::L) {
        game.right();
    }

    if is_key_pressed(KeyCode::Enter) {
        game.shot();
    }
}
