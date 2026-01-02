use std::rc::Rc;

use macroquad::texture::{load_texture, Texture2D};

pub struct Images {
    desert: Rc<Texture2D>,
    dinosaur1: Rc<Texture2D>,
    dinosaur2: Rc<Texture2D>,
    cactus: Rc<Texture2D>
}

impl Images {
    pub async fn new() -> Self {

        let desert = load_texture("./assets/images/background.png")
            .await
            .unwrap();

        let dinosaur1 = load_texture("./assets/images/dinosaur1.png")
            .await
            .unwrap();

        let dinosaur2 = load_texture("./assets/images/dinosaur2.png")
            .await
            .unwrap();

        let cactus = load_texture("./assets/images/cactus.png")
            .await
            .unwrap();

        Images {
            desert: Rc::new(desert),
            dinosaur1: Rc::new(dinosaur1),
            dinosaur2: Rc::new(dinosaur2),
            cactus: Rc::new(cactus)
        }
    }

    pub fn get_desert(&self) -> Rc<Texture2D> {
        return self.desert.clone();
    }

    pub fn get_cactus(&self) -> Rc<Texture2D> {
        return self.cactus.clone();
    }

    pub fn get_dinosaurs(&self) -> Vec<Rc<Texture2D>>{
        let mut images: Vec<Rc<Texture2D>>= Vec::new();

        images.push( self.dinosaur1.clone());
        images.push( self.dinosaur2.clone());

        return images;
    }
}
