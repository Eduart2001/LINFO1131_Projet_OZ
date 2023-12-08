functor

import
    OS
    System
export
    'getPort': SpawnAgent
define

    % Feel free to modify it as much as you want to build your own agents :) !

    % Helper => returns an integer between [0, N[
    fun {GetRandInt N} {OS.rand} mod N end
    fun {IsValidMove X Y State InvMove} %invMove because a ghost can not do a 180° turn
        Maze =State.maze
        PosMaze= X+1+Y*28
        PrevMove=State.prevMove
    in
        {Wait PrevMove}
        if PrevMove==InvMove then false 
        else if {List.nth Maze PosMaze} \=1 then true else false  end end
    end

    % TODO: Complete this concurrent functional agent (PacmOz/GhOzt)
    fun {Agent State}
        fun {MovedTo Msg}
            RandInt
            Dir
            L
            fun {ModPos Msg}
                movedTo(Id Type X Y) = Msg
            in
                agent(id:Id type:Type x:X y:Y)
            end   

            fun {PossibleDirList List L}
                case List of nil then L
                [] state(valid:V move:M )|T then if V==true then {PossibleDirList T M|L} else {PossibleDirList T L} end
                end 
            end
            fun {SameBox Tracker Agent Agents}  

                case Tracker of nil then Agents    
                [] H|T then
                    if {And H.type \= Agent.type  H.id \= Agent.id} andthen {And Agent.x==H.x Agent.y==H.y} then
                        case State.pow of nil then 
                            {Send UpdatedState.gcport haunt(Agent.id H.id)}
                            {SameBox T Agent Agent.id|Agents}
                        else 
                            {Send UpdatedState.gcport incense(H.id Agent.id)}
                            {SameBox T Agent H.id|Agents}
                        end 
                    else 
                        {SameBox T Agent Agents}
                    end
                end
            end

            fun {RemoveFromRecord List Agents}
                case List of nil then Agents
                [] H|T then {RemoveFromRecord T {Record.subtract Agents H}}
                else List end
            end 
            CurrentAgent = {ModPos Msg}
            Id=CurrentAgent.id
            UpdatedState = {AdjoinAt State 'agents' {Adjoin State.agents agents(Id:CurrentAgent)}}
            Samebox
            UpdatedRecord 
        in
            %{System.show UpdatedState.agents}
            %Msg = movedTo(1#<id> 2#<type> 3#<x> 4#<y>)
            if State.id==CurrentAgent.id  then
                Samebox={SameBox {Record.toList UpdatedState.agents}  CurrentAgent nil}
                {Wait Samebox}
                UpdatedRecord={RemoveFromRecord Samebox UpdatedState.agents}
                {Wait UpdatedRecord}
                
                L ={PossibleDirList [state(valid:{IsValidMove CurrentAgent.x CurrentAgent.y+1 State north} move:south) state(valid:{IsValidMove CurrentAgent.x CurrentAgent.y-1 State south} move:north) state(valid:{IsValidMove CurrentAgent.x-1 CurrentAgent.y State east} move:west) state(valid:{IsValidMove CurrentAgent.x+1 CurrentAgent.y State west} move:east)]  nil}
                if L == nil then 
                    {Agent {AdjoinAt UpdatedState agents UpdatedRecord}}
                else 
                    
                    RandInt = {GetRandInt {List.length L}}+1  %so we will have a [1;{Length L}]
            
                    Dir={List.nth L RandInt}
                    {Send UpdatedState.gcport moveTo(UpdatedState.id Dir)}
                    {Agent {AdjoinAt {AdjoinAt UpdatedState agents UpdatedRecord} prevMove Dir}}
                end
 
            else 
                {Agent UpdatedState}

            end
        end

        %adding the messages to handle 
        fun {GotHaunted Msg} 
            {Agent State}
        end
    
        fun {GotIncensed Msg}
            {Agent State} 
        end
    
        fun {PacGumSpawned Msg}
            {Agent State} 
        end
    
        fun {PacGumDispawned Msg}
            {Agent State}
        end
    
        fun {PacPowSpawned Msg} 
            {Agent State}
        end 
        fun {PacPowDown Msg}
            {Agent {AdjoinAt State pow nil}}
        end
        fun {TellTeam Msg}
            {Agent State}
        end
        fun {Haunt Msg}
            {System.show Msg}
            {Agent State}
        end
        fun {Shutdown Msg}

            {Agent State}
        end
        fun {InvalidAction Msg}
            {Agent State}
        end 
        fun {PacpowDispawned pacpowDispawned(X Y)}
            {Agent {AdjoinAt State pow 1|State.pow}}
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
                'pacpowDispawned':PacpowDispawned
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
            'prevMove':none
            'agents':agents()
            'pow':nil
        )}
    in
        thread {Handler Stream Instance} end
        Port
    end
end
