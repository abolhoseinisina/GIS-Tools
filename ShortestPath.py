import matplotlib.pyplot as plt
import networkx as nx

# Defining a directed Graph
G = nx.DiGraph()
nodes = ["a","b","c","d","e","f","g","h","i"]
edges = [("a", "b", 5), 
        ("a", "f", 5), 
        ("b", "c", 5), 
        ("b", "e", 4), 
        ("c", "d", 5), 
        ("d", "e", 5),
        ("d", "i", 5),
        ("e", "b", 5),
        ("e", "d", 5),
        ("e", "f", 5),
        ("e", "h", 5),
        ("f", "a", 5), 
        ("f", "e", 5),
        ("f", "g", 5),
        ("h", "i", 5),
        ("i", "h", 5)]
G.add_nodes_from(nodes)
G.add_weighted_edges_from(edges)
pos = nx.kamada_kawai_layout(G)

# Calculating the shortest path between two nodes
shortest_path = nx.shortest_path(G, 'a', 'i', weight='weight')
path_edges = list(zip(shortest_path,shortest_path[1:]))
print("shortest path from '"+str(shortest_path[0])+"' to '"+str(shortest_path[-1])+"': " + str(shortest_path))

# Drawing nodes and edges
nx.draw_networkx_nodes(G, pos, nodelist=G.nodes, node_color='tab:blue')
nx.draw_networkx_nodes(G, pos, nodelist=shortest_path, node_color='tab:red')
nx.draw_networkx_edges(G, pos, connectionstyle='arc3, rad = 0.1', edgelist=G.edges, edge_color='tab:blue', width=1)
nx.draw_networkx_edges(G, pos, connectionstyle='arc3, rad = 0.1', edgelist=path_edges, edge_color='tab:red', width=2)

# Drawing name of nodes and weight of edges
nx.draw_networkx_labels(G, pos, font_weight='bold')
edges_weights = nx.get_edge_attributes(G, 'weight')
nx.draw_networkx_edge_labels(G, pos, label_pos=0.3, edge_labels=edges_weights, font_size=7)

# Plotting the result
plt.show()  