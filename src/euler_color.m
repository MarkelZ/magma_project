
function MakePrimedFan(G,v,x0,alpha)
  F := <alpha,v,[x0]>;
  k := 0;
  primedF := false;
  
  while not primedF do
    beta := Random(M(F[3][k+1]));
    if beta in M(v) then
      Append(~F, beta);
      primedF := true;
    else
      e := Random({e : e in IncidentEdges(v) | IsLabelled(e) and Label(e) eq beta});
      xkplus1 := Random(Exclude(EndVertices(e), v));
      if exists{i : i in [2 .. k+1] | F[3][i] eq xkplus1} then
        Append(~F, beta);
        primedF := true;
      else 
        Append(~F[3],xkplus1);
        k := k+1;
      end if;
    end if;
  end while;

  return F;

end function;

// Shift a primed fan from x_k
// F is of the form <alpha, v, [x_0,...,x_n],beta>
procedure ShiftFan(~G,F,k)
    v := F[2];
    E := EdgeSet(G);
    for i in [1 .. k] do
        AssignLabel(~G, E ! {v,F[3][i]}, Label(E ! {v,F[3][i+1]}));
    end for;
    DeleteLabel(~G, E ! {v,F[3][k+2]});
end procedure;

// F is of the form <alpha, v, [x_0,...,x_k],beta>
procedure ActivateCFan(~G,d,F)
    alpha := F[1];
    v := F[2];
    k := #F[3]+1;
    beta := F[4];
    if beta in M(v) then
        // shift F from x_k
        ShiftFan(~G,F,k);
        // color vx_k by beta
        AssignLabel(~G, EdgeSet(G) ! {v,F[3][k+1]}, beta);
    else
        // x_j s.t. vx_j is coloured beta
        e := Random([ e : e in IncidentEdges(v) | IsLabelled(e) and Label(e) eq beta ]);
        
        x_j := Random(Exclude(EndVertices(e), v));
        j := Index(F[3],x_j) - 1;
        // flip alphabeta-path P beginning at v, and save endpoint
        w := 1;
        FlipABPath(~G, v, beta, alpha,~w);
        
        if w ne "x_j-1" then
            // Shift F from x_j-1
            ShiftFan(~G,F,j-1);
            // color vx_j-1 by beta
            AssignLabel(~G, EdgeSet(G) ! {v, F[3][j]});
        else 
            // Shift F from x_k
            ShiftFan(~G,F,k);
            AssignLabel(~G, EdgeSet(G) ! {v, F[3][k+1]});
        end if;
    end if;
end procedure;

function ColorOne(G, d)
  // choose uncolored edge vx_0
  e := Random([e : e in EdgeSet(G) | not IsLabelled(e) ]);

  v := InitialVertex(e);
  x0 := TerminalVertex(e);
  // Choose any \alpha \in M(v)
  alpha := Random(M(v));

  F := MakePrimedFan(G,v,x0,alpha);
  
  ActivateCFan(F);
end function;