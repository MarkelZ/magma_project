procedure PrintGraphLabels(G) 
  for e in EdgeSet(G) do
    print(e);
    if IsLabelled(e) then
      print(Label(e));
    else
      print("Unlabeled");
    end if;
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

// Calculate missing colors at vertex
// This should be stored, not always calculated
// Assumes d+1 colors
function M(G,d,v) 
  E := IncidentEdges(v);
  Mv := {1..d+1};
  for e in E do
    if IsLabelled(e) then
      Exclude(~Mv, Label(e));
    end if;
  end for;
  return Mv;
end function;

// v is the starting point
// v has an alpha-edge
// w is the endpoint
// we might have to check for infinite looping,
// if this can run on cycles. I think it cannot.  
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

G := CompleteGraph(6);
V := VertexSet(G);
E := EdgeSet(G);
w := -1;
AssignLabel(E ! {1,2},1);
AssignLabel(E ! {2,3},0);
FlipABPath(~G,V ! 1,1,0,~w);