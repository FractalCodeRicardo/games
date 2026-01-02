mod map;
use macroquad::{audio::{load_sound, play_sound, PlaySoundParams, Sound}, miniquad::native::linux_x11::libx11::Drawable, prelude::*};
use macroquad_platformer::{Actor, Tile, World};

use crate::map::MapDrawer;

struct Player {
    actor: Actor,
    texture: Texture2D,
    speed: Vec2,
}

pub struct Game {
    camera: Camera2D,
    map: MapDrawer,
    player: Player,
    world: World,
    sound: Sound
}

impl Game {
    async fn new() -> Game {
        let map = MapDrawer::new().await;

        let heigth = map.px_height();
        let width = map.px_width();
        let area = Rect::new(0., heigth, width / 7., -heigth);
        let camera = Camera2D::from_display_rect(area);

        let mut world = World::new();
        let actor_texture = load_texture("./assets/player.png").await.unwrap();

        let actor_pos = vec2(10., heigth / 2.);
        let actor = world.add_actor(actor_pos, 32, 32);
        let player = Player {
            actor: actor,
            texture: actor_texture,
            speed: vec2(60., 0.),
        };

        let sound = load_sound("./assets/jump.wav")
            .await
            .unwrap();

        let mut game =Game {
            camera: camera,
            map: map,
            player: player,
            world: world,
            sound: sound
        };

        game.load_obstacles();

        return game
    }

    fn load_obstacles(&mut self) {
        let tiles = self.map.get_tiles();

        let obstacles = tiles.map(|i| {
            if i.2.is_some() {
                return Tile::Solid;
            }

            return Tile::Empty;
        }).collect();

        self.world.add_static_tiled_layer(
            obstacles, 
            self.map.tile_width(), 
            self.map.tile_height(), 
            self.map.width() as usize,
        1);
    }

    fn draw(&mut self) {
        set_camera(&self.camera);
        self.map.draw();
        self.draw_player();
        self.mov();
        self.follow_player();
    }

    fn draw_player(&self) {
        let pos = self.world.actor_pos(self.player.actor);
        draw_texture_ex(
            &self.player.texture,
            pos.x,
            pos.y,
            WHITE,
            DrawTextureParams {
                dest_size: Some(vec2(32., 32.)),
                ..Default::default()
            },
        );
    }

    fn mov(&mut self) {
        let actor = self.player.actor;

        let dy = self.player.speed.y * get_frame_time();
        let dx = self.player.speed.x * get_frame_time();
        self.world.move_v(actor, dy);
        self.world.move_h(actor, dx);

        self.player.speed.y += 200. * get_frame_time();
    }

    fn jump(&mut self) {
        self.player.speed.y = -120.;
        self.play_sound();
    }

    fn follow_player(&mut self) {
        let pos = self.world.actor_pos(self.player.actor);
        self.camera.target = vec2(pos.x, pos.y);
    }

    fn play_sound(&self) {
        play_sound(&self.sound, PlaySoundParams {
            looped: false,
            volume: 0.7
        });
    }
}
#[macroquad::main("Flappy")]
async fn main() {
    let mut game = Game::new().await;

    loop {
        clear_background(GREEN);

        if is_key_pressed(KeyCode::Space) {
            game.jump();
        }

        game.draw();

        next_frame().await
    }
}
