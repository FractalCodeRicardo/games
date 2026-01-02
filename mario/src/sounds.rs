use macroquad::audio::{load_sound, play_sound, PlaySoundParams, Sound};

pub struct Sounds {
    background: Sound,
    jump: Sound
}

impl Sounds {

    pub async fn new() -> Self {

        let background = load_sound("./assets/background.ogg")
            .await
            .unwrap();

        let jump = load_sound("./assets/jump.wav")
            .await
            .unwrap();

        Sounds{
            background,
            jump
        }
    }

    pub fn play_background(&self) {
        play_sound(&self.background, PlaySoundParams {
            volume: 0.5,
            looped: true
        });
    }

    pub fn play_jump(&self) {
        play_sound(&self.jump, PlaySoundParams {
            volume: 0.5,
            looped: false
        });
    }

}
