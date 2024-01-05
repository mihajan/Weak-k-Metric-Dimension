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
    #poiščemo \kappa
    max_k = kappa(graph)
    #prazen slovar kamor bom shranjeval dimenzije grafov (ključi so smiselne vrednosti k)
    vse_dimenzije = {i: None for i in range(1, max_k + 1)}
    for i in vse_dimenzije.keys():
       #Za smiselne k izračunamo šibke dimenzije grafa
       vse_dimenzije[i] = CLP_weak_k_dim(graph, i)

    #iskanje vrednosti \delta za dovolj oddaljena vozlišča
    dist = all_distances(graph)
    #čez razdalje med vozlišči da preverim ali je d(x,y) >=3
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

    #ali je graf tak kot ga želimo:
    if len(ujemanja) > 0:
        return True
    else:
        return False

    #return ujemanja, ok_delte, vse_dimenzije.values()

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
    print(f"Dimenzije: {dim_a} in {dim_b} -> {C.size()} \n kappa({dim_a} x {dim_b}) = {max_k} \n slovar posameznih dimenzij: {vse_dimenzije} \n")

    #return C.size(), max_k, vse_dimenzije
    return None

#############################################################################
#############################################################################

#naslednje pomožne funkcije bodo koristne pri 3. podnalogi
#naredijo praktično isto kot zgornje le da za k-to dimenzijo, ne pa k-to šibko dimenzijo kot zgornje

def delta_navadna(graph):
    #izračunamo razdalje med vozlišči
    dist = all_distances(graph)

    # seznam vozlišč in prazen slovar
    vertices = graph.vertices()
    delta_results = {}

    # sprehod čez vse pare vozlišč
    for x in vertices:
        for y in vertices:
            if x != y:
                # razdalje do koliko vozlišč se razlikujejo
                delta_xy = sum(int(bool(dist[s][x] - dist[s][y])) for s in vertices)
                delta_results[(x, y)] = delta_xy
            else:
                continue

    return delta_results

################

def kappa_navadna(graph):
    delta_results = delta_navadna(graph)
    #poiščemo najmanjšo vrednost
    min_delta = min(delta_results.values())

    #oblikovanje rešitve
    niz_z_rezultatom = f"Iskana kappa oz max smiselna vrednost parametra k pri običajni dimenziji: {min_delta}"
    # Print tega niza
    #print(niz_z_rezultatom)


    return min_delta


#CLP, ki vrne k-to dimenzijo grafa
def CLP_k_dim(g, k_value):
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
                expr = sum(int(bool(g.distance(va, vi) - g.distance(vb, vi))) * x[vi] for vi in g)
                p.add_constraint(expr >= k_value)
            else:
                continue


    optimalna_resitev = p.solve()
    vrednosti_za_S = p.get_values(x)

    #oblikovanje rešitve
    niz_z_rezultatom = f"{k_value} dimension: {optimalna_resitev}"
    # Print tega niza
    #print(niz_z_rezultatom)
    return optimalna_resitev#, vrednosti_za_S


def naloga3(graph):
    #poiščem max vrednosti za kappe za navadno in šibko dimenzjo
    max_k_sibka = kappa(graph)
    max_k_navadna = kappa_navadna(graph)

    #računali bomo do njunega minimuma (nepotrebno saj je max_k_navadna vedno <=)
    max_k = min(max_k_sibka, max_k_navadna)

    #lahko bi gledali samo od 2 navzgor saj se za 1 ujemata za vse grafe
    #prani slovarji za računanje dimenzij
    sibke_dimenzije = {i: None for i in range(1, max_k + 1)}
    navadne_dimenzije = {i: None for i in range(1, max_k + 1)}
    for i in range(1,max_k + 1):#range(1, max_k +1):
        #obe izračunamo in ju dodamo v slovar
        sibka = CLP_weak_k_dim(graph, i)
        navadna = CLP_k_dim(graph, i)
        sibke_dimenzije[i] = sibka
        navadne_dimenzije[i] = navadna
        #if sibka == navadna:
        #    return True
    #return False

    #sprehodim se čez slovarja in pogledam katere dimenzije se ujemajo
    ujemanja = {}
    for kljuc in sibke_dimenzije.keys():
        if kljuc in navadne_dimenzije and sibke_dimenzije[kljuc] == navadne_dimenzije[kljuc]:
            ujemanja[kljuc] = sibke_dimenzije[kljuc]
        #če ni ujemanja z nek k to zabeležimo
        #else:
        #    ujemanja[kljuc] = False

    return ujemanja

########################################################################################
#funkcija ki bo testirala prvo podnalogo

# za vse povezane grafe na najmanj m in največ n vozliščih preveri če velja ujemanje iz prve podnaloge
def testiranje_naloga1(m,n):
    for i in range(m,n + 1):
        for graph in graphs.nauty_geng(f"{i} -c"):
            #preveri če se v kateri dimenziji ujema
            value = ujemanje1(graph)
            #če se ujema ga izriše (lahko bi tut kj druzga dal)
            if value == True:
                show(graph)
    #če ne najde nobenega
    return False

##################################################################################################
#funkcija, ki bo testirala grafe za 2. nalogo
# sprejme argumenta a,b ter m,n ; a in b sta meji za št vozlišč prvega grafa, m in n podobno za drugi graf
# a in m morata biti >= 2 !!
def testiranje_naloga2(a,b,m,n):
    for i in range(a, b + 1):
        for j in range(m, n + 1):
            naloga2(i,j)

#funkcija, ki nariše kartezični produkt ciklov
def risanje_naloga2(dim_a, dim_b):
    c1 =graphs.CycleGraph(dim_a)
    c2 =graphs.CycleGraph(dim_b)
    #naredimo kartezični produkt
    C = c1.cartesian_product(c2)
    show(C)
############################################################################################



