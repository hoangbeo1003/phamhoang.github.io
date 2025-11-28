from collections import defaultdict, deque
edges = [
("A","B"),("A","C"),("B","C"),("B","D"),("C","E"),("D","E"),("D","F"),("E","G"),
("F","H"),("G","H"),("I","J"),("I","K"),("J","K"),("K","L"),("L","M"),("M","N"),
("O","P"),("O","Q"),("P","Q"),("Q","R"),("R","S"),("T","U"),("T","V"),("U","V"),
("W","X"),("W","Y"),("X","Y"),("Z","AA"),("Z","AB"),("AA","AB"),("AC","AD"),
("AC","AE"),("AD","AE"),("AF","AG"),("AH","AI"),("AJ","AK"),("AL","AM"),
("AN","AO"),("AP","AQ"),("AR","AS"),("AT","AU"),("AV","AW"),("AX","AY"),
("AZ","BA"),("BB","BC"),("BD","BE"),("BF","BG"),("BH","BI"),("BJ","BK"),
("BL","BM")
]

graph = defaultdict(list)

for u, v in edges:
    graph[u].append(v)
    graph[v].append(u)  

def bfs(start, visited):
    queue = deque([start])
    component = []

    visited.add(start)

    while queue:
        node = queue.popleft()
        component.append(node)

        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)

    return component

def find_connected_components():
    visited = set()
    components = []

    all_nodes = set(graph.keys())

    for node in all_nodes:
        if node not in visited:
            component = bfs(node, visited)
            components.append(component)

    return components

components = find_connected_components()

print("TỔNG SỐ THÀNH PHẦN LIÊN THÔNG:", len(components))
print("===================================")

for i, comp in enumerate(components, start=1):
    print(f"Thành phần {i}: {sorted(comp)}")