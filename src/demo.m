// Demo for the presentation
nvertices := 8;
density := 0.5;

G := RandomGraph(nvertices, density);
G_col := RandomEulerColor(G);

PrintGraphLabels(G_col);
