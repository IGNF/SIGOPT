//Randomisation des benchmarks

mclose('val1A.dat');
u=mopen('val1A.dat');
file_name=mfscanf(u,'\n NOMBRE : %s');
borne_sup=mfscanf(u,'\n COMENTARIO : %f (cota superior)');
NS=mfscanf(u,'\n VERTICES : %d');
NAR=mfscanf(u,'\n ARISTAS_REQ : %d');
NANR=mfscanf(u,'\n ARISTAS_NOREQ : %d');
N=mfscanf(u,'\n VEHICULOS : %d');
C=mfscanf(u,'\n CAPACIDAD : %d');
mfscanf(u,'\n TIPO_COSTES_ARISTAS : EXPLICITOS');
mfscanf(u,'\n COSTE_TOTAL_REQ : %d');
mfscanf(u,'\n LISTA_ARISTAS_REQ :');
NA=NAR+NANR; //Nombre d'arêtes
a=zeros(NS,NS); //Matrice d'adjacence
c=zeros(NS,NS); //Matrice des coûts
q=zeros(NS,NS); //Matrice des déchets
for i=1:NAR
    L1=mfscanf(u,'\n %c %d %c %d %c');
    a(L1(2),L1(4))=1;
    L2=mfscanf(u,'%s %d');
    c(L1(2),L1(4))=L2(2);
    L3=mfscanf(u,'%s %d');
    q(L1(2),L1(4))=L3(2);
end
//mfscanf(u,'\n %s %s');
//for i=1:NANR
//    L1=mfscanf(u,'\n %c %d %c %d %c');
//    a(L1(2),L1(4))=1;
//    L2=mfscanf(u,'%s %d');
//    c(L1(2),L1(4))=L2(2);
//end
L=mfscanf(u,'%s %s %d');
depot=L(3); //dépôt
for i=2:NS //Symétrisation
    for j=1:(i-1)
        c(i,j)=c(j,i);
        q(i,j)=q(j,i);
        a(i,j)=a(j,i);
    end
end

NPE=2; //Nombre de paramètres environnementaux (déchets)
NQ=7; //Nombre de quantiles extraits + 1
mu=(mean(q(q>0))/NPE)*ones(1,NPE); //Moyennes des composantes aléatoires
var=variance(q(q>0)).^(1/2)*ones(1,NPE); //Variances des composantes aléatoires
q_coef=zeros(NS,NS,NPE); //Coefficients

for i=1:NS
    for j=1:NS
        for k=1:NPE
            q_coef(i,j,k)=q(i,j)/(mu(1)*NPE);
        end
    end
end

shape=(mu.^2)./var; //Paramètres de forme
rate=mu./var; //Taux

Q=zeros(NPE,NQ-1);
for i=1:NPE
    for l=1:(NQ-1)
        Q(i,l)=cdfgam("X",shape(i),rate(i),l/NQ,1-l/NQ);
    end
end

//Grille des indices des paramètres
GI=list();
l=ones(1,NPE);
i=1;
GI(i)=l;
h=1;
while sum(l)<(NQ-1)*NPE //Construction de la grille des indices
    l(h)=l(h)+1;
    if l(h)>NQ-1
        l(h)=1;
    end
    while l(h)==1
        h=h+1;
        l(h)=l(h)+1;
        if l(h)>NQ-1
            l(h)=1;
        end
    end
    h=1;
    i=i+1;
    GI(i)=l;
end

//Grille des paramètres
G=list();
for i=1:size(GI)
    G(i)=zeros(1,NPE);
    for h=1:NPE
        G(i)(h)=Q(h,GI(i)(h));
    end
end

//Voisins (en indices "simples")
VP=list();
NMV=1; //Niveau maximal de voisins
for i=1:size(G)
    VP(i)=list();
    for k=1:NMV
        VP(i)(k)=[];
    end
end
Delta=PH(NPE);
for i=1:size(G)
    for j=1:size(Delta) //Voisins de niveau 1
        if min(GI(i)+Delta(j))>=1 & max(GI(i)+Delta(j))<=NQ-1 then
            VP(i)(1)=[VP(i)(1) GIinv(NPE,NQ-1,GI(i)+Delta(j))];
        end
    end
    for j=1:size(G) //Voisins de niveaux 2 et plus
        if norm(GI(i)-GI(j),'inf')<=NMV & norm(GI(i)-GI(j),'inf')>=2
            VP(i)(norm(GI(i)-GI(j),'inf'))=[VP(i)(norm(GI(i)-GI(j),'inf')) j];
        end
    end
end

P=size(G); //Taille de la grille
q2=zeros(NS,NS,P); //Déchets par paramètres
for k=1:P
    l=GI(k);
    for i=1:NS
        for j=1:NS
            q2(i,j,k)=0;
            for h=1:NPE
                q2(i,j,k)=q2(i,j,k)+q_coef(i,j,h)*Q(h,l(h));
            end
        end
    end
end
q2A=q2;

//Altitudes
//val1

alt(1)=10;
alt(2)=8;
alt(3)=6;
alt(4)=7;
alt(5)=9;
alt(6)=7;
alt(7)=5;
alt(8)=6;
alt(9)=7;
alt(10)=5;
alt(11)=8;
alt(12)=7;
alt(13)=3;
alt(14)=6;
alt(15)=7;
alt(16)=6;
alt(17)=3;
alt(18)=4;
alt(19)=9;
alt(20)=9;
alt(21)=7;
alt(22)=7;
alt(23)=8;
alt(24)=6;
