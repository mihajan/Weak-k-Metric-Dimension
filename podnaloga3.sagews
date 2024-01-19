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
    vertices = list(g.vertices())
    #čez vse pare vozlišč
    for va, vb in itertools.combinations(vertices, 2):
            expr = sum(int(bool(g.distance(va, vi) - g.distance(vb, vi))) * x[vi] for vi in g)
            p.add_constraint(expr >= k_value)



    optimalna_resitev = p.solve()
    vrednosti_za_S = p.get_values(x)

    #oblikovanje rešitve
    niz_z_rezultatom = f"{k_value} dimension: {optimalna_resitev}"
    # Print tega niza
    #print(niz_z_rezultatom)
    return optimalna_resitev#, vrednosti_za_S


def naloga3(graph):

    #računali bomo do kamor je navadna k-ta definirana
    max_k = kappa_navadna(graph)

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
        #else:
        #    ujemanja[kljuc] = False
        #če ni ujemanja z nek k to zabeležimo
        #else:
        #    ujemanja[kljuc] = False

    return ujemanja


#funkcija, ki generira vse povezane grafe z najmanj m in največ n vozlišči in izpiše katere k-te pibke in k-te dimenzije tega grafa se ujemajo
#m obvezno vsaj 2 sicer error
def testiranje_naloga3(m,n):
    for i in range(m,n + 1):
        for graph in graphs.nauty_geng(f"{i} -c"):
            g = naloga3(graph)
            if len(g) >= 5:
                print(g)
                #show(graph)
                #res velikrat enake tut pokažemo
                if len(g) >= 5:
                    show(graph)

#funkcija, ki bo preverjala samo za posplošene petersenove grafe ki imajo zgleda veliko ujemanj
#gre čez vse posplošene peteresenove grafe za med  n=m,...,n ter k=1,...,k
#k must be in 1<= k <=floor((n-1)/2)
# m mora biti >2 in n>m .. primerne k funkcija določi sama

def gen_petersen_naloga_3(m,n):
    for i in range(m,n+1):
        max_k = (i-1) // 2
        for k in range(1,max_k+1):
            gp = naloga3(graphs.GeneralizedPetersenGraph(i, k))
            kappa = kappa_navadna(graphs.GeneralizedPetersenGraph(i, k))
            print(f"GeneralizedPetersen({i},{k}), kappa:{kappa} \n ujemanja: {gp} \n")

#preverja samo za hiperkocke
def kart_cikli_naloga_3(a,b):
    for i in range(a, b + 1):
        for j in range(i, b + 1):
            c1 =graphs.CycleGraph(i)
            c2 =graphs.CycleGraph(j)
            #naredimo kartezični produkt
            C = c1.cartesian_product(c2)
            #izračunamo 1. dimenzijo
            cikel = naloga3(C)
            kappa = kappa_navadna(C)
            print(f"Cikla({i}x{j}), kappa:{kappa} \n ujemanja: {cikel} \n")
