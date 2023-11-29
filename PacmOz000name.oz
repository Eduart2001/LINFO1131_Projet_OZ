functor

import
    OS
    System
export
    'getPort': SpawnAgent
define

    % Feel free to modify it as much as you want to build your own agents :) !

    % Helper => returns an integer between [0, N]
    fun {GetRandInt N} {OS.rand} mod N end
    
    % TODO: Complete this concurrent functional agent (PacmOz/GhOzt)
    fun {Agent State}
        fun {MovedTo Msg}
            % Msg = movedTo(<id> <type> <x> <y>)
            % if State.id ==Msg.1  then 
            %     %{Send State.gcport moveTo(State.id 'south')}
            % end
            {Agent State}
        end

        %adding the messages to handle 
        fun {GotHaunted Msg} 
            RandInt = {GetRandInt 10}
        in
            %{System.show log(RandInt Msg)}
            {Agent State}
        end
    
        fun {GotIncensed Msg}
            RandInt = {GetRandInt 10}
        in
            %{System.show log(RandInt Msg)}
            {Agent State} 
        end
    
        fun {PacGumSpawned Msg}
            RandInt = {GetRandInt 10}
        in
            %{System.show log(RandInt Msg)}
            {Agent State} 
        end
    
        fun {PacGumDispawned Msg}
            RandInt = {GetRandInt 10}
        in
            %{System.show log(RandInt Msg)}
            {Agent State}
        end
    
        fun {PacPowSpawned Msg} 
            RandInt = {GetRandInt 10}
        in
            %{System.show log(RandInt Msg)}
            {Agent State}
        end 
        fun {PacPowDown Msg}
            RandInt = {GetRandInt 10}
        in
            %{System.show log(RandInt Msg)}
            {Agent State}
        end
        fun {TellTeam Msg}
            RandInt = {GetRandInt 10}
        in
            %{System.show log(RandInt Msg)}
            {Agent State}
        end
        fun {Haunt Msg}
            RandInt = {GetRandInt 10}
        in
            %{System.show log(RandInt Msg)}
            {Agent State}
        end
        fun {Shutdown Msg}
            RandInt = {GetRandInt 10}
        in
            %{System.show log(RandInt Msg)}
            {Agent State}
        end
        fun {InvalidAction Msg}
            RandInt = {GetRandInt 10}
        in
            %{System.show log(RandInt Msg)}
            {Agent State}
        end 
    in
        % TODO: complete the interface and discard and report unknown messages
        %adding messages Pdf 4.4
        fun {$ Msg}
            Dispatch = {Label Msg}
            Interface = interface(
                'movedTo': MovedTo
                'gotHaunted': GotHaunted
                'gotIncensed': GotIncensed
                'pacgumSpawned': PacGumSpawned
                'pacgumDispawned': PacGumDispawned
                'pacpowSpawned': PacPowSpawned
                'pacpowDown': PacPowDown
                'tellTeam': TellTeam
                'haunt': Haunt
                'shutdown': Shutdown
                'invalidAction': InvalidAction
            )
        in
            {Interface.Dispatch Msg}
        end
    end

    % Please note: Msg | Upcoming is a pattern match of the Stream argument
    proc {Handler Msg | Upcoming Instance}
        if Msg \= shutdown() then {Handler Upcoming {Instance Msg}} end
    end

    fun {SpawnAgent init(Id GCPort Maze)}
        Stream
        Port = {NewPort Stream}

        Instance = {Agent state(
            'id': Id
            'maze': Maze
            'gcport': GCPort
        )}
    in
        thread {Handler Stream Instance} end
        Port
    end
end
