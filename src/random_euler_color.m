function MakePrimedFan(G,d,v,x0,alpha)
  F := <alpha,v,[x0]>;
  k := 0;
  primedF := false;
  
  while not primedF do
    beta := Random(M(G, d, F[3][k+1]));
    if beta in M(G, d, v) then
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
    DeleteLabel(~G, E ! {v,F[3][k+1]});
end procedure;

// F is of the form <alpha, v, [x_0,...,x_k],beta>
procedure ActivateCFan(~G,d,F)
    alpha := F[1];
    v := F[2];
    k := #F[3]-1;
    beta := F[4];
    if beta in M(G, d, v) then
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
        
        // if w ne x_j-1
        if w ne F[3][j] then
            // Shift F from x_j-1
            ShiftFan(~G,F,j-1);
            // color vx_j-1 by beta
            AssignLabel(~G, EdgeSet(G) ! {v, F[3][j]},beta);
        else 
            // Shift F from x_k
            ShiftFan(~G,F,k);
            AssignLabel(~G, EdgeSet(G) ! {v, F[3][k+1]},beta);
        end if;
    end if;
end procedure;

procedure RandomColorOne(~G, d)
  // choose uncolored edge vx_0
  e := Random([e : e in EdgeSet(G) | not IsLabelled(e) ]);

  v := InitialVertex(e);
  x0 := TerminalVertex(e);
  // Choose any \alpha \in M(v)
  alpha := Random(M(G,d,v));

  F := MakePrimedFan(G,d,v,x0,alpha);
  
  ActivateCFan(~G, d, F);
end procedure;

function EulerPartition(G)
  N := #VertexSet(G);
  G1 := EmptyGraph(N);
  G2 := EmptyGraph(N);
  E := EdgeSet(G);
  E1 := {}; 
  E2 := {};
  flag := 1;
  while #E gt 0 do
    e := Random(E);
    vs := Setseq(EndVertices(e));
    v1 := vs[1];
    v2 := vs[2];
    walk := [e];
    RemoveEdge(~G,e);
    E := EdgeSet(G);
    // Workaround solution to an "annoying consequence of the implementation" 
    v1 := VertexSet(G) ! Index(v1);
    while Degree(v1) ne 0 do
      e := Random(IncidentEdges(v1));
      v1 := Random(Exclude(EndVertices(e),v1));      
      Append(~walk, e);
      RemoveEdge(~G,e);
      E := EdgeSet(G);
      // Workaround solution to an "annoying consequence of the implementation" 
      v1 := VertexSet(G) ! Index(v1);
    end while;

    // Workaround solution to an "annoying consequence of the implementation" 
    v2 := VertexSet(G) ! Index(v2);
    while Degree(v2) ne 0 do
      e := Random(IncidentEdges(v2));
      v2 := Random(Exclude(EndVertices(e),v2));
      Insert(~walk, 1, e);
      RemoveEdge(~G,e);
      E := EdgeSet(G);
      // Workaround solution to an "annoying consequence of the implementation" 
      v2 := VertexSet(G) ! Index(v2);
    end while;
    for e in walk do
      vs := Setseq(EndVertices(e));
      v1 := vs[1];
      v2 := vs[2];
      if flag eq 1 then
        AddEdge(~G1, v1, v2);
        flag := 2;
      else
        AddEdge(~G2, v1, v2);
        flag := 1;
      end if;
    end for; 
  end while;  

  return G1,G2;
end function;


function RandomEulerColorRec(G, d, Colors, trace)
  // Base case
  if d le 1 then
      //print("Base case");
      color := Colors[1];
      for e in EdgeSet(G) do
        AssignLabel(~G,e,color);  
      end for;
      return G;
  end if;

  // Partition
  G1,G2 := EulerPartition(G);
  
  // Recurse
  d1 := Maxdeg(G1);
  d2 := Maxdeg(G2);
  Colors1 := Colors[1..Ceiling(d/2)+1];
  Colors2 := Colors[1..Ceiling(d/2)+1];

  G1 := RandomEulerColorRec(G1, d1, Colors1,trace * "L");
  G2 := RandomEulerColorRec(G2, d2, Colors2,trace * "R");
  
  // Make sure that colour sets are disjoint 
  G1Colors := { Label(e) : e in EdgeSet(G1) }; 
  G2Colors := { Label(e) : e in EdgeSet(G2) };
  common := Setseq(G1Colors meet G2Colors);
  freeColors := Setseq({1..2 * (Ceiling(d/2)+1)} diff (G1Colors join G2Colors));
  
  // Compute a mapping of labels 
  // The index of the next assignable free colour
  ix := 1;
  labelMapGraph := {};
  for c in G2Colors do
    if c in common then
      Include(~labelMapGraph, <c,freeColors[ix]>);
      ix := ix + 1;
    else
      Include(~labelMapGraph, <c,freeColors[ix]>);
    end if;
  end for;

  labelMap := map<G2Colors -> {1..2 * (Ceiling(d/2)+1)} | labelMapGraph>;

  for e in EdgeSet(G1) do
    AssignLabel(~G,e,Label(e));
  end for;
  for e in EdgeSet(G2) do
    AssignLabel(~G,e,labelMap(Label(e)));
  end for;

  Colors0 := Sort(EdgeLabels(G));
  Colors := [];

  i := 1;
  while i le #Colors0 do
    cAct := Colors0[i];
    n := 0;
    while i le #Colors0 and Colors0[i] eq cAct do
      n := n+1;
      i := i + 1;
    end while;
    Append(~Colors,[cAct,n]);
  end while;
  Sort(~Colors,func<x,y | x[2] - y[2]>);
  //print("==========================");
  while #Colors gt d+1 do
    c := Colors[1][1];
    Remove(~Colors,1);
    for e in EdgeSet(G) do 
      if IsLabelled(e) then
        if Label(e) eq c then
          DeleteLabel(~G,e);
        end if;
      end if;
    end for;
  end while;

  // Fix color indices
  col_vec:= [];
  for elem in Colors do
    Append(~col_vec, elem[1]);
  end for;

  for e in EdgeSet(G) do
    if IsLabelled(e) then
      k := Label(e);
      AssignLabel(~G, e, Index(col_vec, k));
    end if;
  end for;

  for i := 1 to #Colors do
    k := Colors[i][1];
    Colors[i][1] := Index(col_vec, k);
  end for;

  // Repair
  l := #[e : e in EdgeSet(G) | not IsLabelled(e)];
  while l gt 0 do
    RandomColorOne(~G, d);
    l := #[e : e in EdgeSet(G) | not IsLabelled(e)];
  end while;

  return G;
end function;


function RandomEulerColor(G)
  d := Maxdeg(G);
  // print(d);
  return RandomEulerColorRec(G, d, [1..d+1],"");
end function;


// // Test1  
// n := 16;
// G0 := CompleteGraph(n);
// G0_col := RandomEulerColor(G0);
// print("\n\n");
// PrintGraphLabels(G0_col);
// assert IsEdgeColored(G0_col);
// assert NumberOfColours(G0_col) le n;


// // Test2
// function TestRandomGraphs(nvertices, ntests)
//   for i := 1 to ntests do
//     GR := RandomGraph(nvertices, 0.75);
//     GR_col := RandomEulerColor(GR);
//     if not IsEdgeColored(GR_col) then
//       return false, GR_col;
//     end if;
//   end for;
//   return true, EmptyGraph(0);
// end function;


// succ, GERR := TestRandomGraphs(16, 100);
// if succ then
//   print("All tests successful!");
// else
//   print("Graph colored wrong");
//   print(GERR);
// end if;


