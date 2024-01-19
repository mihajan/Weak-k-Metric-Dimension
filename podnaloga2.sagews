import itertools

#funkcija ki prek CLP izračuna k-to šibko dimenzijo grafa (input: graf in željeni k)
def CLP_weak_k_dim(g, k_value):
    # Ustvarimo CLP
    p = MixedIntegerLinearProgram(maximization=False)
    #nove spremenljivke
    x = p.new_variable(binary = True)
    #ciljna funkcija
    p.set_objective(sum(x[v] for v in g))

    #p.p.
    vertices = list(g.vertices())
    #čez vse pare vozlišč
    for va, vb in itertools.combinations(vertices, 2):
        expr = sum(abs(g.distance(va, vi) - g.distance(vb, vi)) * x[vi] for vi in g)
        p.add_constraint(expr >= k_value)

    #omejitev za min moč S
    sum_x = sum(x[vi] for vi in g)
    p.add_constraint(sum_x >= k_value)


    optimalna_resitev = p.solve()
    vrednosti_za_S = p.get_values(x)

    #oblikovanje rešitve
    niz_z_rezultatom = f"Weak-{k_value} dimension: {optimalna_resitev}"
    #Print tega niza
    #print(niz_z_rezultatom)
    return optimalna_resitev

###########################################################################

#funkcija ki z vgrajeno metodo izračuna razdalje med vsemi pari vozlišč
def all_distances(graph):
    return sage.graphs.distances_all_pairs.distances_all_pairs(graph)

##########################################################################

#funkcija, ki izračune \delta(x,y) za vse pare vozlišč in vrne vrednosti v slovarju slovarjev
def delta(graph):
    #izračunamo razdalje med vozlišči
    dist = all_distances(graph)

    # seznam vozlišč in prazen slovar
    vertices = graph.vertices()
    delta_results = {}

    # sprehod čez vsa vozlišča
    for x in vertices:
        for y in vertices:
            if x != y:
                # izračun delte po formuli in shranimo v slovar
                delta_xy = sum(abs(dist[s][x] - dist[s][y]) for s in vertices)
                delta_results[(x, y)] = delta_xy
            else:
                continue

    return delta_results

#################################################################################

#funkcija, ki za podani graf izračuna vrednost \kappa
#to je največja vrednost za katero obstaja k-ta šibka dimenzija grafa
def kappa(graph):
    delta_results = delta(graph)
    #poiščemo najmanjšo vrednost
    min_delta = min(delta_results.values())

    #oblikovanje rešitve
    niz_z_rezultatom = f"Iskana kappa oz max smiselna vrednost parametra k: {min_delta}"
    # Print tega niza
    #print(niz_z_rezultatom)


    return min_delta

##########################################################################################################################


#funkcija, ki sprejme dimenziji ciklov a in b. Izračuna kappa in šibke k_te dimenzije za vsak smiselen k
def naloga2(dim_a, dim_b):
    c1 =graphs.CycleGraph(dim_a)
    c2 =graphs.CycleGraph(dim_b)
    #naredimo kartezični produkt
    C = c1.cartesian_product(c2)

    #max smiselna vrednost za k
    max_k = kappa(C)
    #prazen slovar kamor bom shranjeval dimenzije grafov
    vse_dimenzije = {i: None for i in range(1, max_k + 1)}
    for i in vse_dimenzije.keys():
       #Za smiselne k izračunamo šibke dimenzije grafa
       vse_dimenzije[i] = CLP_weak_k_dim(C, i)
    #show(C)
    print(f"Dimenzije: {dim_a} in {dim_b} -> št robov: {C.size()} \n kappa({dim_a} x {dim_b}) = {max_k} \n slovar posameznih dimenzij: {vse_dimenzije} \n")

    #return C.size(), max_k, vse_dimenzije
    return None

#############################################################################
#funkcija, ki bo testirala grafe za 2. nalogo
# sprejme argumenta a,b ; a in b sta meji za št vozlišč ciklov
#naredimo kartezične produkte in izračunamo dimenzije ter kappo
# a mora biti >=2 in b>a
def testiranje_naloga2(a,b):
    for i in range(a, b + 1):
        for j in range(i, b + 1):
            naloga2(i,j)

#funkcija, ki nariše kartezični produkt ciklov
def risanje_naloga2(dim_a, dim_b):
    c1 =graphs.CycleGraph(dim_a)
    c2 =graphs.CycleGraph(dim_b)
    #naredimo kartezični produkt
    C = c1.cartesian_product(c2)
    show(C) 


#funkcija ki za dimenzije a->b izračuna kart produkt grafov in  izračuna kappo in wdim od kappa (ne pa od vseh drugih dimenzij)
def test2_max_kappa(a,b):
    for i in range(a, b + 1):
        for j in range(i, b + 1):
            c1 =graphs.CycleGraph(i)
            c2 =graphs.CycleGraph(j)
            #naredimo kartezični produkt
            C = c1.cartesian_product(c2)
            #max smiselna vrednost za k
            max_k = kappa(C)
            #izračunamo še dimenzijo
            wdim_k = CLP_weak_k_dim(C, max_k)
            print(f"št robov:{C.size()} \n kappa({i}x{j}) = {max_k} \n Največja dimenzija ({max_k}) = {wdim_k} \n")


#funkcija ki za dimenzije a->b izračuna kart produkt grafov in  izračuna 1. dimenzijo tega grafa
def test2_dimenzija_1(a,b):
    for i in range(a, b + 1):
        for j in range(i, b + 1):
            c1 =graphs.CycleGraph(i)
            c2 =graphs.CycleGraph(j)
            #naredimo kartezični produkt
            C = c1.cartesian_product(c2)
            #izračunamo 1. dimenzijo
            wdim_1 = CLP_weak_k_dim(C, 1)
            print(f"št robov:{C.size()} \n vozlišča: {i}x{j} \n Prva šibka dimenzija = {wdim_1} \n")
