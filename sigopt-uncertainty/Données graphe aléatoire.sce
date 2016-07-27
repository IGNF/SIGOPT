//Données graphe aléatoire

NPE=2; //Nombre de paramètres environnementaux (déchets)

//Choix d'un jeu de paramètres de lois gamma
k=[25 35]; //Shape parameters
mu=[6 7]; //Moyennes
Beta=k./mu; //Rate parameters
NQ=7; //Nombre de quantiles extraits + 1
Q=zeros(NPE,NQ-1);
for i=1:NPE
    for l=1:(NQ-1)
        Q(i,l)=cdfgam("X",k(i),Beta(i),l/NQ,1-l/NQ);
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

//Quantités de déchets
P=size(G); //Taille de la grille=nombre de fourmis dans une colonie
NS=17;
q=zeros(NS,NS,NPE); //Coordonnées de déchets en composantes principales (ici: choix aléatoire)
for i=1:NS
    for j=(i+1):NS
        if a(i,j)==1 then
            q(i,j,:)=2*rand(1,NPE,"uniform");
        end
    end
end
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
