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
            X Y R HasGum CurrentAgent 

            fun {ModPos AgentState}
                agentState(id:Id x:Ax y:Ay type:TYPE port:PORT alive:ALIVE) = AgentState
            in
                agentState(id:Id x:Ax+X y:Ay+Y type:TYPE port:PORT alive:ALIVE)
            end

            fun {ModGum Item}
                gum(alive:ALIVE) = Item
            in
                gum(alive:false) 
            end

            CurrentAgent = State.tracker.Id
            ItemsRecord = State.items
            UpdatedState 

        in
            if Dir==north then X=0 Y=~1 end 
            if Dir==south then X=0 Y=1 end 
            if Dir==east then X=1 Y=0 end
            if Dir==west then X=~1 Y=0 end 

            % verifies if a pacgum is in the pacmoz pos to eliminate it 
            if CurrentAgent.type == 'pacmoz' then 
                
                HasGum = CurrentAgent.x+ CurrentAgent.y*28 % calculates the pacmoz pos 
                
                

                if {HasFeature ItemsRecord HasGum}then T in %checks if the pacmoz pos is also a pacgum 
                    T={Record.subtract ItemsRecord HasGum} % removes the HasGum from the record and returns the new record
                    UpdatedState={AdjoinAt{AdjoinAt State items {AdjoinAt T ngum  T.ngum-1} } score State.score+100} %updates the state record by adding the new updated items record and also changes the score by adding 100
                    
                    {UpdatedState.gui dispawnPacgum(CurrentAgent.x CurrentAgent.y)} % dispawns the pacgum

                    {UpdatedState.gui updateScore(UpdatedState.score)} % updates the score
                end 

            end 

            {State.gui moveBot(Id Dir)}


            if {IsDet UpdatedState} then % if the UpdateState is bounded  adjoint the tracker to the new UpdatedState at the trcker pos
                R={List.toRecord agentState {List.mapInd {AgentStateModification {Record.toList UpdatedState.tracker} Id ModPos} fun {$ I A} I#A end}}%Transforms the agents state to List then modifies it and makes it a record again
                {GameController {AdjoinAt UpdatedState tracker R}}
            else 
                R={List.toRecord agentState {List.mapInd {AgentStateModification {Record.toList State.tracker} Id ModPos} fun {$ I A} I#A end}}%Transforms the agents state to List then modifies it and makes it a record again
                {GameController {AdjoinAt State tracker R}}
            end
        end

        % function to handle the movedTo message
        %movedTo(Id Type X Y): The Game Controller broadcasts movedT o(< id >< type >< int >< int > to every agent in the Maze
        fun {MovedTo movedTo(ID TYPE X Y)}
            {Broadcast State.tracker movedTo(ID TYPE X Y)}
            {GameController State}
        end

        fun {Haunt haunt(PacmozId GhOztId)}
        %     PacmozId ={CheckPacmOz State.tracker State.tracker.2.x State.tracker.2.y}
        % in
        %     {System.show PacmozId}
        %      if PacmozId \= 0 then
        %          {Broadcast State.tracker gotHaunted(PacmozId)}
        %          {State.gui dispawnBot(PacmozId)}
        %      end
            
            {GameController State}
        end

        fun {Incense incense(PacmozId GhOztId)}

            {GameController State}
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
            %state.tracker liste des jouerus
            {Broadcast State.tracker pacgumSpawned(X Y)}
            {GameController {AdjoinAt State 'items' NewItems}}
        end

        fun {PacgumDispawned pacgumDispawned(X Y)}
            %{System.show 'pacgumDispawned(X Y)'}
            {Broadcast State.tracker pacgumDispawned(X Y)}

            {GameController State}
        end
       
        fun {PacpowSpawned pacpowSpawned(X Y)}
            {GameController State}
        end
        fun {PacpowDispawned pacpowDispawned(X Y)}
            % {Broadcast State.tracker pacpowDispawned(X Y)}

            % {State.gui pacpowDispawned(X Y)}
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
                
                %%{System.show Msg}
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
