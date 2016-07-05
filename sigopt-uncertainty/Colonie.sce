//Initialisation du graphe
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
q=zeros(17,17); //Matrices des quantités de déchets
q(1,2)=15;
q(1,3)=12;
q(1,4)=13;
q(1,5)=13;
q(1,6)=10;
q(1,7)=10;
q(2,3)=13;
q(3,4)=10;
q(4,5)=11;
q(5,6)=14;
q(6,7)=11;
q(2,7)=12;
q(3,8)=14;
q(5,9)=10;
q(2,10)=15;
q(6,11)=11;
q(4,8)=11;
q(4,9)=12;
q(7,11)=12;
q(7,10)=13;
q(8,9)=17;
q(10,11)=16;
q(8,12)=12;
q(3,12)=11;
q(12,13)=10;
q(3,13)=15;
q(2,13)=14;
q(13,14)=11;
q(2,14)=12;
q(10,14)=13;
q(9,15)=10;
q(5,15)=15;
q(15,16)=12;
q(5,16)=14;
q(6,16)=13;
q(16,17)=11;
q(6,17)=10;
q(11,17)=14;
NS=17; //Nombre de sommets
for i=2:NS //Symétrisation
    for j=1:(i-1)
        c(i,j)=c(j,i);
        q(i,j)=q(j,i);
    end
end
qA=q;
a=bool2s(c>0); //Matrice d'adjacence
CE=300; //Coût étalon (à paramétrer)
NA=sum(a)/2; //Nombre d'arcs
//tau0=1/(CE*NA);
tau0=1;
aa=zeros(NS,NS,NS);
for i=1:NS //Matrice de paires d'arcs orientées
    for j=1:NS
        for k=1:NS
            if a(i,j)==1 & a(j,k)==1 then
                aa(i,j,k)=1;
            end
        end
    end
end
tau=tau0*aa; //Matrice de phéromones
CV=1/12;
eta=CV*q; //Matrice de visibilité
etaA=eta;
q0=0; //Coefficient d'équilibre Intensification/Diversification
V=list(); //Voisinages de chaque sommet
for k=1:NS
    V(k)=find(a(k,:)==1);
end
VA=V; //Voisinages absolus
alpha=1/256; //Paramètre d'importance des phéromones
beta=1; //Paramètre d'importance heuristique
N=3; //Nombre de tournées
K=40; //Nombre de fourmis dans la colonie
x=zeros(NS,NS,N); //Matrice de parcours
y=zeros(NS,NS,N); //Matrice de déblayage
Chemin=list();
C=170; //Capacité d'un véhicule
CC=0; //Capacité courante utilisée
rho=1/2; //Coefficient d'évaporation

//Colonie de fourmis

NC=1; //Noeud courant
NP=0; //Noeud précédent
F=0;
MC=%inf; //Meilleur coût
MCA=%inf; //Meilleur coût absolu
xMS=zeros(NS,NS,N); //Meilleure solution
yMS=zeros(NS,NS,N);
MCh=list();

NbIter=100; //Nombre d'itérations
xMSA=zeros(NS,NS,N); //Meilleure solution absolue
yMSA=zeros(NS,NS,N);
MChA=list();
X=[];
Y=[];
Z=[];
const=30;

d=Dijkstra(a,c,1); //Dijkstra: plus courte distance au dépôt

