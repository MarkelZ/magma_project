
function MakePrimedFan(G,v,x0,alpha)
  F := <alpha,v,x0>;
  k := 0;
  primedF := false;
  
  while not primedF do
    beta := Random(M(F[3+k]));
    if beta in M(v) then
      Append(~F, beta);
      primedF := true;
    else 
      e := Random({e : e in IncidentEdges(v) | IsLabelled(e) and Label(e) eq beta});
      xkplus1 := Random(Exclude(EndVertices(e), v));
      if exists{i : i in [2 .. 2+k] | F[i] eq xkplus1} then
        Append(~F, beta);
        primedF := true;
      else 
        Append(~F,xkplus1);
        k := k+1;
      end if;
    end if;
  end while;

  return F;

end function;


function ActivateCFan(G,d,F)
  
end function;

function ColorOne(G, d)
  // choose uncolored edge vx_0
  uncoloredEdge := 0;
  for e in EdgeSet(G) do
    if not IsLabelled(e) then
      uncoloredEdge = e;
      break;
    end if;
  end for;

  v := InitialVertex(e);
  x0 := TerminalVertex(e);
  // Choose any \alpha \in M(v)
  alpha := Random(M(v));

  F := MakePrimedFan(G,v,x0,\alpha)

  // ActivateCFan(F)
end function;