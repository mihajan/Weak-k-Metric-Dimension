︠83a72a34-19ad-487b-b850-2f9eedfaffd2s︠


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




︡3b9bf2fd-0f19-44a8-b718-461494a67451︡{"done":true}
︠95c88cd2-09c7-4791-9731-cf5ffa7b60e9s︠

︡db6538b4-c3c0-44b6-89d3-3f645f467709︡{"done":true}
︠2318e2f9-75f3-48b3-8099-489941bf3639︠
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

︡eb411a84-5c4d-4f61-a3cc-e1e70e749d18︡{"done":true}
︠d733667d-372b-4e5a-8548-2198eccaa8d1︠
#ujemanje1(graphs.PathGraph(10))
#ujemanje1(graphs.CompleteBipartiteGraph(5,3)) #seveda niso nobena oddaljena za več kot 3 med sabo
#ujemanje1(graphs.CycleGraph(10))
#ujemanje1(graphs.StarGraph(10)) #seveda niso nobena oddaljena za več kot 3 med sabo
#ujemanje1(graphs.PetersenGraph())

︡423da8f5-75ab-4980-b94b-e52ccf85c4e9︡{"stdout":"([], [], dict_values([3.0, 4.0, 7.0, 8.0, 9.0, 10.0]))\n"}︡{"done":true}
︠3feb9074-c3a0-430e-a621-7ed658bf0822s︠

︡f13f9cf3-b7d5-4db2-bdaa-02ea83ed5a0d︡{"done":true}
︠62dd3648-8966-4286-b7fc-b7847f981247︠









