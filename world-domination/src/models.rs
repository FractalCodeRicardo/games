
use crate::constants::*;
use std::{rc::Rc};

use macroquad::{color::WHITE, math::Vec2, prelude::coroutines::tweens::linear, rand::RandomRange, texture::{draw_texture_ex, load_texture, DrawTextureParams, Texture2D}, window::{screen_height, screen_width}};

pub struct Position {
    pub x: f32,
    pub y: f32,
}

pub struct GameObject {
    pub id: String,
    pub picture: Rc<Texture2D>,
    pub pos: Position,
}

impl GameObject {
    pub fn draw(&self) {
        draw_texture_ex(
            &self.picture,
            self.pos.x,
            self.pos.y,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(PLAYER_SIZE, PLAYER_SIZE)),
                ..Default::default()
            },
        );
    }

    pub fn mov_down(&mut self, step: f32) {
        self.pos = Position {
            x: self.pos.x,
            y: self.pos.y + step,
        }
    }

    pub fn mov_up(&mut self, step: f32) {
        self.pos = Position {
            x: self.pos.x,
            y: self.pos.y - step,
        }
    }

    pub fn mov_left(&mut self, step: f32) {
        self.pos = Position {
            x: self.pos.x - step ,
            y: self.pos.y,
        }
    }

    pub fn mov_right(&mut self, step: f32) {
        self.pos = Position {
            x: self.pos.x + step ,
            y: self.pos.y,
        }
    }

    pub fn print(&self, label: &str) {
        println!("{} {} {}", label, self.pos.x, self.pos.y);
    }
}
