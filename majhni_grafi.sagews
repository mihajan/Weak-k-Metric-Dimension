#funkcija ki prek CLP izračuna k-to šibko dimenzijo grafa (input: graf in željeni k)
def CLP_weak_k_dim(g, k_value):
    # Ustvarimo CLP
    p = MixedIntegerLinearProgram(maximization=False)
    #nove spremenljivke
    x = p.new_variable(binary = True)
    #ciljna funkcija
    p.set_objective(sum(x[v] for v in g))

    #p.p.
    for va in g:
        for vb in g:
            if va != vb:
                expr = sum(abs(g.distance(va, vi) - g.distance(vb, vi)) * x[vi] for vi in g)
                p.add_constraint(expr >= k_value)
            else:
                continue

    #omejitev za min moč S
    sum_x = sum(x[vi] for vi in g)
    p.add_constraint(sum_x >= k_value)


    optimalna_resitev = p.solve()
    vrednosti_za_S = p.get_values(x)

    #oblikovanje rešitve
    niz_z_rezultatom = f"Weak-{k_value} dimension: {optimalna_resitev}"
    # Print tega niza
    #print(niz_z_rezultatom)
    return optimalna_resitev

###########################################################################
def all_distances(graph):
    return sage.graphs.distances_all_pairs.distances_all_pairs(graph)

##########################################################################

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

def kappa(graph):
    delta_results = delta(graph)
    #poiščemo najmanjšo vrednost
    min_delta = min(delta_results.values())

    #oblikovanje rešitve
    niz_z_rezultatom = f"Iskana kappa oz max smiselna vrednost parametra k: {min_delta}"
    # Print tega niza
    #print(niz_z_rezultatom)


    return min_delta



#funkcija, ki reši 1. podnalogo
#kot input dobi graf; potem izračuna vse smiselne šibke dimenzije za podani graf
#v naslednjem koraku poišče pare vozlišč oddaljene 3 ali več in poišče delte za te pare
#na koncu preveri ujemanja med zgornjima deloma (če obstaja vren vrednosti,, sicer prazen seznam)


def ujemanje1(graph):
    #max smiselna vrednost za k
    max_k = kappa(graph)
    #prazen slovar kamor bom shranjeval dimenzije grafov
    vse_dimenzije = {i: None for i in range(1, max_k + 1)}
    for i in vse_dimenzije.keys():
       #Za smiselne k izračunamo šibke dimenzije grafa
       vse_dimenzije[i] = CLP_weak_k_dim(graph, i)

    ####
    dist = all_distances(graph)
    #čez vrednosti da preverim ali je d(x,y) >=3
    sez_oddaljenih = []
    for outer_key, inner_dict in dist.items():
        for inner_key, value in inner_dict.items():
            if value >= 3:
                #dodamo par vozlišč na seznam (kot touple-- isto kot delta)
                sez_oddaljenih.append((outer_key,inner_key))
            else:
                continue
    #izračunam vse delte, za pare vozlišč
    vse_delta = delta(graph)
    #poiščem ujemanja med slovarjem in seznamom (kandidati na desni strani navodil)
    ok_delte = [vse_delta[kljuc] for kljuc in sez_oddaljenih if kljuc in vse_delta]

    #####iskanje ujemanj
    #dimenzije in delte, ki se ujemajo
    ujemanja = [stevilka for stevilka in ok_delte if any(stevilka == vrednost for vrednost in vse_dimenzije.values())]


    return ujemanja, ok_delte, vse_dimenzije.values()


#ujemanje1(graphs.PathGraph(10))
#ujemanje1(graphs.CompleteBipartiteGraph(5,3)) #seveda niso nobena oddaljena za več kot 3 med sabo
#ujemanje1(graphs.CycleGraph(10))
#ujemanje1(graphs.StarGraph(10)) #seveda niso nobena oddaljena za več kot 3 med sabo
#ujemanje1(graphs.PetersenGraph())

#############################################################
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
    return C.size(), max_k, vse_dimenzije

##############################################################

#funkcija sprejme graf in izračuna ali je za kakšen k <= kappa
#k-ta dimenzija enaka k-ti šibki dimenziji grafa
def naloga3(graph):
    max_k = kappa(graph)

    for i in range(1, max_k +1):
        #obe izračunamo in pogledamo ali sta enaki
        sibka = CLP_weak_k_dim(graph, i)
        navadna = CLP_k_dim(graph, i)
        if sibka == navadna:
            return True
    return False






