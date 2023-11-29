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
         if {IsValidMove G_X G_Y+1 State north} then  South ={CalculateShortestDistance G_X G_Y+1 P_X P_Y} else South= 9999.0 end
         if {IsValidMove G_X G_Y-1 State south} then North ={CalculateShortestDistance G_X G_Y-1 P_X P_Y} else North=9999.0 end
         if {IsValidMove G_X-1 G_Y State east} then West ={CalculateShortestDistance G_X-1 G_Y P_X P_Y} else West=9999.0 end
         if {IsValidMove G_X+1 G_Y State west} then East ={CalculateShortestDistance G_X+1 G_Y P_X P_Y} else East = 9999.0 end
        ShortestPath = {GetMinDir South North West East}
    end
    fun{GetMinDir South North West East}
        UpRight DownLeft Result
        {System.show 'S'#South#'N'#North#'W'#West#'E'#East}
    in 
        if South =< East then UpRight=state(dist:South dir:south) else UpRight=state(dist: East dir:east) end
        if North < West then DownLeft=state(dist:North dir:north) else DownLeft=state(dist: West dir:west) end    

        if UpRight.dist =< DownLeft.dist then Result=UpRight.dir else Result=DownLeft.dir end
        Result
    end 
    fun{CalculateShortestDistance CurrentX CurrentY TargetX TargetY}
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
        {System.show prevMove}
        if PrevMove==InvMove then false 
        else if {List.nth Maze PosMaze} \=1 then true else false  end end
    end
    % TODO: Complete this concurrent functional agent (PacmOz/GhOzt)
    fun {Agent State}
        fun {MovedTo Msg}
            Dir
        in 
            if State.id == Msg.1  then
                Dir={MoveTowardsThePacmOz Msg.3 Msg.4 1 1 State}
                {Wait Dir}
                {Send State.gcport moveTo(State.id Dir)}
                {Agent {AdjoinAt State 'prevMove' Dir}}
            else 
                {Agent State}
            
            end 
            
    
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
    
    fun {SpawnAgent init(Id GCPort Maze )}
        Stream
        Port = {NewPort Stream}

        Instance = {Agent state(
            'id': Id
            'maze': Maze
            'gcport': GCPort
            'prevMove':south
        )}
    in
        thread {Handler Stream Instance} end
        Port
    end
end
