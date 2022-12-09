procedure PrintGraphLabels(G) 
  for e in EdgeSet(G) do
    print(e);
    print(Label(e));
  end for;
end procedure;

// Determine whether graph G is edge colored.
function IsEdgeColored(G)
  for v in VertexSet(G) do
    // Get list of labels of edges of v
    labels := [];
    for e in IncidentEdges(v) do
      // If an edge is unlabelled return false and print warning msg
      if not IsLabelled(e) then
        print("Edge not labelled!");
        print(e);
        return false;
      end if;

      Append(~labels, Label(e));
    end for;

    // If there are any repeated colors return false
    labels := Sort(labels);
    for i := 1 to #labels - 1 by 1 do
      if labels[i] eq labels[i + 1] then
        return false;
      end if;
    end for;
  end for;

  // If no colors repeat return true
  return true;
end function;

function EulerPartition(G)
  GCopy := G;
  N := #VertexSet(GCopy);
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
        // Include(~E1,e);
        AddEdge(~G1, v1, v2);
        flag := 2;
      else
        // Include(~E2,e);
        AddEdge(~G2, v1, v2);
        flag := 1;
      end if;
    end for; 
  end while;  

  // G1 := sub<GCopy | E1>;
  // G2 := sub<GCopy | E2>;
  return G1,G2;
end function;


function GreedyEulerColorRec(G, d, Colors)
  // Base case
  if d le 1 then
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
  Colors1 := Colors[1..2*Ceiling(d/2)-1];
  Colors2 := Colors[2*Ceiling(d/2)..#Colors];
  if #Colors2 lt 2*Ceiling(d/2)-1 then
    Append(~Colors2, Maximum(Colors1)+#Colors2+1);
  end if;
  G1 := GreedyEulerColorRec(G1, d1, Colors1);
  G2 := GreedyEulerColorRec(G2, d2, Colors2);
  
  for e in EdgeSet(G1) do
    AssignLabel(~G,e,Label(e));
  end for;
  for e in EdgeSet(G2) do
    AssignLabel(~G,e,Label(e));
  end for;

  // Prune
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
    Append(~Colors,[n,i]);
  end while;
  Sort(~Colors,func<x,y | x[2] - y[2]>); 
  while #Colors gt 2*d-1 do
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

  // Repair
  for e in EdgeSet(G) do
    if not IsLabelled(e) then
      print("Repairing edge: ");
      print(e);
      vs := Setseq(EndVertices(e));
      v1 := vs[1];
      cols1 := [];
      for e1 in IncidentEdges(v1) do
        if IsLabelled(e1) then
          Append(~cols1, Label(e1));
        end if;
      end for;

      v2 := vs[2];
      cols2 := [];
      for e2 in IncidentEdges(v2) do
        if IsLabelled(e2) then
          Append(~cols1, Label(e2));
        end if;
      end for;

      for cf in Colors do
        alpha := cf[1];
        if (alpha notin cols1) and (alpha notin cols2) then
          AssignLabel(~G, e, alpha);
        end if;
      end for;
    end if;
  end for;

  return G;
end function;


function GreedyEulerColor(G)
  d := Maxdeg(G);
  return GreedyEulerColorRec(G, d, [1..2*d-1]);
end function;

// Test1
G0 := CompleteGraph(4);
G0_col := GreedyEulerColor(G0);
assert IsEdgeColored(G0_col);

// Test2

function TestRandomGraphs(nvertices, ntests)
  for i := 1 to ntests do
    GR := RandomGraph(nvertices, 0.75);
    GR_col := GreedyEulerColor(GR);
    if not IsEdgeColored(G0_col) then
      return false, GR_col;
    end if;
  end for;
  return true, EmptyGraph(0);
end function;


succ, GERR := TestRandomGraphs(16, 100);
if succ then
  print("All tests successful!");
else
  print("Graph colored wrong");
  print(GERR);
end if;
