use std::vec;

use macroquad::{color::WHITE, math::{vec2, Vec2}, rand::RandomRange, text::draw_text_ex, texture::{draw_texture_ex, load_texture, DrawTextureParams, Texture2D}, window::{screen_height, screen_width}};

use crate::consts::{CANION_HEIGHT, CANION_WIDTH, GRAVITY, HEAD_SIZE, RESISTENCE, SHOOT_MAGNITUDE, TRASH_HEIGHT, TRASH_SPEED, TRASH_WIDTH};

pub struct LandFill {
    image: Texture2D
}

impl LandFill {

    pub async fn new() -> Self {

        let image = load_texture("./assets/background.png")
            .await
            .unwrap();

        LandFill {
            image
        }
    }


    pub fn draw(&self) {
        draw_texture_ex(
            &self.image,
            0.,
            0.,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(screen_width(), screen_width())),
                ..Default::default()
            }
        );
    }
}

pub struct Canion {
    image: Texture2D,
    angle: f32
}

impl Canion {

    pub async fn new() -> Self {

        let image = load_texture("./assets/canion.png")
            .await
            .unwrap();

        Canion {
            image: image,
            angle: 45.
        }
    }

    pub fn draw(&self) {
        let base_angle = (90. as f32).to_radians();
        draw_texture_ex(
            &self.image,
            - CANION_WIDTH / 2.,
            screen_height() - CANION_HEIGHT/ 2.,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(CANION_WIDTH, CANION_HEIGHT)),
                rotation: base_angle - self.angle.to_radians(),
                ..Default::default()
            }
        );
    }

    pub fn left(&mut self) {
        self.angle += 1.;
    }

    pub fn right(&mut self) {
        self.angle -= 1.;
    }

    pub fn shoot_position(&self) -> Vec2 {
        let x = CANION_HEIGHT / 2.;
        let y = 0.;

        let cos = self.angle.to_radians().cos();
        let sin = self.angle.to_radians().sin();

        let n_x = x * cos - y* sin;
        let n_y = x * sin + x* cos;

        println!("POS {} {}", n_x, n_y);

        return Vec2::new(n_x, screen_height() - n_y);
    }

    pub fn direction_force(&self) -> Vec2 {
        let angle = self.angle.to_radians();
        
        let x = SHOOT_MAGNITUDE * angle.cos(); 
        let y = SHOOT_MAGNITUDE * angle.sin(); 

        Vec2::new(x, y)
    }
    
}

pub struct Head {
    image: Texture2D,
    pos: Vec2,
    force: Vec2
}

impl Head {
    pub async fn new() -> Self {
        let heads_files = vec!["head1.png","head2.png","head3.png", "head4.png"];
        let index = RandomRange::gen_range(0, heads_files.len());
        let file = heads_files[index];
        let path = "./assets/".to_string() + file;

        let image = load_texture(&path)
            .await
            .unwrap();

        let pos = Vec2::new(0., screen_height());
        let force = Vec2::new(10., 30.);

        Head {
            image: image,
            pos: pos,
            force: force
        }
    }

    pub fn draw(&mut self) {
        draw_texture_ex(
            &self.image,
            self.pos.x,
            self.pos.y,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(HEAD_SIZE, HEAD_SIZE)),
                ..Default::default()
            }
        );

        self.mov();
    }

    pub fn mov(&mut self) {
        self.pos = Vec2 {
            x: self.pos.x + self.force.x,
            y: self.pos.y - self.force.y
        };

        self.force = Vec2 {
            x: self.force.x * RESISTENCE,
            y: (self.force.y - GRAVITY) * RESISTENCE
        };
    }

    pub fn set_shoot(&mut self, pos: &Vec2, force: &Vec2) {
        self.pos = Vec2{
            x: pos.x,
            y: pos.y
        };

        self.force = Vec2 {
            x: force.x,
            y: force.y
        };
    }

    pub fn get_bottom_center(&self) -> Vec2 {
        Vec2 {
            x: self.pos.x + HEAD_SIZE / 2.,
            y: self.pos.y + HEAD_SIZE
        }
    }
    
}

pub struct TrashCan {
    image: Texture2D,
    pos: Vec2,
    dir_x: f32
}

impl TrashCan {

    pub async fn new() -> Self {

        let image = load_texture("./assets/trash.png")
            .await
            .unwrap();

        let pos = Vec2::new(screen_width() / 2., screen_height() - TRASH_HEIGHT);

        TrashCan {
            image: image,
            pos: pos,
            dir_x: 1.
        }
    }

    pub fn draw(&mut self) {
        draw_texture_ex(
            &self.image,
            self.pos.x,
            self.pos.y,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(TRASH_WIDTH, TRASH_HEIGHT)),
                ..Default::default()
            }
        );

        self.mov();
    }

    fn mov(&mut self) {
        let next = self.pos.x + (TRASH_SPEED * self.dir_x);

        if next <= 200. {
            self.dir_x = 1.;
            return 
        }

        if next >= screen_width() - TRASH_WIDTH {
            self.dir_x = -1.;
            return;
        }

        self.pos = Vec2 {
            x: next,
            y: self.pos.y 
        }
    }

    pub fn overlaps(&self, pos: &Vec2) -> bool {
        let v_overlap = self.pos.y <= pos.y && pos.y <= self.pos.y + TRASH_HEIGHT;
        let h_overlap = self.pos.x<= pos.x && pos.x <= self.pos.x + TRASH_WIDTH;

        return v_overlap && h_overlap;

    }
}
