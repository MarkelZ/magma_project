
procedure FlipABPath(~G, v, alpha, beta, ~w)
  currentVertex := v;
  hasNext := true;
  nextColour := alpha;
  while hasNext do
    // Find incident edge with label nextColour
    es := [ e : e in IncidentEdges(currentVertex) | IsLabelled(e) and Label(e) eq nextColour ];
    if #es eq 0 then
      w := currentVertex;
      hasNext := false;
    else
      // we assumed there is only one such e
      e := es[1];
      currentVertex := Random(Exclude(EndVertices(e),currentVertex));
      if nextColour eq alpha then
        nextColour := beta;
      else
        nextColour := alpha;
      end if;
    end if;
  end while;

end procedure;

// u-fan F = <alpha, v, xs>
// color beta in M(v)
procedure ActivateUFan(~G, ~F, beta)
  // Unpack F, this is hopefully by reference
  alpha := F[1];
  v := F[2];
  xs := F[3];

  // Flip alpha-beta path beginning at v
  w := -1;
  FlipABPath(~G, F, alpha, beta, ~w);
  
  // If w is a leaf of F then Remove w from F
  Exclude(~xs, w);
  
  // Pick any leaf x of F and color vx by alpha
  x := xs[1];
  vx := EdgeSet(G)!{v, x};
  AssignLabel(~G, vx, alpha);
  
  // Remove x from F
  Exclude(~xs, x);

  F[3] := xs;
end procedure;

function MergeFans(F1, F2)
  // 4 cases
end function;

// This was copy-pasted from MakePrimedFan,
// TODO: make necessary changes
function MakeCollectionFan(v, x0, alpha, C)
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

function BuildCollection(G, alpha, I)
  C := {};
  S := I;
  for v in S do
    Exclude(~S, v);
    // Choose uncolored incident edge vx0
    vx0 := ;
    F := MakeCollectionFan(v, x0, alpha, C);
    if !IsNull(F) then
      Append(~C, F);
    end if;
  end for;
  
  return C;
end function;

procedure DisconnectVertex()

end procedure;

procedure ActivateCollection(~G, ~C)

end procedure;

procedure ColorMany(~G)
  // Choose alpha that maximizes |I|
  alpha := ;
  I := ;

  C := BuildCollection(G, alpha, I)
  ActivateCollection(~G, ~C);
end procedure;
