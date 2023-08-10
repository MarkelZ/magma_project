import matplotlib.pyplot as plt
import networkx as nx
import random

path = 'graph.dat'

with open(path) as f:
    content = f.readlines()

badchars = [' ', '\n', '\t', ' ', '{', '}']
content = [''.join([x for x in line if x not in badchars]) for line in content]
content = [x for x in content if x != '']

edges = [[int(v) for v in x.split(',')] for x in content[::2]]
labels = [int(x) for x in content[1::2]]

nvertices = max([v for x in edges for v in x])

G = nx.empty_graph(nvertices)

for i in range(len(edges)):
    u, v = edges[i]
    lb = labels[i]
    G.add_edge(u-1, v-1, weight=lb)

edges, weights = zip(*nx.get_edge_attributes(G, 'weight').items())

cm = plt.get_cmap('gist_ncar')
colors = []
max_weight = max(weights)
for w in weights:
    colors.append(cm(float(w-1)/max_weight))

pos = nx.spring_layout(G)
nx.draw(G, pos, node_color='b', edgelist=edges,
        edge_color=colors, width=10.0)
# plt.savefig('edges.png')
plt.show()
