# Edge Coloring in Magma

This project uses the Magma computer algebra system to implement the edge coloring algorithm proposed by Corwin Sinnamon:

https://arxiv.org/abs/1907.03201v4

## Demo

In `src/demo.m` feel free to adjust the variables `nvertices` and `density` as you please.

The demo can be run with

```sh
cd src/
magma common.m random_euler_color.m demo.m
```

To visualize the graph, copy the output of the demo into `visualize/graph.dat`.

The graph can be then visualized by going to the `visualize` directory and running

```sh
python3 visualize.py
```
