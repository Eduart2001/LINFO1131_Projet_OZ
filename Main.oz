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

    % TODO: Complete this concurrent functional agent to handle all the message-passing between the GUI and the Agents
    fun {GameController State}
        fun {MoveTo moveTo(Id Dir)}
            {State.gui moveBot(Id Dir)}
            {GameController State}
        end
        % function to handle the PacGumSpawned message
        fun {PacgumSpawned pacgumSpawned(X Y)}
            Index = Y * 28 + X
            NewItems = {Adjoin State.items items(Index: gum('alive': true) 'ngum': State.items.ngum + 1)}
        in
            %steate.tracker liste des jouerus
            {Broadcast State.tracker pacgumSpawned(X Y)}
            {GameController {AdjoinAt State 'items' NewItems}}
        end

        % function to handle the movedTo message

        % fun {movedTo Id Type X Y}

        % in

        % end
        
        %
        % TODO: add other functions to handle the messages here
        %...
        
        % function to handle the movedTo message    % TODO: Complete this concurrent functional agent to handle all the message-passing between the GUI and the Agents
        fun {MovedTo movedTo(Id Type X Y)}
            {System.show log(Id Type X Y)}

            
            % Create a NewState record with Adjoin/AdjoinAt function and return it
            {GameController State}
        end
    in
        % TODO: complete the interface and discard and report unknown messages
        % every function is a field in the interface() record
        fun {$ Msg}
            Dispatch = {Label Msg}
            Interface = interface(
                'moveTo': MoveTo
                'movedTo': MovedTo
                'pacgumSpawned': PacgumSpawned
                %TODO: add other messages here
                %...
            )
        in
            if {HasFeature Msg Dispatch} then
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
		    {AgentManager.spawnBot H.2 init(ID GameControllerPort Maze)}|{DoListBot T GameControllerPort Maze GUI}
        end
	end

	fun {InitAgents Ports}
        case Ports
        of nil then nil
        [] Port|T then
                playerState(
                    alive: true % ?
                    % TODO: add fields
                    port: Port
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
        AgentsState = {InitAgents Agents} 

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
