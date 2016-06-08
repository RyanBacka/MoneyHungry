// ---------------------------------------
// Sprite definitions for 'bird'
// Generated with TexturePacker 4.2.1
//
// http://www.codeandweb.com/texturepacker
// ---------------------------------------

import SpriteKit


class Bird {

    // sprite names
    let FRAME_1 = "frame-1"
    let FRAME_2 = "frame-2"
    let FRAME_3 = "frame-3"
    let FRAME_4 = "frame-4"
    let FRAME_5 = "frame-5"
    let FRAME_6 = "frame-6"
    let FRAME_7 = "frame-7"
    let FRAME_8 = "frame-8"


    // load texture atlas
    let textureAtlas = SKTextureAtlas(named: "bird")


    // individual texture objects
    func frame_1() -> SKTexture { return textureAtlas.textureNamed(FRAME_1) }
    func frame_2() -> SKTexture { return textureAtlas.textureNamed(FRAME_2) }
    func frame_3() -> SKTexture { return textureAtlas.textureNamed(FRAME_3) }
    func frame_4() -> SKTexture { return textureAtlas.textureNamed(FRAME_4) }
    func frame_5() -> SKTexture { return textureAtlas.textureNamed(FRAME_5) }
    func frame_6() -> SKTexture { return textureAtlas.textureNamed(FRAME_6) }
    func frame_7() -> SKTexture { return textureAtlas.textureNamed(FRAME_7) }
    func frame_8() -> SKTexture { return textureAtlas.textureNamed(FRAME_8) }


    // texture arrays for animations
    func frame_() -> [SKTexture] {
        return [
            frame_1(),
            frame_2(),
            frame_3(),
            frame_4(),
            frame_5(),
            frame_6(),
            frame_7(),
            frame_8()
        ]
    }


}
