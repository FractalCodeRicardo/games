use macroquad::math::Rect;

use crate::{consts::{BLOCK_SIZE, FOOD_SIZE}, sprites::{Enemy, Player}};

pub fn get_map() -> Vec<String> {
    let map = vec![
        "#####################################################",
        "#                                                   #",
        "#         ** * *            *** *     ****          #",
        "#                                                   #",
        "#              ****        ****         *           #",
        "#                    x             x    x           #",
        "#           p     ***      ***                      #",
        "#                                                   #",
        "#               ######   ##### #     #              #",
        "#               #        #      #   #               #",
        "#         *     #        #       # #                #",
        "#         *     ######   ###      #                 #",
        "#         *          #   #       # #                #",
        "#                    #   #      #   #               #",
        "#               ######   ##### #     #              #",
        "#          *                                        #",
        "#          *                                        #",
        "#          *     **  x     **     x  **             #",
        "#                                                   #",
        "#                                                   #",
        "#          #####     #####    #####   ####          #",
        "#                                                   #",
        "#                                                   #",
        "#         x           x           x                 #",
        "#                                                   #",
        "#       ** *          * ***         ***             #",
        "#                                                   #",
        "#          #####     #####    #####   ####          #",
        "#                                                   #",
        "#       *      x     ** **      x      **** *       #",
        "#       *                                           #",
        "#       *                                           #",
        "#          #     #     #     #     #     #          #",
        "#           #   #       #   #       #   #           #",
        "#            # #         # #    x    # #    *       #",
        "#             #           #           #     *       #",
        "#            # #        #  #         # #    *       #",
        "#           #   #      #    #       #   #   *       #",
        "#          #     #    #      #     #     #  *       #",
        "#                                                   #",
        "#                                                   #",
        "#              x                   x                #",
        "#          ***       * ****         ****            #",
        "#                     x                             #",
        "#                                                   #",
        "#####################################################",
    ]
    .iter()
    .map(|i| i.to_string())
    .collect();

    return map;
}

pub fn iter_map(map: &Vec<String>) -> Vec<(usize, usize, char)> {
    let mut items = vec![];

    for j in 0..map.len() {
        let line = &map[j];
        for i in 0..line.len() {
            let c = line.chars().nth(i).unwrap();

            items.push((i, j, c));
        }
    }

    items
}

pub fn get_player(map: &Vec<String>) -> Player {
    let mut player = Player::new(0, 0);

    for e in iter_map(map) {
        let c = e.2;
        let i = e.0;
        let j = e.1;

        if c == 'p' {
            player = Player::new(i, j);
        }
    }

    player
}

pub fn get_food(map: &Vec<String>) -> Vec<Rect> {
    let mut food = vec![];

    for e in iter_map(map) {
        let c = e.2;
        let i = e.0;
        let j = e.1;

        if c == '*' {
            let rect = Rect::new(
                i as f32 * BLOCK_SIZE,
                j as f32 * BLOCK_SIZE,
                FOOD_SIZE,
                FOOD_SIZE,
            );

            food.push(rect);
        }
    }

    food
}

pub fn get_enemies(map: &Vec<String>) -> Vec<Enemy> {
    let mut enemies = vec![];
    for e in iter_map(map) {
        let c = e.2;
        let i = e.0;
        let j = e.1;

        if c == 'x' {

            let enemy = Enemy::new(i, j);
            enemies.push(enemy);
        }
    }

    enemies
}

pub fn get_blocks(map: &Vec<String>) -> Vec<Rect> {
    let mut blocks = vec![];
    for e in iter_map(map) {
        let c = e.2;
        let i = e.0;
        let j = e.1;

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

    blocks
}
