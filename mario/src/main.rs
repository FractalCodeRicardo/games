mod sounds;
mod consts;
mod map;
mod sprites;
use std::{cell::{Ref, RefCell}, rc::Rc};

use macroquad::{audio::Sound, prelude::*};
use macroquad_platformer::{Tile, World};

use crate::{consts::{PLAYER_SIZE, TILE_GROUND, TILE_SIZE}, map::MapDrawer, sounds::Sounds, sprites::{Enemy, Player}};


struct Game {
    world: Rc<RefCell<World>>,
    map: MapDrawer,
    camera: Camera2D,
    player: Player,
    enemies: Vec<Enemy>,
    sounds: Sounds
}

impl Game {

    pub async fn new() -> Self {
        let map = MapDrawer::new()
            .await;

        let camera = Game::create_camera(map.px_area());
        let world = World::new();
        let r_world = Rc::new(RefCell::new(world));

        let player = Player::new(r_world.clone())
            .await;

        let sounds = Sounds::new().await;

        let mut game = Game{
            world: r_world.clone(),
            map: map,
            camera: camera,
            player: player,
            enemies: Vec::new(),
            sounds: sounds
        };


        game.add_enemies().await;
        game.load_tiles();

        game.sounds.play_background();
        return game;
    }

    pub fn load_tiles(&self) {
        let tiles = self.map.get_tiles();
        let mut world = self.world.borrow_mut();

        let obstacles:Vec<Tile> = tiles
            .map(|i| {
                if i.2.is_some() {
                    return Tile::Solid;
                }
                return Tile::Empty
            }).collect();

        world.add_static_tiled_layer(
            obstacles, 
            self.map.tile_width(),
            self.map.tile_height(), 
            self.map.width() as usize, 1);

        drop(world);
    }

    pub async fn add_enemies(&mut self) {
        let y = TILE_GROUND * TILE_SIZE - PLAYER_SIZE;
        let world = self.world.clone();

        let mut x = vec![];

        x.push(400.);
        x.push(550.);
        x.push(800.);
        x.push(1400.);
        x.push(1600.);

        for ix in x {
            let position = vec2(ix, y);

            if !world.borrow().solid_at(position) {
                let enemy = Enemy::new(position, self.world.clone())
                .await;
                self.enemies.push(enemy);

            }
        }
    }

    pub fn draw_enemies(&mut self) {
        for e in &mut self.enemies {
            e.draw();
        }
    }

    pub fn create_camera(area: Rect) -> Camera2D {
        let camera_area = Rect::new(
            0.,
            area.h,
            area.w / 7., 
            -area.h);

        let camera = Camera2D::from_display_rect(camera_area);

        return camera;

    }

    pub fn draw(&mut self) {
        set_camera(&self.camera);
        self.follow_camera();
        self.map.draw();
        self.player.draw();
        self.draw_enemies();
        self.handle_enemy_smashed();
    }

    pub fn left(&mut self) {
        self.player.left();
    }

    pub fn right(&mut self) {
        self.player.right();
    }

    pub fn stop(&mut self) {
        self.player.stop();
    }

    pub fn jump(&mut self) {
        self.player.jump();
        self.sounds.play_jump();
    }

    pub fn follow_camera(&mut self) {
        let height = self.map.px_height() / 2.;
        let pos = self.player.pos();

        self.camera.target = Vec2 {
            x: pos.x + 200.,
            y: height - 30. 
        }
    }

   pub fn handle_enemy_smashed(&mut self)  {
       let enemy = self.get_enemy_smashed();

       if enemy.is_some() {
           self.enemies.remove(enemy.unwrap());
       }
   }

   pub fn get_enemy_smashed(&self) -> Option<usize> {
       let pp = self.player.bottom_center();

       for i in 0..self.enemies.len() {
           let e = &self.enemies[i];
           let e_area = e.area();

           if e_area.contains(pp) {
               return Some(i);
           }
       }

       None
   }

}

#[macroquad::main("MyGame")]
async fn main() {
    let mut game = Game::new().await;
    loop {

        clear_background(Color {
            r: 93. / 255.,
            g: 148. / 255.,
            b: 252. / 255.,
            a: 255. / 255.,
        });

        let mut is_moving = false;
        if is_key_down(KeyCode::Left) {
            game.left();
            is_moving = true;
        }

        if is_key_down(KeyCode::Right) {
            game.right();
            is_moving = true;
        }

        if is_key_pressed(KeyCode::Space) {
            game.jump();
        }

        if !is_moving {
            game.stop();
        }

        game.draw();

        next_frame().await
    }
}
