use std::{cell::RefCell, rc::Rc};

use macroquad::{
    color::WHITE,
    math::{Rect, Vec2, vec2},
    texture::{DrawTextureParams, Texture2D, draw_texture_ex, load_texture},
    time::{get_frame_time, get_time},
};
use macroquad_platformer::{Actor, World};

use crate::consts::{
    FRAME_EVERY, GRAVITY, JUMP, PLAYER_SIZE, PLAYER_SPEED, SPEED_ENEMY, TILE_GROUND, TILE_SIZE
};

pub struct Player {
    world: Rc<RefCell<World>>,
    actor: Actor,
    texture: Texture2D,
    speed: Vec2,
    frame: usize,
    frame_time: f32,
}

impl Player {
    pub async fn new(world: Rc<RefCell<World>>) -> Self {
        let texture = load_texture("./assets/sprite-running.png").await.unwrap();

        let init_pos = vec2(10., TILE_GROUND * TILE_SIZE - PLAYER_SIZE);

        let actor = world
            .borrow_mut()
            .add_actor(init_pos, PLAYER_SIZE as i32, PLAYER_SIZE as i32);

        Player {
            world: world,
            actor: actor,
            texture: texture,
            speed: vec2(0., 0.),
            frame: 0,
            frame_time: 0.,
        }
    }

    pub fn draw(&mut self) {
        let area = Rect::new(
            self.frame as f32 * (PLAYER_SIZE + 2.),
            0.,
            PLAYER_SIZE,
            PLAYER_SIZE,
        );

        let pos = self.pos();

        draw_texture_ex(
            &self.texture,
            pos.x,
            pos.y,
            WHITE,
            DrawTextureParams {
                source: Some(area),
                ..Default::default()
            },
        );

        self.mov();
        self.mov_gravity();
        self.change_frame();
    }

    pub fn change_frame(&mut self) {
        if self.speed.x == 0. {
            self.frame = 0;
            return;
        }

        if self.frame_time < FRAME_EVERY {
            self.frame_time += get_frame_time();
            return;
        }

        self.frame_time = 0.;
        self.frame += 1;

        if self.frame >= 4 {
            self.frame = 0;
        }
    }

    pub fn pos(&self) -> Vec2 {
        let world = self.world.borrow();

        world.actor_pos(self.actor)
    }

    pub fn right(&mut self) {
        self.speed.x = PLAYER_SPEED;
    }

    pub fn left(&mut self) {
        self.speed.x = -PLAYER_SPEED;
    }

    pub fn stop(&mut self) {
        self.speed.x = 0.;
    }

    pub fn jump(&mut self) {
        if self.speed.y == 0. {
            self.speed.y = -JUMP;
        }
    }

    pub fn mov(&mut self) {
        let dx = self.speed.x * get_frame_time();
        let dy = self.speed.y * get_frame_time();

        let mut world = self.world.borrow_mut();

        world.move_v(self.actor, dy);
        world.move_h(self.actor, dx);
    }

    pub fn mov_gravity(&mut self) {
        if self.is_on_ground() {
            self.speed.y = 0.;
            return;
        }

        self.speed.y += GRAVITY * get_frame_time();
    }

    pub fn is_on_ground(&self) -> bool {
        let world = self.world.borrow();
        let pos = self.pos();
        let bottom = vec2(pos.x, pos.y + PLAYER_SIZE + 1.);

        world.solid_at(bottom)
    }

    pub fn bottom_center(&self) -> Vec2 {
        let pos = self.pos();

        Vec2 {
            x: pos.x + PLAYER_SIZE / 2.,
            y: pos.y + PLAYER_SIZE
        }
    }
}

pub struct Enemy {
    world: Rc<RefCell<World>>,
    actor: Actor,
    texture: Texture2D,
    speed: Vec2,
}

impl Enemy {
    
    pub async fn new(pos: Vec2, world: Rc<RefCell<World>>) -> Self {
        let texture = load_texture("./assets/enemies.png")
            .await
            .unwrap();


        let actor = world
            .borrow_mut()
            .add_actor(pos, PLAYER_SIZE as i32, PLAYER_SIZE as i32);

        Enemy {
            world: world,
            actor: actor,
            texture: texture,
            speed: vec2(-SPEED_ENEMY, 0.)
        }
    }


    pub fn mov(&mut self) {
        let dx = self.speed.x * get_frame_time();
        let dy = self.speed.y * get_frame_time();

        let mut world = self.world.borrow_mut();

        world.move_v(self.actor, dy);
        world.move_h(self.actor, dx);

        
    }

    pub fn mov_gravity(&mut self) {
        if self.is_on_ground() {
            self.speed.y = 0.;
            return;
        }

        self.speed.y += GRAVITY * get_frame_time();
    }

    pub fn is_on_ground(&self) -> bool {
        let world = self.world.borrow();
        let pos = self.pos();
        let bottom = vec2(pos.x, pos.y + PLAYER_SIZE + 1.);

        world.solid_at(bottom)
    }


    pub fn draw(&mut self) {
        let area = Rect::new(
            0.,
            0.,
            PLAYER_SIZE,
            PLAYER_SIZE,
        );

        let pos = self.pos();

        draw_texture_ex(
            &self.texture,
            pos.x,
            pos.y,
            WHITE,
            DrawTextureParams {
                source: Some(area),
                ..Default::default()
            },
        );

        self.mov();
        self.mov_gravity();


        if self.h_collition() {
            self.speed.x *= -1.;
        }

    }

    pub fn pos(&self) -> Vec2 {
        let world = self.world.borrow();

        world.actor_pos(self.actor)
    }

    pub fn area(&self) -> Rect {
        let pos = self.pos();
        Rect {
            x: pos.x,
            y: pos.y,
            w: PLAYER_SIZE,
            h: PLAYER_SIZE,
        }
    }

    pub fn h_collition(&self)-> bool {
        let world = self.world.borrow();
        let pos = self .pos();
        let right = pos + vec2(1. + PLAYER_SIZE , 0.);
        let left = pos + vec2(-1. , 0.);

        if world.solid_at(right) {
            return true;
        }

        if world.solid_at(left) {
            return true;
        }

        return false;

    }

}
