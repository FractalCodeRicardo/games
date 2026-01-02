mod consts;
mod audio;
mod components;

use macroquad::prelude::*;

use crate::{audio::Audio, components::{Canion, Head, LandFill, TrashCan}};

struct Game {
    landfill: LandFill,
    canion: Canion,
    heads: Vec<Head>,
    trash: TrashCan,
    score: usize,
    audio: Audio
}

impl Game {
    async fn new() -> Self {
        let landfill = LandFill::new().await;
        let canion = Canion::new().await;
        let heads = Vec::new();
        let trash = TrashCan::new().await;
        let audio = Audio::new().await;

        Game { 
            landfill: landfill ,
            canion: canion,
            heads: heads,
            trash: trash,
            score: 0,
            audio: audio
        }
    }

    fn draw(&mut self) {
        self.landfill.draw();
        self.canion.draw();
        self.draw_heads();
        self.trash.draw();
        self.handle_crash();
        self.draw_scores();
    }

    fn draw_heads(&mut self) {
        for h in &mut self.heads {
            h.draw();
        }
    }

    fn draw_scores(&self) {
        let text = format!("SCORE: {}", self.score);
        draw_text(&text, screen_width()/ 2. -100., 180., 80., YELLOW);
    }

    fn left(&mut self) {
        self.canion.left();
    }

    fn right(&mut self) {
        self.canion.right();
    }

    async fn shoot(&mut self) {
        let mut head = Head::new().await;

        let pos = self.canion.shoot_position();
        let force = self.canion.direction_force();
        head.set_shoot(&pos, &force);
        self.heads.push(head);

        self.audio.play_shoot();
    }

    fn handle_crash(&mut self) {
        let crashes = self.get_crash_indexes();

        if crashes.len() > 0 {
            self.audio.play_explosion();
            self.score += crashes.len();
        }

        self.remove_crashes(&crashes);
    }

    fn get_crash_indexes(&self) -> Vec<usize> {
        let mut indexes: Vec<usize> = Vec::new();
        for i in 0..self.heads.len() {
            let head = &self.heads[i];
            let point = head.get_bottom_center();

            if self.trash.overlaps(&point) {
                println!("Overlap");
                indexes.push(i);
            }
        }

        return indexes;
    }

    fn remove_crashes(&mut self, indexes: &Vec<usize>) {
        let mut i: usize = 0;
        self.heads
            .retain(|_| {
                let keep = !indexes.contains(&i);
                i += 1;
                keep
            });
    }
}

#[macroquad::main("MyGame")]
async fn main() {
    let mut game = Game::new().await;
    loop {
        clear_background(RED);
        
        events(&mut game).await;
        game.draw();

        next_frame().await
    }
}

async fn events(game: &mut Game) {

    if is_key_down(KeyCode::L) {
        game.right();
    }


    if is_key_down(KeyCode::H) {
        game.left();
    }

    if is_key_pressed(KeyCode::Space) {
        game.shoot().await;
    }

}
