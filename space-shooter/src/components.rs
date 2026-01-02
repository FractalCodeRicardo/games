use std::{rc::Rc, sync::mpsc::TryRecvError};

use macroquad::{
    color::{RED, WHITE, YELLOW}, math::{vec2, Vec2}, shapes::draw_rectangle, text::{draw_text, draw_text_ex}, texture::{draw_texture_ex, DrawTextureParams, Texture2D}, window::{screen_height, screen_width}
};

use crate::consts::{BG_SPEED, BULLET_SIZE, BULLET_SPEED, ENEMY_HEIGHT, ENEMY_SPEED, ENEMY_WIDTH, HURT_DURATION, SHIP_HEIGHT, SHIP_SPEED, SHIP_WIDTH};

pub struct Background {
    image: Rc<Texture2D>,
    x1: f32,
    x2: f32,
}

impl Background {
    pub fn new(image: Rc<Texture2D>) -> Self {
        Background {
            image,
            x1: 0.,
            x2: screen_width(),
        }
    }

    pub fn draw(&mut self) {
        draw_texture_ex(
            &self.image,
            self.x1,
            0.,
            WHITE,
            DrawTextureParams {
                dest_size: Some(vec2(screen_width(), screen_height())),
                ..Default::default()
            },
        );

        draw_texture_ex(
            &self.image,
            self.x2,
            0.,
            WHITE,
            DrawTextureParams {
                dest_size: Some(vec2(screen_width(), screen_height())),
                ..Default::default()
            },
        );

        self.mov();
    }

    fn mov(&mut self) {
        if self.x1 <= screen_width() * -1. {
            self.x1 = 0.;
        } else {
            self.x1 -= BG_SPEED;
        }

        self.x2 = screen_width() + self.x1;
    }
}

pub struct Spaceship {
    image: Rc<Texture2D>,
    pub pos: Vec2,
}

impl Spaceship {
    pub fn new(image: Rc<Texture2D>) -> Self {
        Spaceship {
            image: image,
            pos: vec2(50., screen_height() / 2.),
        }
    }

    pub fn draw(&mut self) {
        draw_texture_ex(
            &self.image,
            self.pos.x,
            self.pos.y,
            WHITE,
            DrawTextureParams {
                dest_size: Some(vec2(SHIP_WIDTH, SHIP_HEIGHT)),
                ..Default::default()
            },
        );
    }

    pub fn right(&mut self) {
        self.pos += vec2(SHIP_SPEED, 0.)
    }

    pub fn left(&mut self) {
        self.pos += vec2(-SHIP_SPEED, 0.)
    }

    pub fn up(&mut self) {
        self.pos += vec2(0., -SHIP_SPEED)
    }

    pub fn down(&mut self) {
        self.pos += vec2(0., SHIP_SPEED)
    }

    pub fn overlaps(&self, pos: &Vec2) -> bool {
        let h_overlaps = self.pos.x <= pos.x && pos.x <= self.pos.x + SHIP_WIDTH;
        let v_overlaps = self.pos.y <= pos.y && pos.y <= self.pos.y + SHIP_HEIGHT;

        return v_overlaps && h_overlaps
    }
}

pub struct Enemy {
    image: Rc<Texture2D>,
    hurt_image: Rc<Texture2D>,
    pub pos: Vec2,
    dir_y: f32,
    life: usize,
    is_hurt: bool,
    last_hurt: usize
}

impl Enemy {
    pub fn new(image: Rc<Texture2D>, hurt_image: Rc<Texture2D>) -> Self {
        Enemy {
            image: image,
            hurt_image: hurt_image,
            pos: Vec2 {
                x: screen_width() - ENEMY_WIDTH - 40.,
                y: screen_height() / 2. - ENEMY_HEIGHT / 2.,
            },
            dir_y: -1.,
            life: 100,
            is_hurt: false,
            last_hurt: 0

        }
    }

    pub fn draw(&mut self) {
        let mut image = &self.image;

        if self.is_hurt {
            image = &self.hurt_image;
        }

        draw_texture_ex(
            image,
            self.pos.x,
            self.pos.y,
            WHITE,
            DrawTextureParams {
                dest_size: Some(vec2(ENEMY_WIDTH, ENEMY_HEIGHT)),
                ..Default::default()
            },
        );

        self.change_hurt_state();
        self.draw_life();
        self.mov();
    }

    fn change_hurt_state(&mut self) {
        if self.last_hurt>= HURT_DURATION {
            self.is_hurt = false;
            self.last_hurt = 0;
        }

        self.last_hurt += 1;
    }

    fn mov(&mut self) {
        let nexty = self.pos.y + (ENEMY_SPEED * self.dir_y);

        if nexty <= 50. {
            self.dir_y = 1.;
        }

        if nexty >= screen_height() - ENEMY_HEIGHT - 50.{
            self.dir_y = -1.;
        }

        self.pos = vec2(self.pos.x, nexty);
    }

    pub fn overlaps(&self, pos: &Vec2) -> bool {
        let h_overlaps = self.pos.x <= pos.x && pos.x <= self.pos.x + ENEMY_WIDTH;
        let v_overlaps = self.pos.y <= pos.y && pos.y <= self.pos.y + ENEMY_HEIGHT;

        return v_overlaps && h_overlaps
    }

    pub fn hit(&mut self, times: usize) {
        self.life -= times;
        self.is_hurt = true;


    }

    fn draw_life(&self) {
        let portion = (screen_width() - 20.) / 100.;
        let w_life = portion * self.life as f32;
        let w_death = (screen_width()-20.) - w_life;

        draw_rectangle(10., 10., w_life, 20., YELLOW);
        draw_rectangle(w_life, 10., w_death, 20., RED);

        let text = format!("SCORE: {} / {}", self.life, 100);
        draw_text(&text, 20., 60., 40., YELLOW);
    }

}


pub struct Bullet {
    image: Rc<Texture2D>,
    pos: Vec2,
    dir: Vec2
}

impl Bullet {

    pub fn new(
        image: Rc<Texture2D>,
        pos: Vec2,
        dir: Vec2
    ) -> Self {
        Bullet {
            image,
            pos,
            dir
        }
    }


    pub fn draw(&mut self) {
        draw_texture_ex(
            &self.image,
            self.pos.x,
            self.pos.y,
            WHITE,
            DrawTextureParams {
                dest_size: Some(vec2(BULLET_SIZE, BULLET_SIZE)),
                ..Default::default()
            },
        );

        println!("Bullets {} {}", self.pos.x, self.pos.y);

        self.mov();
    }

    fn mov(&mut self) {
        self.pos = Vec2 {
            x: self.pos.x + self.dir.x * BULLET_SPEED,
            y: self.pos.y + self.dir.y * BULLET_SPEED,
        }
    }

    pub fn get_center(&self) -> Vec2 {
        Vec2 {
            x: self.pos.x + BULLET_SIZE / 2.,
            y: self.pos.y + BULLET_SIZE / 2.
        }
    }

}

