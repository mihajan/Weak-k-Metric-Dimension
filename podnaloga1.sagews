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

################################################################################
#funkcija, ki reši 1. podnalogo
#kot input dobi graf; potem izračuna vse smiselne šibke dimenzije za podani graf
#v naslednjem koraku poišče pare vozlišč oddaljene 3 ali več in poišče delte za te pare
#na koncu preveri ujemanja med zgornjima deloma (če obstaja vrne True, sicer False)
#kaj točno vrne, ko poišče graf ki se ujema se seveda da prilagoditi


def ujemanje1(graph):

    #iskanje vrednosti \delta za dovolj oddaljena vozlišča
    dist = all_distances(graph)
    #čez razdalje med vozlišči da preverim ali je d(x,y) >=3
    sez_oddaljenih = []
    for outer_key, inner_dict in dist.items():
        for inner_key, value in inner_dict.items():
            if value >= 3:
                #dodamo par vozlišč na seznam (kot touple-- isto kot delta)
                sez_oddaljenih.append((outer_key,inner_key))



    #če ni nobenih oddaljenih vrnemo False (ker ne bo ujemanj)
    if len(sez_oddaljenih) < 1:
        return False
    #sicer gremo računat dimenzije
    else:
        #izračunam vse delte, za pare vozlišč
        vse_delta = delta(graph)
        #poiščem ujemanja med slovarjem in seznamom (kandidati na desni strani navodil)
        ok_delte = [vse_delta[kljuc] for kljuc in sez_oddaljenih if kljuc in vse_delta]

        #poiščemo \kappa
        max_k = kappa(graph)
        #prazen slovar kamor bom shranjeval dimenzije grafov (ključi so smiselne vrednosti k)
        vse_dimenzije = {i: None for i in range(1, max_k + 1)}
        for i in vse_dimenzije.keys():
           #Za smiselne k izračunamo šibke dimenzije grafa
           vse_dimenzije[i] = CLP_weak_k_dim(graph, i)


        #####iskanje ujemanj
        #dimenzije in delte, ki se ujemajo
        ujemanja = [stevilka for stevilka in ok_delte if any(stevilka == vrednost for vrednost in vse_dimenzije.values())]

        #ali je graf tak kot ga želimo:
        if len(ujemanja) > 0:
            return True
        else:
            return False

        #return ujemanja, ok_delte, vse_dimenzije.values()

#funkcija ki bo testirala prvo podnalogo

#########################################################################################################

# za vse povezane grafe na najmanj m in največ n vozliščih preveri če velja ujemanje iz prve podnaloge
#ta funkcija vse grafe tudi izriše. To je preveč (že za n=9 ne more vseh izrisat)
def testiranje_naloga1(m,n):
    stevec_ujemanj = 0
    stevec_pregledanih = 0
    for i in range(m,n + 1):

        for graph in graphs.nauty_geng(f"{i} -c"):
            #preveri če se v kateri dimenziji ujema
            value = ujemanje1(graph)
            stevec_pregledanih += 1
            #če se ujema ga izriše (lahko bi tut kj druzga dal)
            if value == True:
                stevec_ujemanj += 1
                show(graph)
                print(f"stevec:{stevec_ujemanj} št robov zadnjega ujemanja:{graph.size()} št vozlišč: {i} (vseh pregledanih: {stevec_pregledanih})")
    #če ne najde nobenega
    return False


#pogleda samo vsak 1000 graf
#primerno za velike grafe, iz 1000 lahko poljubno spremenimo na željeno število
def trik_naloga_1(m,n):
        for i in range(m,n + 1):
            stevec_ujemanj = 0
            #na koliko grafih je zares kaj računal
            stevec_zares_pregledanih = 0
            #koliko grafov je videl (tut te k jih je spustu)
            stevec_videnih = 0
            for graph in graphs.nauty_geng(f"{i} -c"):
                stevec_videnih += 1
                st_robov = graph.size()
                #pogoj kdaj ga sploh zares pregleda
                if stevec_videnih % 1000 == 0:
                    #preveri če se v kateri dimenziji ujema
                    value = ujemanje1(graph)
                    #tega je dejansko pogledov
                    stevec_zares_pregledanih += 1
                    #če se ujema ga printamo in popravmo še ta števc za ujemanja
                    if value == True:
                        stevec_ujemanj += 1
                        #show(graph)
                        st_trikotnikov = graph.triangles_count()
                        print(f"stevec ujemanj:{stevec_ujemanj} št trikotnikov zadnjega ujemanja:{st_trikotnikov} (do zdaj zares pregledanih:{stevec_zares_pregledanih}, vseh videnih:{stevec_videnih}), kappa: {kappa(graph)}")

        #če ne najde nobenega
        return False
        
