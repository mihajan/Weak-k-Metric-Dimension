import itertools
import time
from sage.graphs.distances_all_pairs import distances_all_pairs
from random import random, sample
from math import exp

# Funkcija ki preveri ali je delta(x,y) >k za vsa vozlišča glede na trenutno rešitev
#če je OK vrne moč množice, sicer inf
def objective(resolving_set, graph, k, all_distances):
    vertices = set(graph.vertices())
    for va, vb in itertools.combinations(vertices, 2):
                count = sum(abs(all_distances[va][vi] - all_distances[vb][vi]) for vi in resolving_set)
                if count < k:
                    return float('inf')
    return len(resolving_set)



# funkcija ki dodaja ali odstranjuje vozlišča iz trenutne rešitve
def transition(current_state, graph, k):
    #prepišemo trenutno rešitev
    new_state = set(current_state)

    #generiramo verjetnost
    action = random()
    #če imamo več kot k vozlišč in ugodno verjetnost enega odstranimo ali če so vsa notri
    if (action < 0.5 and len(new_state) > k) or graph.num_verts() == len(current_state):
        #izberemo naključno vozlišče in ga izločimo
        vertex_to_remove = sample(list(new_state), 1)[0]
        new_state.remove(vertex_to_remove)
    else:
        #sicer dodamo  naključno vozlišče
        vertices_list = sorted(list(graph.vertices()))  # Uporabljamo globalno spremenljivko za graf
        vertex_to_add = sample(vertices_list, 1)[0]
        new_state.add(vertex_to_add)

    return new_state

def acceptance_probability(current_energy, new_energy, temperature):
    if new_energy < current_energy:
        return 1.0
    return exp((current_energy - new_energy) / temperature)

# Implement the simulated annealing algorithm (utilizing your existing functions)
def simulated_annealing(initial_state, graph, k, initial_temperature, cooling_rate, max_iterations):
    all_distances = distances_all_pairs(graph)
    #nastavimo začetne parametre
    current_state = initial_state
    best_solution = initial_state

    current_temperature = initial_temperature
    current_energy = objective(current_state, graph, k, all_distances)
    best_energy = objective(best_solution, graph, k, all_distances)

    for _ in range(max_iterations):
        #dodamo oz. odstranimo vozlišče
        new_state = transition(current_state, graph, k)
        #izračun energij

        new_energy = objective(new_state, graph, k, all_distances)

        #če je nova energija nižja jo gotovo obdržimo
        if new_energy < current_energy:
            current_state = new_state
            current_energy = new_energy
            if new_energy < best_energy:
                best_solution = new_state
                best_energy = objective(current_state, graph, k, all_distances)
        else:
            probability = acceptance_probability(current_energy, new_energy, current_temperature)
            if random() < probability:
                current_state = new_state

        current_temperature *= cooling_rate

    return best_solution


#definiramo graf in vrednost k
g = graphs.CycleGraph(100)
k = 1
# Za začetno stanje vzamemo kar vsa vozlišča
initial_state = set(g.vertices())  

# definiramo začetne parametre
initial_temperature = 100
cooling_rate = 0.95
max_iterations = 1000

start_time = time.time()
best_solution = simulated_annealing(initial_state, g, k, initial_temperature, cooling_rate, max_iterations)
end_time = time.time()

stop_time = time.time()
duration = stop_time-start_time

print(f"{duration:.2f}s")
print("množica S:", best_solution)
print(f"weak {k}-dimension:", len(best_solution))
