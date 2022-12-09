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