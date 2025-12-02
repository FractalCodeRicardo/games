use macroquad::{
    color::WHITE,
    math::{Rect, Vec2, vec2},
    rand::RandomRange,
    texture::{DrawTextureParams, Texture2D, draw_texture_ex},
};

use crate::consts::{BLOCK_SIZE, STEP};

pub struct Enemy {
    pub rect: Rect,
    dir: Vec2,
}

impl Enemy {
    pub fn new(i: usize, j: usize) -> Self {
        let rect = Rect::new(
            i as f32 * BLOCK_SIZE,
            j as f32 * BLOCK_SIZE,
            BLOCK_SIZE - 5.,
            BLOCK_SIZE - 5.,
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
