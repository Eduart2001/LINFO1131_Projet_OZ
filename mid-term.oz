declare 
fun{Prod N}
   {Delay 1000}
   N|{Prod N+1}
end
fun{Cons S}
    case S of H|T then 
        H|{Cons T}
    end
end 
declare S S1 in
thread S={Prod 1} end
thread S1={Cons S} end
thread {Browse S1}end


declare

fun lazy {Times S N}
    case S of H|T then
    N*H|{Times T N}
    end
end
fun lazy {Merge S1 S2}
    case S1|S2 of (H1|T1)|(H2|T2) then
        if H1<H2 then
            H1|{Merge T1 S2}
        elseif H1>H2 then
        H2|{Merge S1 T2}
            else
        /* H1==H2 */
        H1|{Merge T1 T2}
        end
    end
end

declare 

H=1|{Merge
        {Times H 2}
        {Merge {Times H 3}
                {Times H 5}}
    }
{Browse H}

declare
local
    proc {Ping L}
        case L of H|T then T2 in
            {Delay 500} {Browse ping}
            T=_|T2
            {Ping T}
        end
    end
    
    proc {Pong L}
        case L of H|T then T2 in
            {Browse pong}
            T=_|T2
            {Pong T2}
        end
    end
    
    L
in    
    thread {Ping L} end
    thread {Pong L} end
    L=_|_

end

declare
fun {GetRandInt 10}
    12
