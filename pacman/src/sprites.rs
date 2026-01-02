use macroquad::{
    color::WHITE,
    math::{Rect, Vec2, vec2},
    rand::RandomRange,
    texture::{DrawTextureParams, Texture2D, draw_texture_ex},
};

use crate::consts::{BLOCK_SIZE, ENEMY_SIZE, PLAYER_SIZE, STEP};

pub struct Enemy {
    pub rect: Rect,
    dir: Vec2,
}

impl Enemy {
    pub fn new(i: usize, j: usize) -> Self {
        let rect = Rect::new(
            i as f32 * BLOCK_SIZE,
            j as f32 * BLOCK_SIZE,
            ENEMY_SIZE,
            ENEMY_SIZE,
        );

        let dir = vec2(STEP, 0.);

        Enemy { rect, dir }
    }

    pub fn draw_enemy(&mut self, texture: &Texture2D) {
        let area = Rect::new(0., 0., 230., 250.);

        draw_texture_ex(
            &texture,
            self.rect.x,
            self.rect.y,
            WHITE,
            DrawTextureParams {
                dest_size: Some(vec2(self.rect.w, self.rect.h)),
                source: Some(area),
                ..Default::default()
            },
        );
    }

    pub fn change_rect(&mut self, rect: Rect) {
        self.rect = rect;
    }

    pub fn next_mov(&self) -> Rect {
        Rect::new(
            self.rect.x + self.dir.x,
            self.rect.y + self.dir.y,
            self.rect.w,
            self.rect.h,
        )
    }

    pub fn change_dir(&mut self) {
        self.dir = Enemy::random_dir();
    }

    fn random_dir() -> Vec2 {
        let movs = vec![
            vec2(STEP, 0.),
            vec2(-STEP, 0.),
            vec2(0., STEP),
            vec2(0., -STEP),
        ];

        let m = movs[RandomRange::gen_range(0, 4)];
        return m;
    }
}

pub struct Player {
    pub rect: Rect,
    dir: Vec2,
}

impl Player {
    pub fn new(i: usize, j: usize) -> Self {
        let rect = Rect::new(
            i as f32 * BLOCK_SIZE,
            j as f32 * BLOCK_SIZE,
            PLAYER_SIZE,
            PLAYER_SIZE,
        );

        Player {
            rect: rect,
            dir: vec2(0., 0.),
        }
    }

    pub fn get_rotation(&self) -> f32 {
        if self.dir.y < 0. {
            return (-90 as f32).to_radians();
        }


        if self.dir.x < 0. {
            return (-180 as f32).to_radians();
        }


        if self.dir.y > 0. {
            return (-270 as f32).to_radians();
        }

        return 0.;
    }

    pub fn mov_left(&mut self) {
        self.dir = vec2(-STEP, 0.);
    }


    pub fn mov_right(&mut self) {
        self.dir = vec2(STEP, 0.);
    }

    pub fn mov_up(&mut self)  {
        self.dir = vec2(0., -STEP);
    }

    pub fn mov_down(&mut self)  {
        self.dir = vec2(0., STEP);
    }

    pub fn stop(&mut self)  {
        self.dir = vec2(0., 0.);
    }

    pub fn next_mov(&mut self) -> Rect {
        Rect::new(
            self.rect.x + self.dir.x, 
            self.rect.y + self.dir.y, 
            self.rect.w, 
            self.rect.h)
    }

    pub fn draw_player(&mut self, texture: &Texture2D, open: bool) {
        let frame = if open { 0. } else { 1. };
        let rotation = self.get_rotation();

        let area = Rect::new(frame * 230., 270., 230., 250.);

        draw_texture_ex(
            &texture,
            self.rect.x,
            self.rect.y,
            WHITE,
            DrawTextureParams {
                dest_size: Some(vec2(self.rect.w, self.rect.h)),
                rotation: rotation,
                source: Some(area),
                ..Default::default()
            },
        );
    }

    pub fn change_rect(&mut self, rect: Rect) {
        self.rect = rect; 
    }
}
