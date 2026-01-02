use macroquad::{prelude::*, rand::RandomRange};

const SQUARE_SIZE: f32 = 30.0;
const CREATE_INVADER_EVERY: usize = 3;

const MOVE_EVERY: f64 = 0.3;

struct Position {
    x: f32,
    y: f32,
}

impl Position {
    pub fn new(x: f32, y: f32) -> Self {
        return Position { x: x, y: y };
    }

    pub fn add(&mut self, x: f32, y: f32) {
        self.x = self.x + x;
        self.y = self.y + y;
    }
}

struct Bullet {
    pos: Position,
}

impl Bullet {
    fn new(x: f32, y: f32) -> Self {
        Bullet {
            pos: Position::new(x, y),
        }
    }

    fn draw(&mut self) {
        draw_rectangle(
            self.pos.x,
            self.pos.y,
            SQUARE_SIZE * 1.0,
            SQUARE_SIZE,
            GREEN,
        );
    }

    fn mov(&mut self) {
        self.pos.add(0.0, SQUARE_SIZE * -1.0);
    }
}

struct Invader {
    pos: Position,
}

impl Invader {
    fn new() -> Self {
        let x = RandomRange::gen_range(0.0, screen_width());
        let y = 0.0;

        Invader {
            pos: Position::new(x, y),
        }
    }

    fn draw(&mut self) {
        draw_rectangle(self.pos.x, self.pos.y, SQUARE_SIZE * 1.0, SQUARE_SIZE, RED);
    }

    fn mov(&mut self) {
        self.pos.add(0.0, SQUARE_SIZE);
    }
}
struct Ship {
    pos: Position,
}

impl Ship {
    fn new() -> Self {
        Ship {
            pos: Position::new(screen_width() / 2.0, screen_height() / 2.0 + 300.0),
        }
    }

    fn draw(&mut self) {
        draw_rectangle(
            self.pos.x,
            self.pos.y,
            SQUARE_SIZE * 3.0,
            SQUARE_SIZE,
            WHITE,
        );
    }

    fn left(&mut self) {
        self.pos.add(SQUARE_SIZE * -1.0, 0.0);
    }

    fn right(&mut self) {
        self.pos.add(SQUARE_SIZE * 1.0, 0.0);
    }

    fn shot(&mut self) -> Bullet {
        let bullet = Bullet::new(self.pos.x, self.pos.y);

        return bullet;
    }
}

struct Game {
    ship: Ship,
    invaders: Vec<Invader>,
    bullets: Vec<Bullet>,
    invaders_count: usize,
}

impl Game {
    pub fn new() -> Self {
        Game {
            ship: Ship::new(),
            invaders: Vec::new(),
            bullets: Vec::new(),
            invaders_count: 0,
        }
    }

    pub fn mov(&mut self) {
        self.create_invaders();
        self.mov_invaders();
        self.mov_bullets();
        self.handle_crash();
    }

    pub fn mov_invaders(&mut self) {
        for invader in &mut self.invaders {
            invader.mov();
        }
    }

    pub fn mov_bullets(&mut self) {
        for bullet in &mut self.bullets {
            bullet.mov();
        }
    }

    pub fn create_invaders(&mut self) {
        if self.invaders_count >= CREATE_INVADER_EVERY {
            self.invaders.push(Invader::new());
            self.invaders_count = 0;
            return;
        }

        self.invaders_count += 1;
    }

    pub fn draw_invaders(&mut self) {
        for invader in &mut self.invaders {
            invader.draw();
        }
    }

    pub fn draw_bullets(&mut self) {
        for bullet in &mut self.bullets {
            bullet.draw();
        }
    }

    pub fn draw(&mut self) {
        self.ship.draw();
        self.draw_invaders();
        self.draw_bullets();
    }

    pub fn left(&mut self) {
        self.ship.left();
    }

    pub fn right(&mut self) {
        self.ship.right();
    }

    pub fn shot(&mut self) {
        let bullet = self.ship.shot();
        self.bullets.push(bullet);
    }

    pub fn handle_crash(&mut self) {
        let mut bullets_remove = vec![false; self.bullets.len()];
        let mut invaders_remove = vec![false; self.invaders.len()];

        for (b_index, bullet) in self.bullets.iter().enumerate() {
            for (i_index, invader) in self.invaders.iter().enumerate() {
                if Game::is_crash(invader, bullet) {
                    bullets_remove[b_index] = true;
                    invaders_remove[i_index] = true;
                }
            }
        }

        let mut i = 0;

        self.bullets.retain(|_| {
            let keep = !bullets_remove[i];
            i += 1;
            return keep;
        });

        i = 0;
        self.invaders.retain(|_| {
            let keep = !invaders_remove[i];
            i += 1;
            return keep;
        });
    }

    pub fn is_crash(invader: &Invader, bullet: &Bullet) -> bool {
        let vertical = Game::vertical_crash(invader, bullet);
        let horizontal = Game::horizontal_crash(invader, bullet);

        return vertical && horizontal;
    }

    pub fn vertical_crash(invader: &Invader, bullet: &Bullet) -> bool {
        let i_bottom = invader.pos.y + SQUARE_SIZE;
        let b_top = bullet.pos.y;

        return i_bottom > b_top;
    }

    pub fn horizontal_crash(invader: &Invader, bullet: &Bullet) -> bool {
        let i_left = invader.pos.x;
        let i_right = i_left + SQUARE_SIZE;

        let b_left = bullet.pos.x;
        let b_righ = b_left + SQUARE_SIZE;

        if i_left == b_left {
            return true;
        }

        if i_left < b_left {
            return i_right >= b_left;
        }

        if i_left > b_left {
            return b_righ >= i_left;
        }

        return false;
    }
}

#[macroquad::main("MyGame")]
async fn main() {
    let mut game = Game::new();
    let mut time = get_time();

    loop {
        clear_background(BLACK);

        game.draw();

        if is_key_pressed(KeyCode::Left) {
            game.left();
        }

        if is_key_pressed(KeyCode::Right) {
            game.right();
        }

        if is_key_pressed(KeyCode::Space) {
            game.shot();
        }

        if get_time() - time > MOVE_EVERY {
            game.mov();
            time = get_time();
        }

        next_frame().await
    }
}
