mod consts;
mod map;
mod sprites;

use macroquad::{prelude::*, rand::RandomRange, texture};

use crate::{
    consts::{BLOCK_SIZE, FOOD_SIZE, PLAYER_SIZE, STEP},
    sprites::{Enemy, Player},
};

//TODO:
//1. Fix map, set this sizes wall 1x, player 3x, enemies 3x
//2. Refactor player to a struct
//3. Fix animation when player go up or down
//4. Fix end game

fn draw_rects(rects: &Vec<Rect>) {
    for r in rects {
        draw_rect(r);
    }
}

fn draw_rect(rect: &Rect) {
    draw_rectangle(rect.x, rect.y, rect.w, rect.h, MAGENTA);
}

fn draw_food(rects: &Vec<Rect>) {
    for rect in rects {
        draw_rectangle(rect.x, rect.y, rect.w, rect.h, YELLOW);
    }
}

fn draw_enemies(enemies: &mut Vec<Enemy>, textures: &Texture2D) {
    for enemy in enemies {
        enemy.draw_enemy(textures);
    }
}

fn collides_blocks(player: &Rect, blocks: &Vec<Rect>) -> bool {
    let res = collided_index(player, blocks);
    return res != -1;
}

fn collided_index(player: &Rect, blocks: &Vec<Rect>) -> i32 {
    let p1 = vec2(player.x, player.y);
    let p2 = vec2(player.x + player.w, player.y);
    let p3 = vec2(player.x, player.y + player.h);
    let p4 = vec2(player.x + player.w, player.y + player.h);
    for i in 0..blocks.len() {
        let b = blocks[i];

        if b.overlaps(player) {
            return i as i32;
        }

        if b.contains(p1) || b.contains(p2) || b.contains(p3) || b.contains(p4) {
            return i as i32;
        }
    }

    return -1;
}

fn draw_score(score: i32) {
    let text = format!("SCORE: {}", score);
    draw_text(&text, 10., screen_height() - 20., 40., WHITE);
}

fn draw_game_over() {
    let text = "GAME OVER";
    draw_text(
        &text,
        screen_width() - 300.,
        screen_height() - 20.,
        40.,
        RED,
    );
}

#[macroquad::main("MyGame")]
async fn main() {
    let textures = load_texture("./assets/sprites.png").await.unwrap();

    let map = map::get_map();
    let blocks = map::get_blocks(&map);
    let mut player = map::get_player(&map);
    let mut enemies = map::get_enemies(&map);
    let mut food = map::get_food(&map);
    let mut score = 0;
    let mut game_over = false;
    let mut open_mouth = false;
    let mut time = 0.;

    loop {
        clear_background(BLACK);

        draw_rects(&blocks);
        player.draw_player(&textures, open_mouth);
        draw_food(&food);
        draw_enemies(&mut enemies, &textures);
        draw_score(score);

        let mut is_moving = false;
        if is_key_down(KeyCode::Left) {
            player.mov_left();
            is_moving = true;
        }

        if is_key_down(KeyCode::Right) {
            player.mov_right();
            is_moving = true;
        }

        if is_key_down(KeyCode::Up) {
            player.mov_up();
            is_moving = true;
        }

        if is_key_down(KeyCode::Down) {
            player.mov_down();
            is_moving = true;
        }

        if !is_moving {
            player.stop();
        }

        if is_moving {
            let next_mov = player.next_mov();
            if !collides_blocks(&next_mov, &blocks) {
                if !game_over {
                    player.change_rect(next_mov);
                }
            }
        }

        let i_food = collided_index(&player.rect, &food);

        if i_food > -1 {
            food.remove(i_food as usize);
            score += 1;
        }

        let enemies_blocks = enemies.iter().map(|i| i.rect).collect();

        let i_enemy = collided_index(&player.rect, &enemies_blocks);

        if i_enemy > -1 {
            draw_game_over();
            game_over = true;
        }

        if !game_over {
            for e in &mut enemies {
                let mut ne = e.next_mov();

                while true {
                    if !collides_blocks(&ne, &blocks) {
                        break;
                    }

                    e.change_dir();
                    ne = e.next_mov();
                }

                e.change_rect(ne);
            }
        }

        if time > 0.5 {
            time = 0.;
            open_mouth = !open_mouth;
        }

        time += get_frame_time();

        next_frame().await
    }
}
