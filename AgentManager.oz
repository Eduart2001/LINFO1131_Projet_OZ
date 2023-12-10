functor

import
    System
    GhOzt000Basic
    PacmOz000Basic
    GhOzt055Advanced at './extension/GhOzt055Advanced.ozf'
    PacmOz055Advanced at './extension/PacmOz055Advanced.ozf'
    PacmOz055Basic
    GhOzt055Basic

export
    'spawnBot': SpawnBot
define

    % Spawn the agent and returns its port
    fun {SpawnBot BotName Init}
        % Init => init(Id GameControllerPort Maze)
        case BotName of
            'ghOzt000Basic' then {GhOzt000Basic.getPort Init}
        []  'pacmOz000Basic' then {PacmOz000Basic.getPort Init}
        []  'ghOzt055Advanced' then {GhOzt055Advanced.getPort Init}
        []  'pacmOz055Advanced' then {PacmOz055Advanced.getPort Init}
        else
            {System.show 'Unknown BotName'}
            false
        end
    end
end