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