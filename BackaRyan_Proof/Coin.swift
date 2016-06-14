// ---------------------------------------
// Sprite definitions for 'coin'
// Generated with TexturePacker 4.2.1
//
// http://www.codeandweb.com/texturepacker
// ---------------------------------------

import SpriteKit


class Coin {

    // sprite names
    let COIN_01 = "coin_01"
    let COIN_02 = "coin_02"
    let COIN_03 = "coin_03"
    let COIN_04 = "coin_04"
    let COIN_05 = "coin_05"
    let COIN_06 = "coin_06"
    let COIN_07 = "coin_07"
    let COIN_08 = "coin_08"


    // load texture atlas
    let textureAtlas = SKTextureAtlas(named: "coin")


    // individual texture objects
    func coin_01() -> SKTexture { return textureAtlas.textureNamed(COIN_01) }
    func coin_02() -> SKTexture { return textureAtlas.textureNamed(COIN_02) }
    func coin_03() -> SKTexture { return textureAtlas.textureNamed(COIN_03) }
    func coin_04() -> SKTexture { return textureAtlas.textureNamed(COIN_04) }
    func coin_05() -> SKTexture { return textureAtlas.textureNamed(COIN_05) }
    func coin_06() -> SKTexture { return textureAtlas.textureNamed(COIN_06) }
    func coin_07() -> SKTexture { return textureAtlas.textureNamed(COIN_07) }
    func coin_08() -> SKTexture { return textureAtlas.textureNamed(COIN_08) }


    // texture arrays for animations
    func coin_() -> [SKTexture] {
        return [
            coin_01(),
            coin_02(),
            coin_03(),
            coin_04(),
            coin_05(),
            coin_06(),
            coin_07(),
            coin_08()
        ]
    }


}
