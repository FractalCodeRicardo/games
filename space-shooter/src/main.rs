mod consts;
mod assets;
mod components;
use macroquad::{prelude::*, rand::RandomRange};

use crate::{assets::Assets, components::{Background, Bullet, Enemy, Spaceship}, consts::{BULLET_SPEED, ENEMY_HEIGHT, SHIP_HEIGHT, SHIP_WIDTH, SHOOT_EVERY}};

struct Game {
    assets: Assets,
    background: Background,
    spaceship: Spaceship,
    enemy: Enemy,
    bullets: Vec<Bullet>,
    last_shoot: usize,
    game_over: bool

}

impl Game {

    async fn new() -> Self {
        let assets = Assets::new().await;
        let background = Background::new(assets.image("background.png"));
        let spaceship = Spaceship::new(assets.image("spaceship.png"));

        let enemy_image = assets.image("enemy.png");
        let hurt_image = assets.image("enemy-shoot.png");
        let enemy = Enemy::new(enemy_image, hurt_image);

        Game {
            assets: assets,
            background: background,
            spaceship: spaceship,
            enemy: enemy,
            bullets: Vec::new(),
            last_shoot: 0,
            game_over: false
        }
    }

    fn draw(&mut self) {
        if self.game_over {
            self.background.draw();
            self.show_end_game();
            return;
        }

        self.background.draw();
        self.spaceship.draw();
        self.enemy.draw();
        self.draw_bullets();
        self.enemy_shoot();
        self.handle_enemy_hit();
        self.handle_spaceship_hit();
    }

    fn show_end_game(&self) {
        let text = "GAME OVER";
        draw_text(text, screen_width() /2. -80., 200., 40., YELLOW);
    }

    fn draw_bullets(&mut self) {
        for b in &mut self.bullets {
            b.draw();
        }
    }

    fn left(&mut self) {
        self.spaceship.left();
    }

    fn up(&mut self) {
        self.spaceship.up();
    }

    fn right(&mut self) {
        self.spaceship.right();
    }

    fn down(&mut self) {
        self.spaceship.down();
    }

    fn space_ship_shoot(&mut self) {
        let pos = Vec2 {
            x: self.spaceship.pos.x + SHIP_WIDTH,
            y: self.spaceship.pos.y + SHIP_HEIGHT / 2.
        };

        let dir =vec2(BULLET_SPEED, 0.);
        let image = self.assets.image("shoot.png");
        let bullet = Bullet::new(image, pos, dir);

        self.bullets.push(bullet);
        self.play_shoot();
    }

    fn enemy_shoot(&mut self) {
        if self.last_shoot < SHOOT_EVERY {
            self.last_shoot += 1;
            return
        }

        self.last_shoot = 0;

        let multishoot = RandomRange::gen_range(0, 2);

        if multishoot == 1 {
            self.enemy_multi_shoot();
        } else {
            self.boss_single_shoot();
        }

    }

    fn boss_single_shoot(&mut self) {

        let pos = Vec2 {
            x: self.enemy.pos.x - 5.,
            y: self.enemy.pos.y + ENEMY_HEIGHT / 2.
        };

        let mut to = self.spaceship.pos - self.enemy.pos;
        to = to.normalize() * vec2(BULLET_SPEED, BULLET_SPEED);

        let image = self.assets.image("shoot.png");
        let bullet = Bullet::new(image, pos, to);

        self.bullets.push(bullet);
        self.play_shoot();
    }

    fn enemy_multi_shoot(&mut self) {
        let pos = Vec2 {
            x: self.enemy.pos.x - 5.,
            y: self.enemy.pos.y + ENEMY_HEIGHT / 2.
        };

        let image = self.assets.image("shoot.png");
        let b1 = Bullet::new(image.clone(), pos, vec2(-2., 0.));
        let b2 = Bullet::new(image.clone(), pos, vec2(-2., 1.));
        let b3 = Bullet::new(image.clone(), pos, vec2(-2., 2.));
        let b4 = Bullet::new(image.clone(), pos, vec2(-2., -1.));
        let b5 = Bullet::new(image.clone(), pos, vec2(-2., -2.));

        self.bullets.push(b1);
        self.bullets.push(b2);
        self.bullets.push(b3);
        self.bullets.push(b4);
        self.bullets.push(b5);


        self.play_shoot();
        self.play_shoot();
        self.play_shoot();
    }

    fn handle_enemy_hit (&mut self) {
        let bullets = self.get_bullets_enemy_hit();
        self.remove_bullets(&bullets);

        if bullets.len() > 0 {
            self.enemy.hit(bullets.len());
            self.play_explosion();
        }
    }


    fn handle_spaceship_hit (&mut self) {
        let bullets = self.get_bullets_spaceship_hit();
        self.remove_bullets(&bullets);

        if bullets.len() > 0 {
            self.game_over = true;
            self.play_explosion();
        }
    }

    fn get_bullets_enemy_hit(&self) -> Vec<usize> {
        let mut indexes = Vec::new();

        for i in 0..self.bullets.len() {
            let b = &self.bullets[i];
            let p = b.get_center();

            if self.enemy.overlaps(&p) {
                indexes.push(i);
            }
        }

        return indexes;
    }


    fn get_bullets_spaceship_hit(&self) -> Vec<usize> {
        let mut indexes = Vec::new();

        for i in 0..self.bullets.len() {
            let b = &self.bullets[i];
            let p = b.get_center();

            if self.spaceship.overlaps(&p) {
                indexes.push(i);
            }
        }

        return indexes;
    }

    fn remove_bullets(&mut self, indexes: &Vec<usize>) {
        let mut i = 0;
        self.bullets
            .retain(|_| {
                let keep = !indexes.contains(&i);
                i += 1;
                keep
            });
    }

    fn play_explosion(&self) {
        self.assets.play_sound("explosion.wav");
    }

    fn play_shoot(&self) {
        self.assets.play_sound("shoot.wav");
    }

}

#[macroquad::main("MyGame")]
async fn main() {
    let mut game = Game::new().await;
    loop {
        clear_background(RED);

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

    if is_key_down(KeyCode::J) {
        game.down();
    }

    if is_key_down(KeyCode::K) {
        game.up();
    }

    if is_key_pressed(KeyCode::Space) {
        game.space_ship_shoot();
    }
}
