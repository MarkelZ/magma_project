// Include the right files before running plz:
// $ magma common.m greedy_euler_color.m benchmarks.m


// JIT messes with the benchmarks, so we compile everything ahead of time
print("jitting...");
for i := 1 to 1000 do
    try
        GR := RandomGraph(16, 0.75);
        GR_col := GreedyEulerColor(GR);
    catch e;
    end try;
    printf "%1o", ".";
end for;


// Actual benchmarks
nvertices := 96;
densities := [0.25, 0.50, 0.75, 1.00];
nsamples := 100;

print("==================================================================================================");
print("==================================================================================================");
print("Starting benchmark!");
for density in densities do
    i := 0;
    accum := 0;

    print("Progress:");
    while i lt nsamples do
        GR := RandomGraph(nvertices, density);

        try
        t0 := Cputime();
        GR_col := GreedyEulerColor(GR);
        dt := Cputime(t0);
        catch e
            printf "%1o ", "x";
            continue;
        end try; 


        if not IsEdgeColored(GR_col) then
            printf "%1o ", "y";
            continue;
        end if;

        accum := accum + dt;
        i := i + 1;
        printf "Iter: %1o ", i;
        printf "Avg: %1o ", (1000*accum) / i;
    end while;

    avg := accum / nsamples;
    print("\n");
    print("############################################################################");
    print("Num. samples:");
    print(nsamples);
    print("Num. vertices:");
    print(nvertices);
    print("Density:");
    print(density);
    print("Average execution time (ms): ");
    print(avg * 1000);
end for;