end
fun {Agent State}
    fun {MovedTo Msg}
        RandInt = {GetRandInt 10}
    in
        {System.show log(RandInt 'Msg'#Msg)}
        {Agent State}
    end

    %adding the messages to handle 
    fun {GotHaunted Msg} 
        RandInt = {GetRandInt 10}
    in
        {Browse  log(RandInt Msg)}
        {Agent State}
    end

    fun {GotIncensed Msg}
        RandInt = {GetRandInt 10}
    in
        {System.show log(RandInt Msg)}
        {Agent State} 
    end

    fun {PacGumSpawned Msg}
        RandInt = {GetRandInt 10}
    in
        {System.show log(RandInt Msg)}
        {Agent State} 
    end

    fun {PacGumDispawned Msg}
        RandInt = {GetRandInt 10}
    in
        {System.show log(RandInt Msg)}
        {Agent State}
    end

    fun {PacPowSpawned Msg} 
        RandInt = {GetRandInt 10}
    in
        {System.show log(RandInt Msg)}
        {Agent State}
    end 
    fun {PacPowDown Msg}
        RandInt = {GetRandInt 10}
    in
        {System.show log(RandInt Msg)}
        {Agent State}
    end
    fun {TellTeam Msg}
        RandInt = {GetRandInt 10}
    in
        {System.show log(RandInt Msg)}
        {Agent State}
    end
    fun {Haunt Msg}
        RandInt = {GetRandInt 10}
    in
        {System.show log(RandInt Msg)}
        {Agent State}
    end
    fun {Shutdown Msg}
        RandInt = {GetRandInt 10}
    in
        {System.show log(RandInt Msg)}
        {Agent State}
    end
    fun {InvalidAction Msg}
        RandInt = {GetRandInt 10}
    in
        {System.show log(RandInt Msg)}
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
declare
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

    {Send Port 'movedTo'}
    
in
    thread {Handler Stream Instance} end
    {Browse'Player ID'#init(GCPort)}
    Port
end

declare 

R ={SpawnAgent init(1 vd maaze)}



declare

class Graphics
    attr
        'buffer' 'buffered' 'canvas' 'window'
        'score' 'scoreHandle'
        'ids' 'gameObjects'
        'background'
        'running'
        'gcPort'
    
    meth init(GCPort)
        Height = 928
        Width = 896
    in
        'running' := true
        'gcPort' := GCPort

        'buffer' := {QTk.newImage photo('width': Width 'height': Height)}
        'buffered' := {QTk.newImage photo('width': Width 'height': Height)}

        'window' := {QTk.build td(
            canvas(
                'handle': @canvas
                'width': Width
                'height': Height
                'background': 'black'
            )
            button(
                'text': "close"
                'action' : proc {$} {Application.exit 0} end
            )
        )}

        'score' := 0
        {@canvas create('image' Width div 2 Height div 2 'image': @buffer)}
        {@canvas create('text' 128 16 'text': 'score: 0' 'fill': 'white' 'font': FONT 'handle': @scoreHandle)}
        'background' := {QTk.newImage photo('width': Width 'height': Height)}
        {@window 'show'}

        'gameObjects' := {Dictionary.new}
        'ids' := 0
    end

    meth isRunning($) @running end

    meth genId($)
        'ids' := @ids + 1
        @ids
    end

    meth spawnPacgum(X Y)
        {@background copy(PACGUM_SPRITE 'to': o(X * 32 Y * 32))}
        {Send @gcPort pacgumSpawned(X Y)}
    end

    meth dispawnPacgum(X Y)
        {@background copy(GROUND_TILE 'to': o(X * 32 Y * 32))}
        {Send @gcPort pacgumDispawned(X Y)}
    end

    meth spawnPacpow(X Y)
        {@background copy(PACPOW_SPRITE 'to': o(X * 32 Y * 32))}
        {Send @gcPort pacpowSpawned(X Y)}
    end

    meth setAllScared(Value)
        GameObjects = {Dictionary.items @gameObjects}
    in
        for Gobj in GameObjects do
            if {Gobj getType($)} == 'ghost' then
                {Gobj setScared(Value)}
            end
        end
    end

    meth dispawnPacpow(X Y)
        {self setAllScared(true)}
        thread
            {Delay 3000}
            {Send @gcPort pacpowDown()}
            {Delay 7000}
            {self spawnPacpow(X Y)}
        end
        {@background copy(GROUND_TILE 'to': o(X * 32 Y * 32))}
        {Send @gcPort pacpowDispawned(X Y)}
    end

    meth buildMaze(Maze)
        Z = {NewCell 0}
    in
        for K in Maze do
            X = @Z mod 28
            Y = @Z div 28
        in
            if K == 0 then
                {@background copy(GROUND_TILE 'to': o(X * 32 Y * 32))}
                {self spawnPacgum(X Y)}
            elseif K == 1 then
                {@background copy(WALL_TILE 'to': o(X * 32 Y * 32))}
            elseif K == 2 then
                {@background copy(GROUND_TILE 'to': o(X * 32 Y * 32))}
                {self spawnPacpow(X Y)}
            end
            Z := @Z + 1
        end
    end

    meth spawnBot(Type X Y $)
        Bot
        Id = {self genId($)}
    in
        if Type == 'pacmoz' then
            Bot = {New Pacmoz init(Id X * 32 Y * 32)}
        else
            Bot = {New Ghost init(Id X * 32 Y * 32)}
        end

        {Dictionary.put @gameObjects Id Bot}
        {Send @gcPort movedTo(Id Type X Y)}
        Id
    end

    meth dispawnBot(Id)
        {Dictionary.remove @gameObjects Id}
    end

    meth moveBot(Id Dir)
        Bot = {Dictionary.condGet @gameObjects Id 'null'}
    in
        if Bot \= 'null' then
            {Bot setTarget(Dir)}
        end
    end

    meth updateScore(Score)
        'score' := Score
        {@scoreHandle set('text': "score: " # @score)}
    end

    meth update()
        GameObjects = {Dictionary.items @gameObjects}
    in
        {@buffered copy(@background 'to': o(0 0))}
        for Gobj in GameObjects do
            {Gobj update(@gcPort)}
            {Gobj render(@buffered)}
        end
        {@buffer copy(@buffered 'to': o(0 0))}
    end
end