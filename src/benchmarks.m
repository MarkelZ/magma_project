// Include the right files before running plz:
// $ magma common.m random_euler_color.m benchmarks.m


// JIT messes with the benchmarks, so we compile everything ahead of time
print("jitting...");
for i := 1 to 10 do
    try
        GR := RandomGraph(16, 0.75);
        GR_col := RandomEulerColor(GR);
    catch e;
    end try;
    print(i);
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
        GR_col := RandomEulerColor(GR);
        dt := Cputime(t0);
        accum := accum + dt;
        catch e
            printf "%3o ", "ooopsie";
            continue;
        end try; 

        if not IsEdgeColored(GR_col) then
            printf "%3o ", "rly bad oopsie";
            continue;
        end if;

        i := i + 1;
        printf "%3o ", i;
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
