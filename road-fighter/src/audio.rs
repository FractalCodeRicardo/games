use macroquad::audio::{load_sound, play_sound, PlaySoundParams, Sound};

pub struct Audio {
    explosion: Sound,
    background: Sound
}

impl Audio {

    pub async fn new() -> Self {
        let explosion = load_sound("./assets/audio/explosion.wav").await.unwrap();
        let background = load_sound("./assets/audio/engine.ogg").await.unwrap();

        Audio {
            explosion: explosion,
            background:background
        }
    }

    pub fn play_explosion(&self) {
        play_sound(&self.explosion, PlaySoundParams {
            looped: false,
            volume: 0.7
        });
    }

    pub fn play_background(&self) {
        play_sound(&self.background, PlaySoundParams {
            looped: true,
            volume: 0.7
        });
    }
}
