functor

import
    OS
    System
    Application
    QTk at 'x-oz://system/wp/QTk.ozf'
export
    'randomTexture': RandomTexture
define
    CD = {OS.getCWD}
    fun {GetRandInt N} {OS.rand} mod N end
    fun {RandomTexture}
        N ={GetRandInt 4}+1
        R
        WALL_TILE
        GROUND_TILE
        PACPOW_SPRITE 
        PACGUM_SPRITE
    in
        {System.show N}
        WALL_TILE = {QTk.newImage photo(file: CD # '/ress/'#N#'/wall.png')}
        GROUND_TILE = {QTk.newImage photo(file: CD # '/ress/'#N#'/ground.png')}
        PACGUM_SPRITE = {QTk.newImage photo(file: CD # '/ress/'#N#'/pacgum.png')}
        PACPOW_SPRITE = {QTk.newImage photo(file: CD # '/ress/'#N#'/pacpow.png')}
        R=texture(wall_tile:WALL_TILE  ground_tile:GROUND_TILE pacgum_sprite:PACGUM_SPRITE pacpow_sprite :PACPOW_SPRITE)
    end 
end