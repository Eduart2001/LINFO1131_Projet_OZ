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

    fun {MoveTowardsThePacmOz G_X G_Y P_X P_Y State}
        South North West East  ShortestPath 
    in 
         if {IsValidMove G_X G_Y+1 State north} then  South ={CalculateDistance G_X G_Y+1 P_X P_Y} else South= 9999.0 end
         if {IsValidMove G_X G_Y-1 State south} then North ={CalculateDistance G_X G_Y-1 P_X P_Y} else North=9999.0 end
         if {IsValidMove G_X-1 G_Y State east} then West ={CalculateDistance G_X-1 G_Y P_X P_Y} else West=9999.0 end
         if {IsValidMove G_X+1 G_Y State west} then East ={CalculateDistance G_X+1 G_Y P_X P_Y} else East = 9999.0 end
        ShortestPath = {GetMinDir South North West East}
    end
    fun{GetMinDir South North West East}
        UpRight DownLeft Result
        %{System.show 'S'#South#'N'#North#'W'#West#'E'#East}
    in 
        if South =< East then UpRight=state(dist:South dir:south) else UpRight=state(dist: East dir:east) end
        if North < West then DownLeft=state(dist:North dir:north) else DownLeft=state(dist: West dir:west) end    

        if UpRight.dist =< DownLeft.dist then Result=UpRight.dir else Result=DownLeft.dir end
        Result
    end 
    fun{CalculateDistance CurrentX CurrentY TargetX TargetY}
        Result
        DeltaX2= {Pow (TargetX-CurrentX) 2 }
        DeltaY2={Pow (TargetY-CurrentY) 2 }
        Sum = DeltaX2+DeltaY2

    in     
        Result = {Sqrt {Int.toFloat Sum}}
    end 
    fun {IsValidMove X Y State InvMove} %invMove because a ghost can not do a 180° turn
        Maze =State.maze
        PosMaze= X+1+Y*28
        PrevMove=State.prevMove
    in
        {Wait PrevMove}
        %{System.show prevMove}
        if PrevMove==InvMove then false 
        else if {List.nth Maze PosMaze} \=1 then true else false  end end
    end

    % TODO: Complete this concurrent functional agent (PacmOz/GhOzt)
    fun {Agent State}
        fun {MovedTo Msg}
            RandInt
            Dir
            Closest
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
            fun {FindClosest Agent Agents Dist}
                K
            in
                case Agents of nil then Dist
                [] H|T then K = {CalculateDistance Agent.x Agent.y H.x H.y}  
                    if {And H.type \= Agent.type K =< Dist.dist} then
                        {FindClosest Agent T closest(id:H.id dist:K)}
                    else 
                        {FindClosest Agent T Dist}
                    end 
                end
            end
            
            CurrentAgent = {ModPos Msg}
            Id=CurrentAgent.id
            UpdatedState = {AdjoinAt State 'agents' {Adjoin State.agents agents(Id:CurrentAgent)}}
            Samebox
            UpdatedRecord 
            L
        in

            % if State.id==CurrentAgent.id  then

            %     if State.pow \= nil then 

            %         % if State.turned \= State.hasTurned then
            %         %     case State.prevMove of north then Dir=south
            %         %         []south then Dir=north
            %         %         []east then Dir=west
            %         %         []west then Dir=east 
            %         %     end
            %         %     {Send UpdatedState.gcport moveTo(UpdatedState.id Dir)}

            %         %         Samebox={SameBox {Record.toList UpdatedState.agents}  CurrentAgent nil}
            %         %         {Wait Samebox}
            %         %         UpdatedRecord={RemoveFromRecord Samebox UpdatedState.agents}
            %         %         {Wait UpdatedRecord}

            %         %     {Agent {AdjoinAt {AdjoinAt {AdjoinAt UpdatedState agents UpdatedRecord} hasTurned true} prevMove Dir}}
            %         % else 
            %             L ={PossibleDirList [state(valid:{IsValidMove CurrentAgent.x CurrentAgent.y+1 State north} move:south) state(valid:{IsValidMove CurrentAgent.x CurrentAgent.y-1 State south} move:north) state(valid:{IsValidMove CurrentAgent.x-1 CurrentAgent.y State east} move:west) state(valid:{IsValidMove CurrentAgent.x+1 CurrentAgent.y State west} move:east)]  nil}
            %             if L == nil then 
            %                 {Agent UpdatedState}
            %             else
                            
            %                 RandInt = {GetRandInt {List.length L}}+1  %so we will have a [1;{Length L}]
            %                 Dir={List.nth L RandInt}
            %                 {Send UpdatedState.gcport moveTo(UpdatedState.id Dir)}
            %                 Samebox={SameBox {Record.toList UpdatedState.agents}  CurrentAgent nil}
            %                 {Wait Samebox}
            %                 UpdatedRecord={RemoveFromRecord Samebox UpdatedState.agents}
            %                 {Wait UpdatedRecord}
            %                 {Agent {AdjoinAt {AdjoinAt UpdatedState agents UpdatedRecord} prevMove Dir}}
            %             end
            %         %end
            %     else 
            %         Closest={FindClosest CurrentAgent {Record.toList State.agents} closest(id:0 dist:9999.0)}.id
            %         if Closest \= 0 then
            %             Dir={MoveTowardsThePacmOz CurrentAgent.x CurrentAgent.y UpdatedRecord.Closest.x  UpdatedRecord.Closest.y UpdatedState}
            %             {Wait Dir}
            %             {Send UpdatedState.gcport moveTo(UpdatedState.id Dir)}
            %         end
            %         Samebox={SameBox {Record.toList UpdatedState.agents}  CurrentAgent nil}
            %         {Wait Samebox}
            %         UpdatedRecord={RemoveFromRecord Samebox UpdatedState.agents}
            %         {Wait UpdatedRecord}
            %         {Agent {AdjoinAt {AdjoinAt UpdatedState 'prevMove' Dir} agents UpdatedRecord}}
            %     end
            % else 
            %     {Agent State}
            % end 




            if State.id==CurrentAgent.id  then

                
                L ={PossibleDirList [state(valid:{IsValidMove CurrentAgent.x CurrentAgent.y+1 State north} move:south) state(valid:{IsValidMove CurrentAgent.x CurrentAgent.y-1 State south} move:north) state(valid:{IsValidMove CurrentAgent.x-1 CurrentAgent.y State east} move:west) state(valid:{IsValidMove CurrentAgent.x+1 CurrentAgent.y State west} move:east)]  nil}
                if L == nil then
                    {Send UpdatedState.gcport moveTo(UpdatedState.id none)}
                    {Agent UpdatedState}
                else 
                    
                    RandInt = {GetRandInt {List.length L}}+1  %so we will have a [1;{Length L}]
                    Dir={List.nth L RandInt}
                    {Send UpdatedState.gcport moveTo(UpdatedState.id Dir)}
                    Samebox={SameBox {Record.toList UpdatedState.agents}  CurrentAgent nil}
                    {Wait Samebox}
                    UpdatedRecord={RemoveFromRecord Samebox UpdatedState.agents}
                    {Wait UpdatedRecord}
                    {Agent {AdjoinAt {AdjoinAt UpdatedState agents UpdatedRecord} prevMove Dir}}
                end


            else 
                {Agent UpdatedState}

            end




            % %{System.show UpdatedState.agents}
            % %Msg = movedTo(1#<id> 2#<type> 3#<x> 4#<y>)
            % if State.id==CurrentAgent.id  then

                
            %     if UpdatedState.pow \=nil then 
            %             if State.turned \= State.hasTurned then
            %                 case State.prevMove of north then Dir=south
            %                 []south then Dir=north
            %                 []east then Dir=west
            %                 []west then Dir=east 
            %                 end
            %                 {Send UpdatedState.gcport moveTo(UpdatedState.id Dir)}
            %                 {Agent {AdjoinAt {AdjoinAt UpdatedState hasTurned true} prevMove Dir}}
            %             else
                            
            %                 RandInt = {GetRandInt {List.length L}}+1  %so we will have a [1;{Length L}]
            %                 Dir={List.nth L RandInt}
            %                 {Send UpdatedState.gcport moveTo(UpdatedState.id Dir)}
            %                 Samebox={SameBox {Record.toList UpdatedState.agents}  CurrentAgent nil}
            %                 {Wait Samebox}
            %                 UpdatedRecord={RemoveFromRecord Samebox UpdatedState.agents}
            %                 {Wait UpdatedRecord}

            %                 {Agent {AdjoinAt {AdjoinAt UpdatedState agents UpdatedRecord} prevMove Dir}}
            %             end

            %     else
            %         %{Send State.gcport tellTeam(CurrentAgent.id)}
            %         Closest={FindClosest CurrentAgent {Record.toList State.agents} closest(id:0 dist:9999.0)}.id
            %         {System.show Closest}
            %         if Closest \= 0 then
            %             Dir={MoveTowardsThePacmOz CurrentAgent.x CurrentAgent.y UpdatedRecord.Closest.x  UpdatedRecord.Closest.y UpdatedState}
            %             {Wait Dir}
            %             {Send UpdatedState.gcport moveTo(UpdatedState.id Dir)}
            %         end
            %         Samebox={SameBox {Record.toList UpdatedState.agents}  CurrentAgent nil}
            %         {Wait Samebox}
            %         UpdatedRecord={RemoveFromRecord Samebox UpdatedState.agents}
            %         {Wait UpdatedRecord}
            %         {Agent {AdjoinAt {AdjoinAt UpdatedState 'prevMove' Dir} agents UpdatedRecord}}
            %     end
           
            % else   
            %     {Agent UpdatedState}

            % end
        end
    
        fun {GotHaunted Msg} 
            {Agent {AdjoinAt State agents {Record.subtract State.agents Msg.1}}}
        end
    
        fun {GotIncensed Msg}
            {Agent {AdjoinAt State agents {Record.subtract State.agents Msg.1}}}
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
            {Agent {AdjoinAt {AdjoinAt {AdjoinAt State turned false} hasTurned false } pow nil}}
        end
        fun {TellTeam Msg}
            {Agent State}
        end
        fun {Haunt Msg}
            {System.show Msg}
            {Agent State}
        end
        fun {InvalidAction Msg}
            {System.show 'The action you tried to perform is invalid : '#Msg}
            {Agent State}
        end 
        fun {PacpowDispawned pacpowDispawned(X Y)}
            {Agent {AdjoinAt {AdjoinAt State turned true} pow 1|State.pow}}
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
            'turned':false
            'hasTurned':false
            'agents':agents()
            'pow':nil
        )}
    in
        thread {Handler Stream Instance} end
        Port
    end
end