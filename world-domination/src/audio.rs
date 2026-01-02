use macroquad::audio::*;
use macroquad::prelude::*;

pub struct AudioHandler {
    shoot: Sound,
    explosion: Sound,
    background: Sound
}

impl AudioHandler {

    pub async fn new() -> Self {
        let shoot = load_sound("./assets/shoot.wav").await;
        let explosion = load_sound("./assets/explosion.wav").await;
        let background = load_sound("./assets/background.ogg").await;

        return AudioHandler {
            shoot: shoot.unwrap(),
            explosion: explosion.unwrap(),
            background: background.unwrap()
        }
    }

    pub fn play_shoot(&self) {
        AudioHandler::play(&self.shoot, false, 1.);
    }

    pub fn play_explosion(&self) {
        AudioHandler::play(&self.explosion, false, 1.);
    }

    pub fn play_background(&self) {
        AudioHandler::play(&self.background, true, 0.7);
    }

    pub fn play(sound: &Sound, looped: bool, vol: f32) {
        play_sound(
            sound,
            PlaySoundParams {
                looped: looped,
                volume: vol
            },
        );
    }
}
