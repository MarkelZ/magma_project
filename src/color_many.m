
procedure FlipABPath(~G, v, alpha, beta, ~w)
  // TODO
  // ...
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

function BuildCollection()
    
end function;

procedure ActivateCollection()

end procedure;

procedure ColorMany

end procedure;