for n=1:NbIter
    for f=1:K
        for k=1:N
            Chemin(k)=1;
            while F<>1
                q1=rand(1,"uniform");
                for h=V(NC)
                    if NP<>0
                        A(h)=tau(NP,NC,h)^alpha*eta(NC,h)^beta;
                    else
                        A(h)=eta(NC,h)^beta;
                    end
                end
                if q1<=q0 then //Intensification
                    F=find(A==max(A));
                    F=F(1);
                    x(NC,F,k)=x(NC,F,k)+1;
                    Chemin(k)=[Chemin(k) F];
                    if q(NC,F)>0 then
                        y(NC,F,k)=1;
                        y(F,NC,k)=1;
                    end
                    CC=CC+q(NC,F);
                    q(NC,F)=0;
                    q(F,NC)=0;
                    eta(NC,F)=eta(NC,F)/100; //Baisse de visibilité
                    eta(F,NC)=eta(F,NC)/100;
                    if NP<>0
                        tau(NP,NC,F)=(1-rho)*tau(NP,NC,F)+rho*tau0; //Renouvellement local
                        tau(F,NC,NP)=(1-rho)*tau(F,NC,NP)+rho*tau0;
                    end
                    //V(NC)=V(NC)(V(NC)<>F); //Fermeture de l'arc
                    //V(F)=V(F)(V(F)<>NC);
                    NP=NC;
                    NC=F;
                else //Diversification
                    for j=V(NC)
                        pNC(j)=A(j)/sum(A);
                    end
                    r=rand(1,"uniform");
                    p=cumsum(pNC);
                    for h=V(NC)
                        if r<=p(h)
                            F=h;
                            break
                        end
                    end
                    x(NC,F,k)=x(NC,F,k)+1;
                    Chemin(k)=[Chemin(k) F];
                    if q(NC,F)>0 then
                        y(NC,F,k)=1;
                        y(F,NC,k)=1;
                    end
                    CC=CC+q(NC,F);
                    q(NC,F)=0;
                    q(F,NC)=0;
                    eta(NC,F)=eta(NC,F)/100; //Baisse de visibilité
                    eta(F,NC)=eta(F,NC)/100;
                    if NP<>0
                        tau(NP,NC,F)=(1-rho)*tau(NP,NC,F)+rho*tau0; //Renouvellement local
                        tau(F,NC,NP)=(1-rho)*tau(F,NC,NP)+rho*tau0;
                    end
                    //V(NC)=V(NC)(V(NC)<>F); //Fermeture de l'arc
                    //V(F)=V(F)(V(F)<>NC);
                    NP=NC;
                    NC=F;
                end
                clear A
                clear pNC
                clear p
                for h=V(NC)
                    if q(NC,h)>C-CC then //Retour à la maison
                        while F<>1
                            NP=NC;
                            NC=F;
                            F=pred(a,c,NC,d);
                            x(NC,F,k)=x(NC,F,k)+1;
                            Chemin(k)=[Chemin(k) F];
                            if q(NC,F)<=C-CC & sum(y(NC,F,:))==0 & sum(y(F,NC,:))==0 then
                                y(NC,F,k)=1; //Déblayages éventuels sur le retour
                                y(F,NC,k)=1;
                                CC=CC+q(NC,F);
                                q(NC,F)=0;
                                q(F,NC)=0;
                                eta(NC,F)=eta(NC,F)/100;
                                eta(F,NC)=eta(F,NC)/100;
                            end
                        end
                        break
                    end
                end
            end
            V=VA; //Réouverture des arcs
            CC=0; //Vidage du camion
            F=0;
            NP=0;
            NC=1;
        end
        eta=etaA; //Réinitialisation de la visibilité
        q=qA; //Réinitialisation des déchets
        Z=[Z cout(x,y,c,qA,N)];
        if cout(x,y,c,qA,N)<MC then
            xMS=x;
            MCh=Chemin;
            yMS=y;
            MC=cout(x,y,c,qA,N);
        end
        x=zeros(NS,NS,N);
        y=zeros(NS,NS,N);
        Chemin=list();
    end
    if MC<MCA then
        MCA=MC;
        xMSA=xMS;
        yMSA=yMS;
        MChA=MCh;
        nM=n;
    end
    X=[X MCA];
    for NN=1:N //Renouvellement global
        for j=2:(length(MChA(NN))-1)
            tau(MChA(NN)(j-1),MChA(NN)(j),MChA(NN)(j+1))=(1-rho)*tau(MChA(NN)(j-1),MChA(NN)(j),MChA(NN)(j+1))+rho*const;
            tau(MChA(NN)(j+1),MChA(NN)(j),MChA(NN)(j-1))=(1-rho)*tau(MChA(NN)(j+1),MChA(NN)(j),MChA(NN)(j-1))+rho*const;
        end
        j=j+1;
        if NN<>N
            tau(MChA(NN)(j-1),MChA(NN)(j),MChA(NN+1)(2))=(1-rho)*tau(MChA(NN)(j-1),MChA(NN)(j),MChA(NN+1)(2))+rho*const;
            tau(MChA(NN+1)(2),MChA(NN)(j),MChA(NN)(j-1))=(1-rho)*tau(MChA(NN+1)(2),MChA(NN)(j),MChA(NN)(j-1))+rho*const;
        end
    end
end
//disp(Compteur,"fourmis bloquées:")
disp(MChA)
