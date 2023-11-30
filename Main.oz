functor

import
    Input
    System
    Graphics
    AgentManager
    Application
    OS
define
     % Check the Adjoin and AdjoinAt function, documentation: (http://mozart2.org/mozart-v1/doc-1.4.0/base/record.html#section.records.records)
    %liste des joueurs 
    proc {Broadcast Tracker Msg}
        {Record.forAll Tracker proc {$ Tracked} if Tracked.alive then {Send Tracked.port Msg} end end}
    end
    % TODO: define here any auxiliary functions or procedures you may need
    %...


    %Function to modify agents states based on a function
    fun {AgentStateModification AgentsState WantedID Function}
        case AgentsState
        of nil then nil
        [] agentState(alive:_ id:ID  port:_ type:_ x:_ y:_)|T then
            if (ID== WantedID) then
                {Function AgentsState.1}|T
            else 
                AgentsState.1|{AgentStateModification T WantedID Function}
            end
        end
    end


    fun {CheckPacmOz Tracker G_X G_Y}
        Id
    in    
        {Record.forAll Tracker proc {$ Tracked} if {And Tracked.alive Tracked.type \= ghozt}then if {And Tracked.x == G_X  Tracked.y == G_Y} then Id = Tracked.id end  end end}
        if {IsDet Id} then  Id else 0 end
    end



    % TODO: Complete this concurrent functional agent to handle all the message-passing between the GUI and the Agents
    fun {GameController State}


        % function to handle the moveTo message
        fun {MoveTo moveTo(Id Dir)}
            X Y R 
            fun {ModPos AgentState}
                agentState(id:Id x:Ax y:Ay type:TYPE port:PORT alive:ALIVE) = AgentState
            in
                agentState(id:Id x:Ax+X y:Ay+Y type:TYPE port:PORT alive:ALIVE)
            end
        in
            if Dir==north then X=0 Y=~1 end 
            if Dir==south then X=0 Y=1 end 
            if Dir==east then X=1 Y=0 end
            if Dir==west then X=~1 Y=0 end 

            {State.gui moveBot(Id Dir)}

            R={List.toRecord agentState {List.mapInd {AgentStateModification {Record.toList State.tracker} Id ModPos} fun {$ I A} I#A end}} %Transforms the agents state to List then modifies it and makes it a record again

            {System.show R}
            {GameController {AdjoinAt State tracker R}}
        end


        % function to handle the PacGumSpawned message
        fun {PacgumSpawned pacgumSpawned(X Y)}
            Index = Y * 28 + X
            NewItems
            if {HasFeature State 'items'} then 
                NewItems = {Adjoin State.items items(Index: gum('alive': true) 'ngum': State.items.ngum +1)}
            else
                NewItems = items(Index: gum('alive': true) 'ngum': 1)
            end
        in
            %steate.tracker liste des jouerus
            {Broadcast State.tracker pacgumSpawned(X Y)}
            {GameController {AdjoinAt State 'items' NewItems}}
        end

        % function to handle the movedTo message
        %movedTo(Id Type X Y): The Game Controller broadcasts movedT o(< id >< type >< int >< int > to every agent in the Maze
        fun {MovedTo movedTo(ID TYPE X Y)}

            {Broadcast State.tracker movedTo(ID TYPE X Y)}
            {GameController State}
        end

        fun {Haunt haunt(PacmozId GhOztId)}
            PacmozId ={CheckPacmOz State.tracker State.tracker.2.x State.tracker.2.y}
        in
            {System.show PacmozId}
             if PacmozId \= 0 then
                 {State.gui dispawnBot(PacmozId)}
                 %{Broadcast State.tracker gotHaunted(PacmozId)}
             end
            
            {GameController State}
        end
        fun {Incense incense(PacmozId GhOztId)}

            {GameController State}
        end
        fun {PacgumDispawned pacgumDispawned(X Y)}
            {GameController State}
        end
        fun {PacpowSpawned pacpowSpawned(X Y)}
            {GameController State}
        end
        fun {PacpowDispawned pacpowDispawned(X Y)}
            {GameController State}
        end
        fun {PacpowDown pacpowDown(X Y)}
            {GameController State}
        end

        fun {TellTeam tellTeam(Id Record)}
            {GameController State}
        end
        %
        % TODO: add other functions to handle the messages here
        %...
    
    in
        % TODO: complete the interface and discard and report unknown messages
        % every function is a field in the interface() record
        fun {$ Msg}
            Dispatch = {Label Msg}
            Interface = interface(
                'moveTo': MoveTo
                'movedTo': MovedTo
                'pacgumSpawned': PacgumSpawned
                'haunt':Haunt
                'incense':Incense
                'pacgumDispawned':PacgumDispawned
                'pacpowSpawned':PacpowSpawned
                'pacpowDispawned':PacpowDispawned
                'pacpowDown':PacpowDown
                'tellTeam':TellTeam

                %TODO: add other messages here
                %...
            )
        in
            if {HasFeature Interface Dispatch} then
                %{System.show 'interface:'#Interface#' Dispatch:'#Dispatch#'Msg:'#Msg}
                {Interface.Dispatch Msg}
            else
                % {System.show log('Unhandle message' Dispatch)}
                {GameController State}
            end
        end
    end

    % Please note: Msg | Upcoming is a pattern match of the Stream argument
    proc {Handler Msg | Upcoming Instance}
        {Handler Upcoming {Instance Msg}}
    end
    % Add bots to their port and also to the GUI
    fun {DoListBot Bots GameControllerPort Maze GUI}
        case Bots 
        of nil then nil
        [] H|T then ID in 
            ID={GUI spawnBot(H.1 H.3 H.4 $)} %spawn the bot H and returns its Id
            {Wait ID}
		    agent(
                id:ID   %agent ID
                x:H.3   %agent x pos
                y:H.4   %agent y pos
                type:H.1   %agent type
                port:{AgentManager.spawnBot H.2 init(ID GameControllerPort Maze)}
                )|{DoListBot T GameControllerPort Maze GUI}
        end
	end

	fun {InitAgents Agents}
        case Agents
        of nil then nil
        [] Agent|T then
                agentState(
                    alive: true % ?
                    % TODO: add fields
                    id:Agent.id
                    x:Agent.x 
                    y:Agent.y
                    type:Agent.type
                    port: Agent.port
                    )|{InitAgents T}
		end
	end

    % TODO: Spawn the agents
    proc {StartGame}
        Stream
        Port = {NewPort Stream}
        GUI = {Graphics.spawn Port 30}

        Maze = {Input.genMaze}
        {GUI buildMaze(Maze)}

    

        % init the agents (returns a list the agents' ports)
        Agents = {DoListBot Input.bots Port Maze GUI}
        % init the state record for all agents
        AgentsState = {List.toRecord agentState {List.mapInd {InitAgents Agents} fun {$ I A} I#A end}}
        Instance = {GameController state(
            'gui': GUI
            'maze': Maze
            'score': 0
            'tracker': AgentsState
        )}
        
    in
        % TODO: log the winning team name and the score then use {Application.exit 0}
        {Handler Stream Instance}
    end

    {StartGame}
end
