use std::rc::Rc;

use macroquad::{
    color::WHITE,
    math::Vec2,
    rand::RandomRange,
    texture::{DrawTextureParams, Texture2D, draw_texture_ex},
    window::{screen_height, screen_width},
};

use crate::consts::{CAR_SIZE, ENEMY_SPEED, PLAYER_SPEED, ROAD_BORDE, ROAD_SIZE, ROAD_SPEED};

pub struct Position {
    pub x: f32,
    pub y: f32,
}

pub struct Road {
    image: Rc<Texture2D>,
    y1: f32,
    y2: f32,
}

impl Road {
    pub fn new(image: Rc<Texture2D>) -> Self {
        Road {
            image: image,
            y2: 0.,
            y1: screen_height() * -1.,
        }
    }

    pub fn draw(&mut self) {
        draw_texture_ex(
            &self.image,
            screen_width() / 2. - ROAD_SIZE / 2.,
            self.y1,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(ROAD_SIZE, screen_height())),
                ..Default::default()
            },
        );

        draw_texture_ex(
            &self.image,
            screen_width() / 2. - ROAD_SIZE / 2.,
            self.y2,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(ROAD_SIZE, screen_height())),
                ..Default::default()
            },
        );

        if self.y2 >= screen_height() {
            self.y2 = 0.;
        } else {
            self.y2 += ROAD_SPEED;
        }

        self.y1 = (screen_height() - self.y2) * -1.;
    }
}

pub struct Player {
    image: Rc<Texture2D>,
    pub pos: Position,
}

impl Player {
    pub fn new(image: Rc<Texture2D>) -> Self {
        let pos = Position {
            x: screen_width() / 2.,
            y: screen_height() - 150.,
        };

        Player {
            pos: pos,
            image: image,
        }
    }

    pub fn draw(&self) {
        draw_texture_ex(
            &self.image,
            self.pos.x,
            self.pos.y,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(CAR_SIZE, CAR_SIZE)),
                ..Default::default()
            },
        );
    }

    pub fn left(&mut self) {
        self.pos = Position {
            x: self.pos.x - PLAYER_SPEED,
            y: self.pos.y,
        }
    }

    pub fn right(&mut self) {
        self.pos = Position {
            x: self.pos.x + PLAYER_SPEED,
            y: self.pos.y,
        }
    }

    pub fn top_left(&self) -> Position {
        Position {
            x: self.pos.x,
            y: self.pos.y
        }
    }

    pub fn top_right(&self) -> Position {
        Position {
            x: self.pos.x + CAR_SIZE,
            y: self.pos.y
        }
    }
}

pub struct Enemy {
    image: Rc<Texture2D>,
    pub pos: Position,
}

impl Enemy {
    pub fn new(image: Rc<Texture2D>) -> Self {
        let pos = Position {
            x: RandomRange::gen_range(ROAD_BORDE, screen_width() - ROAD_BORDE - CAR_SIZE),
            y: 10.,
        };

        Enemy {
            pos: pos,
            image: image,
        }
    }

    pub fn draw(&mut self) {
        draw_texture_ex(
            &self.image,
            self.pos.x,
            self.pos.y,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(CAR_SIZE, CAR_SIZE)),
                ..Default::default()
            },
        );

        self.pos = Position {
            x: self.pos.x,
            y: self.pos.y + ENEMY_SPEED,
        }
    }

    pub fn overlaps(&self, pos: &Position) -> bool {
        let horizontal_overlap = self.pos.x <= pos.x && pos.x <= self.pos.x + CAR_SIZE;
        let vertical_overlap = self.pos.y <= pos.y && pos.y <= self.pos.y + CAR_SIZE;

        return vertical_overlap && horizontal_overlap;
    }
}
