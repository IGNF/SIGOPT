//Données graphe aléatoire

NPE=2; //Nombre de paramètres environnementaux (déchets)

//Choix d'un jeu de paramètres de lois gamma
ks=[25 35]; //Shape parameters
mu=[6 7]; //Moyennes
Beta=ks./mu; //Rate parameters
NQ=7; //Nombre de quantiles extraits + 1
Q=zeros(NPE,NQ-1);
for i=1:NPE
    for l=1:(NQ-1)
        Q(i,l)=cdfgam("X",ks(i),Beta(i),l/NQ,1-l/NQ);
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

//Voisins (de niveau 1, en indices "uniques")
//V1=list();
//Delta=PH(NPE);
//for i=1:size(G)
//    V1(i)=[];
//    for j=1:size(Delta)
//        if min(GI(i)+Delta(j))>=1 & max(GI(i)+Delta(j))<=NQ-1 then
//            V1(i)=[V1(i) GIinv(NPE,NQ-1,GI(i)+Delta(j))];
//        end
//    end
//end

//Voisins (de niveau 1, en indices "simples")
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

//Matrice des distances (déterministe)
c=-1*ones(17,17);
for k=2:7 //1=dépôt
    c(1,k)=2;
end
for k=2:6
    c(k,k+1)=2;
end
c(2,7)=2;
c(2,10)=2;
c(7,10)=2;
c(7,11)=2;
c(6,11)=2;
c(3,8)=2;
c(4,8)=2;
c(4,9)=2;
c(5,9)=2;
c(8,9)=5;
c(10,11)=5;
c(8,12)=2;
c(3,12)=2;
c(12,13)=2;
c(3,13)=2;
c(2,13)=2;
c(13,14)=2;
c(2,14)=2;
c(10,14)=2;
c(9,15)=2;
c(5,15)=2;
c(15,16)=2;
c(5,16)=2;
c(6,16)=2;
c(16,17)=2;
c(6,17)=2;
c(11,17)=2;
NS=size(c,1);
for i=2:NS //Symétrisation
    for j=1:(i-1)
        c(i,j)=c(j,i);
    end
end
a=bool2s(c>0); //Matrice d'adjacence

//Altitudes
alt(1)=4;
alt(2)=2.5;
alt(3)=2;
alt(4)=2;
alt(5)=3.5;
alt(6)=3;
alt(7)=3.5;
alt(8)=1.5;
alt(9)=2.5;
alt(10)=2.5;
alt(11)=3.5;
alt(12)=1;
alt(13)=1.5;
alt(14)=2;
alt(15)=3;
alt(16)=3.5;
alt(17)=4;

//Quantités de déchets
P=size(G); //Taille de la grille=nombre de fourmis dans une colonie
NS=17;
q=zeros(NS,NS,NPE); //Coordonnées de déchets en composantes principales (ici: choix aléatoire)
q(1,2,1)=1.3447899;
q(1,2,2)=0.4034345;
q(1,3,1)=0.7823148;
q(1,3,2)=1.6600633;
q(1,4,1)=1.175744;
q(1,4,2)=0.9658359;
q(1,5,1)=0.4465730;
q(1,5,2)=1.6801771;
q(1,6,1)=0.2411992;
q(1,6,2)=0.5710728;
q(1,7,1)=1.7215029;
q(1,7,2)=1.6988203;
q(2,3,1)=1.0514122;
q(2,3,2)=1.986242;
q(2,7,1)=1.2977126;
q(2,7,2)=1.9846382;
q(2,10,1)=0.1000840;
q(2,10,2)=1.4971013;
q(2,13,1)=0.8208118;
q(2,13,2)=1.2169053;
q(2,14,1)=1.7088422;
q(2,14,2)=0.1285293;
q(3,4,1)=1.6558166;
q(3,4,2)=1.8524688;
q(3,8,1)=1.1334423;
q(3,8,2)=1.1423278;
q(3,12,1)=1.6320221;
q(3,12,2)=0.1137856;
q(3,13,1)=1.1191873;
q(3,13,2)=0.2498681;
q(4,5,1)=1.4558445;
q(4,5,2)=0.5355533;
q(4,8,1)=1.093067;
q(4,8,2)=1.9770815;
q(4,9,1)=1.4791313;
q(4,9,2)=0.0074346;
q(5,6,1)=1.1801146;
q(5,6,2)=0.6192935;
q(5,9,1)=0.5104411;
q(5,9,2)=1.2503759;
q(5,15,1)=0.2314835;
q(5,15,2)=1.2234008;
q(5,16,1)=1.3567913;
q(5,16,2)=0.6640191;
q(6,7,1)=0.0517420;
q(6,7,2)=1.0348936;
q(6,11,1)=0.7833746;
q(6,11,2)=0.4827077;
q(6,16,1)=1.012887;
q(6,16,2)=0.8472204;
q(6,17,1)=0.5787455;
q(6,17,2)=0.1775864;
q(7,10,1)=1.2425764;
q(7,10,2)=0.6909969;
q(7,11,1)=1.4129735;
q(7,11,2)=1.0422945;
q(8,9,1)=0.5740802;
q(8,9,2)=1.300559;
q(8,12,1)=0.1762670;
q(8,12,2)=0.8997527;
q(9,15,1)=1.4454506;
q(9,15,2)=1.7953593;
q(10,11,1)=0.4855644;
q(10,11,2)=0.8675442;
q(10,14,1)=1.9354106;
q(10,14,2)=1.0137069;
q(11,17,1)=1.0465953;
q(11,17,2)=1.1193895;
q(12,13,1)=1.1234614;
q(12,13,2)=0.9363520;
q(13,14,1)=1.5589093;
q(13,14,2)=1.5802144;
q(15,16,1)=1.9617084;
q(15,16,2)=1.6374132;
q(16,17,1)=1.9617084;
q(16,17,2)=1.6374132;
for i=2:NS //Symétrisation
    for j=1:(i-1)
        q(i,j,:)=q(j,i,:);
    end
end
q2=zeros(NS,NS,P); //Déchets par paramètres
for k=1:P
    l=GI(k);
    for i=1:NS
        for j=1:NS
            q2(i,j,k)=0;
            for h=1:NPE
                q2(i,j,k)=q2(i,j,k)+q(i,j,h)*Q(h,l(h));
            end
        end
    end
end
q2A=q2;

N=3; //Nombre de tournées
C=170; //Capacité d'un camion
