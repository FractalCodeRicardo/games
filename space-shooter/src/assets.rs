
use std::{collections::HashMap, fs, rc::Rc};

use macroquad::{
    audio::{PlaySoundParams, Sound, load_sound, play_sound},
    texture::{Texture2D, load_texture},
};

struct File {
    id: String,
    path: String,
}

pub struct Assets {
    images: HashMap<String, Rc<Texture2D>>,
    sounds: HashMap<String, Rc<Sound>>,
}

impl Assets {
    pub async fn new() -> Self {
        let files = Assets::get_files();
        let images = Assets::get_images(&files).await;
        let sounds = Assets::get_sounds(&files).await;

        Assets {
            images: images,
            sounds: sounds,
        }
    }

    async fn get_images(files: &Vec<File>) -> HashMap<String, Rc<Texture2D>> {
        let mut images: HashMap<String, Rc<Texture2D>> = HashMap::new();

        for f in files {
            let file = &f;

            if file.id.contains(".png") {
                let asset = load_texture(&file.path).await.unwrap();
                images.insert(file.id.to_string(), Rc::new(asset));
            }
        }

        return images;
    }

    async fn get_sounds(files: &Vec<File>) -> HashMap<String, Rc<Sound>> {
        let mut sounds: HashMap<String, Rc<Sound>> = HashMap::new();

        for f in files {
            let file = &f;

            if file.id.contains(".wav") || file.id.contains("ogg") {
                let asset = load_sound(&file.path).await.unwrap();
                sounds.insert(file.id.to_string(), Rc::new(asset));
            }
        }

        return sounds;
    }

    fn get_files() -> Vec<File> {
        let paths = fs::read_dir("./assets").unwrap();

        return paths
            .into_iter()
            .map(|f| {
                let file = f.unwrap().file_name().into_string().unwrap();

                let path = "./assets/".to_string() + &file;

                File {
                    id: file,
                    path: path,
                }
            })
            .collect();
    }

    pub fn image(&self, name: &str) -> Rc<Texture2D> {
        self.images[name].clone()
    }

    pub fn play_sound(&self, name: &str) {
        let sound = &self.sounds[name];
        play_sound(
            sound,
            PlaySoundParams {
                volume: 0.7,
                looped: false,
            },
        );
    }


    pub fn play_sound_loop(&self, name: &str) {
        let sound = &self.sounds[name];
        play_sound(
            sound,
            PlaySoundParams {
                volume: 0.7,
                looped: true,
            },
        );
    }
}
