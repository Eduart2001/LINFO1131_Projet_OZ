functor

import
    System
    GhOzt000Basic
    PacmOz000Basic
    GhOzt055Basic
    PacmOz055Basic
export
    'spawnBot': SpawnBot
define

    % Spawn the agent and returns its port
    fun {SpawnBot BotName Init}
        % Init => init(Id GameControllerPort Maze)
        case BotName of
            'ghOzt000Basic' then {GhOzt000Basic.getPort Init}
        []  'pacmOz000Basic' then {PacmOz000Basic.getPort Init}
        []  'ghOzt055Basic' then {GhOzt055Basic.getPort Init}
        []  'pacmOz055Basic' then {PacmOz055Basic.getPort Init}
        else
            {System.show 'Unknown BotName'}
            false
        end
    end
end