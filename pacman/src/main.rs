use macroquad::{prelude::*, rand::RandomRange};

const BLOCK_SIZE: f32 = 25.;
const STEP: f32 = 3.;

fn get_map() -> Vec<String> {
    let map = vec![
        "############################",
        "#  p  *  *    *  x  *      #",
        "# ###### ######### #######*#",
        "# ###### ######### ####### #",
        "# *  * * x  x   *     *   *#",
        "# ### ##### #### #### #### #",
        "# ### ##### #### #### #### #",
        "#*### ##### #### #### #### #",
        "# ### ##### #### #### #### #",
        "# ### ##### #### #### #### #",
        "# ### ##### #### #### #### #",
        "#*   *  x ***   x   * x    #",
        "# ####  ##### ###### *#### #",
        "# #### x##### ######  #### #",
        "#*####  ##### ###### *#### #",
        "# ########### ############ #",
        "# ########## *  ########## #",
        "#  #########    ########## #",
        "#  ######### * ########### #",
        "#* * x x  *    x *  x * x  #",
        "############################",
    ]
    .iter()
    .map(|i| i.to_string())
    .collect();

    return map;
}

fn get_player(map: &Vec<String>) -> Rect {
    let mut player = Rect::new(0.0, 0., BLOCK_SIZE, BLOCK_SIZE);

    for j in 0..map.len() {
        let line = &map[j];
        for i in 0..line.len() {
            let c = line.chars().nth(i).unwrap();

            if c == 'p' {
                let rect = Rect::new(
                    i as f32 * BLOCK_SIZE,
                    j as f32 * BLOCK_SIZE,
                    BLOCK_SIZE - 10.,
                    BLOCK_SIZE - 10.,
                );
                player = rect;
            }
        }
    }

    player
}

fn get_food(map: &Vec<String>) -> Vec<Rect> {
    let mut food = vec![];
    for j in 0..map.len() {
        let line = &map[j];
        for i in 0..line.len() {
            let c = line.chars().nth(i).unwrap();

            if c == '*' {
                let rect = Rect::new(
                    i as f32 * BLOCK_SIZE,
                    j as f32 * BLOCK_SIZE,
                    BLOCK_SIZE - 20.,
                    BLOCK_SIZE - 20.,
                );

                food.push(rect);
            }
        }
    }

    food
}

fn get_enemies(map: &Vec<String>) -> Vec<Rect> {
    let mut enemies = vec![];
    for j in 0..map.len() {
        let line = &map[j];
        for i in 0..line.len() {
            let c = line.chars().nth(i).unwrap();

            if c == 'x' {
                let rect = Rect::new(
                    i as f32 * BLOCK_SIZE,
                    j as f32 * BLOCK_SIZE,
                    BLOCK_SIZE - 10.,
                    BLOCK_SIZE - 10.,
                );

                enemies.push(rect);
            }
        }
    }

    enemies
}

fn get_blocks(map: &Vec<String>) -> Vec<Rect> {
    let mut blocks = vec![];
    for j in 0..map.len() {
        let line = &map[j];
        for i in 0..line.len() {
            let c = line.chars().nth(i).unwrap();

            if c == '#' {
                let rect = Rect::new(
                    i as f32 * BLOCK_SIZE,
                    j as f32 * BLOCK_SIZE,
                    BLOCK_SIZE,
                    BLOCK_SIZE,
                );

                blocks.push(rect);
            }
        }
    }

    blocks
}

fn draw_rects(rects: &Vec<Rect>) {
    for r in rects {
        draw_rect(r);
    }
}

fn draw_rect(rect: &Rect) {
    draw_rectangle(rect.x, rect.y, rect.w, rect.h, BLUE);
}

fn draw_cirs(rects: &Vec<Rect>, color: Color) {
    for rect in rects {
        draw_cir(rect, color);
    }
}

fn draw_cir(rect: &Rect, color: Color) {
    draw_circle(
        rect.x + BLOCK_SIZE / 2.,
        rect.y + BLOCK_SIZE / 2.,
        rect.w / 2.,
        color,
    );
}

fn mov_left(rect: &Rect) -> Rect {
    Rect::new(rect.x - STEP, rect.y, rect.w, rect.h)
}

fn mov_right(rect: &Rect) -> Rect {
    Rect::new(rect.x + STEP, rect.y, rect.w, rect.h)
}

fn mov_up(rect: &Rect) -> Rect {
    Rect::new(rect.x, rect.y - STEP, rect.w, rect.h)
}

fn mov_down(rect: &Rect) -> Rect {
    Rect::new(rect.x, rect.y + STEP, rect.w, rect.h)
}

fn random_mov(rect: &Rect) -> Rect {
    let movs = vec![
        vec2(STEP, 0.),
        vec2(-STEP, 0.),
        vec2(0., STEP),
        vec2(0., -STEP),
    ];

    let m = movs[RandomRange::gen_range(0, 4)];

    return Rect::new(
        rect.x + m.x,
        rect.y + m.y, 
        rect.w, rect.h
    );
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
        if b.contains(p1) || b.contains(p2) || b.contains(p3) || b.contains(p4) {
            return i as i32;
        }
    }

    return -1;
}

fn draw_score(score: i32) {
    let text = format!("SCORE: {}", score);
    draw_text(&text, 10., screen_height() -20., 40., WHITE);
}


fn draw_game_over() {
    let text ="GAME OVER";
    draw_text(&text, screen_width() - 300., screen_height() -20., 40., RED);
}

#[macroquad::main("MyGame")]
async fn main() {
    let map = get_map();
    let blocks = get_blocks(&map);
    let mut player = get_player(&map);
    let mut enemies = get_enemies(&map);
    let mut food = get_food(&map);
    let mut score = 0;
    let mut game_over =  false;

    loop {
        clear_background(BLACK);

        draw_rects(&blocks);
        draw_cir(&player, YELLOW);
        draw_cirs(&food, WHITE);
        draw_cirs(&enemies, RED);
        draw_score(score);

        let mut next_player = player;
        if is_key_down(KeyCode::Left) {
            next_player = mov_left(&player);
        }

        if is_key_down(KeyCode::Right) {
            next_player = mov_right(&player);
        }

        if is_key_down(KeyCode::Up) {
            next_player = mov_up(&player);
        }

        if is_key_down(KeyCode::Down) {
            next_player = mov_down(&player);
        }

        if !collides_blocks(&next_player, &blocks) {
            if !game_over {
                player = next_player;
            }
        }

        let i_food = collided_index(&player, &food);

        if i_food > -1 {
            food.remove(i_food as usize);
            score += 1;
        }

        let i_enemy = collided_index(&player, &enemies);

        if i_enemy > -1 {
            draw_game_over();
            game_over = true;
        }

        for e in &mut enemies {
            let ne = random_mov(&e);

            if !collides_blocks(&ne, &blocks) {
                *e = ne;
            }
        }

        next_frame().await
    }
}
