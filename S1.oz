
%Threads and declarative currency

%1)

    local X Y Z in
        thread if X==1 then Y=2 else Y=2 end end 
        thread if Y==1 then X=1 else Z=2 end end 
        X=1

        % {Browse X}
        % {Browse Y}
        % {Browse Z}
    end

%2)

% declare 
% fun {List T}
%     {Wait 2000}
%     T |{List T+1}
% end
% local X in 
%     thread X={List 0}end
%     {Browse X}
% end

%Message parsing
%1)
declare 
P S 
{NewPort S P}
{Send P foo}
{Send P bar}

{Browse S}

%2)Implement the function WaitTwo 
declare
 X Y
fun {WaitTwo X Y }
    S
    PORT={NewPort S}
in
    thread {Wait X} {Send PORT 1}end
    thread {Wait Y} {Send PORT 2}end
    S.1
end

R={WaitTwo X Y}
{Browse R}
X=1
Y=2

declare
fun {Prod N}
    {Browse N}
    {Wait 1000}
    N|{Prod N+1}
    end
fun {Cons S}
    case S of H|T then
    {Browse H}
    {Cons T}
    end
end
thread S={Prod 1} end