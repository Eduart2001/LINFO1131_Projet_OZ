functor

import 
    OS
export
    'eatingPacgums':EatingPacgums
define
    fun{EatingPacgums}
        Command
    in
        Command="powershell -c (New-Object Media.SoundPlayer './Soundeffects/pacman_chomp.wav')"
    end 


end