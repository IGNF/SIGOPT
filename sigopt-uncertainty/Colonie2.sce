//Initialisation du graphe
save=1
c=csvRead("/home/mickael/Téléchargements/donnees_test/test_sofiane/matrice_distance.csv",";")
c=c(2:size(c,1),2:size(c,2))
q=csvRead("/home/mickael/Téléchargements/donnees_test/test_sofiane/trash_quant.csv",";")
q=q(2:size(q,1),2:size(q,2))
qA=q; //Quantités initiales de déchets
a=bool2s(c>0); //Matrice d'adjacence
D=Dijkstra(a,c,1); //Distance au dépôt
d=zeros(NS,NS); //distances (coûts)
for i=1:NS
    for j=(i+1):NS
        CH=pcch2(a,c,i,j);
        for h=1:(length(CH)-1)
            d(i,j)=d(i,j)+c(CH(h),CH(h+1));
            d(j,i)=d(j,i)+c(CH(h),CH(h+1));
        end
    end
end
Md=max(d);
s=zeros(NS,NS); //Mesure d'économie de déplacement
for i=1:NS
    for j=1:NS
        s(i,j)=1/(1+100*d(i,j));
    end
end
V=list(); //Voisinages de chaque sommet
for k=1:NS
    V(k)=find(a(k,:)==1);
end
VA=V; //Voisinages absolus
N=3; //Nombre de tournées
C=170; //Capacité d'un véhicule
CC=0; //Capacité courante utilisée
tau=zeros(NS,NS,NS,NS); //Phéromones (entre deux arcs servis consécutivement)
for i=1:NS
    for j=1:NS
        for k=1:NS
            for l=1:NS
                if a(i,j)==1 & a(k,l)==1 then
                    tau(i,j,k,l)=1;
                end
            end
        end
    end
end
tau(1,1,:,:)=a;
tauA=tau; //Quantité initiale de phéromones
rho=0.7; //Coefficient d'évaporation
alpha=1;
beta=1;

//Path-scanning

X=list(); //Trajet
Y=list(); //Déblayages
NC=1; //Noeud courant
for k=1:N
    X(k)=1;
    Y(k)=[];
end
for k=1:N
    while CC<C/2
        if V(NC)==[] then
            V(NC)=VA(NC);
        end
        for h=V(NC)
            A(h)=d(1,h);
        end
        NC=find(A==max(A));
        if length(NC)>1 then
            NC=NC(grand(1,"uin",1,length(NC)));
        end
        X(k)=[X(k) NC];
        if q(X(k)(length(X(k))-1),NC)<=C-CC & q(X(k)(length(X(k))-1),NC)>0 then
            Y(k)=[Y(k) 1];
            CC=CC+q(X(k)(length(X(k))-1),NC);
            q(X(k)(length(X(k))-1),NC)=0;
            q(NC,X(k)(length(X(k))-1))=0;
            V(NC)=V(NC)(V(NC)<>X(k)(length(X(k))-1)); //Fermeture de l'arc
            V(X(k)(length(X(k))-1))=V(X(k)(length(X(k))-1))(V(X(k)(length(X(k))-1))<>NC);
        else
            Y(k)=[Y(k) 0];
        end
        clear A
    end
    while NC<>1
        if V(NC)==[] then
            V(NC)=VA(NC);
        end
        for h=1:length(V(NC))
            A(h)=d(1,V(NC)(h));
        end
        h=find(A==min(A));
        if length(h)>1 then
            h=h(grand(1,"uin",1,length(h)));
        end
        NC=V(NC)(h);
        X(k)=[X(k) NC];
        if q(X(k)(length(X(k))-1),NC)<=C-CC & q(X(k)(length(X(k))-1),NC)>0 then
            Y(k)=[Y(k) 1];
            CC=CC+q(X(k)(length(X(k))-1),NC);
            q(X(k)(length(X(k))-1),NC)=0;
            q(NC,X(k)(length(X(k))-1))=0;
            V(NC)=V(NC)(V(NC)<>X(k)(length(X(k))-1)); //Fermeture de l'arc
            V(X(k)(length(X(k))-1))=V(X(k)(length(X(k))-1))(V(X(k)(length(X(k))-1))<>NC);
        else
            Y(k)=[Y(k) 0];
        end
        clear A
    end
    CC=0; //Vidage du camion
end

L=cout2(X,Y,c,qA);

//Amélioration de la solution par colonie de fourmis

Gachette=0;
q=qA; //Réinitialisation des déchets
V=VA; //Réinitialisation des voisins
Lseuil=120; //Plafond des bonnes solutions
NC=0; //Noeud courant
pp=1; //Probabilité de diversification
K=3;
NbIter=500;
MC=%inf;
Compteur=0;
tau=tauA;

for n=1:NbIter
    pp=0.985*pp;
    X=list();
    Y=list();
    for k=1:N
        X(k)=1;
        Y(k)=[];
    end
    for k=1:N
        while NC<>1
            p=rand(1,'uniform');
            if NC==0 then
                NC=1;
            end
            if p<=pp then //Diversification
                A=zeros(NS,NS);
                if NC==1 then
                    for l=2:NS
                        A(1,l)=q(1,l);
                    end
                end
                for h=2:NS
                    for l=1:NS
                        if q(h,l)<=C-CC then
                            A(h,l)=q(h,l)*s(NC,h);
                        end
                    end
                end
                if CC<=C/4 then
                    for i=V(1)
                        A(i,1)=A(i,1)/10;
                    end
                end
                if CC>=3*C/4 then
                    for i=V(1)
                        A(i,1)=A(i,1)*10;
                    end
                end
                if sum(A)==0 then
                    CH=pcch(a,c,NC,D);
                    e=CH(length(CH)-1);
                    A(e,1)=1;
                end
                b=gsort(matrix(A,1,length(A)));
                b=b(1:K);
                b=b(b>0);
                u=rand(1,'uniform');
                b2=cumsum(b)/sum(b);
                for i=1:length(b)
                    if u<=b2(i) then
                        [km,lm]=find(A==b(i));
                        break
                    end
                end
                g=grand(1,"uin",1,length(km));
                km=km(g);
                lm=lm(g);
//                pause
                B=pcch2(a,c,NC,km);
                B=B(B<>NC);
                B=B';
                X(k)=[X(k) B lm];
                Y(k)=[Y(k) zeros(1,length(B)) 1];
                CC=CC+q(km,lm);
                q(km,lm)=0;
                q(lm,km)=0;
                NC=lm;
            else //Intensification
                A=zeros(NS,NS);
                if NC==1 & k==1 then
                    for l=2:NS
                        if q(1,l)>0 & a(1,l)==1 then
                            A(1,l)=tau(1,1,1,l)^beta;
                        end
                    end
                elseif NC==1 then
                    I1=find(Y(k-1)==1);
                    for l=2:NS
                        if q(1,l)>0 & a(1,l)==1 then
                            A(1,l)=tau(X(k-1)(I1(length(I1))),X(k-1)(I1(length(I1))+1),1,l)^beta;
                        end
                    end
                end
                for h=2:NS
                    for l=1:NS
                        if q(h,l)>0 & q(h,l)<=C-CC & a(h,l)==1 & NC<>1 then
                            A(h,l)=s(NC,h)^alpha*tau(X(k)(length(X(k))-1),NC,h,l)^beta;
                        end
                    end
                end
                if CC<=2*C/3 then
                    for i=V(1)
                        A(i,1)=A(i,1)/10;
                    end
                end
                if CC>=C-mean(qA(qA>0)) then
                    for i=V(1)
                        A(i,1)=A(i,1)*10;
                    end
                end
                b=gsort(matrix(A,1,length(A)));
                b=b(1:K);
                b=b(b>0);
                u=rand(1,'uniform');
                if b==[] then
                    Gachette=1;
                    break
                end
                b2=cumsum(b)/sum(b);
                for i=1:5
                    if u<=b2(i) then
                        [km,lm]=find(A==b(i));
                        break
                    end
                end
                g=grand(1,"uin",1,length(km));
                km=km(g);
                lm=lm(g);
//                pause
                B=pcch2(a,c,NC,km);
                B=B(B<>NC);
                B=B';
                X(k)=[X(k) B lm];
                Y(k)=[Y(k) zeros(1,length(B)) 1];
                CC=CC+q(km,lm);
                q(km,lm)=0;
                q(lm,km)=0;
                NC=lm;
            end
            //            pause
        end
        CC=0;
        if Gachette==1 then //Retour dépôt
            B=pcch(a,c,NC,D);
            B=B(B<>NC);
            B=B';
            X(k)=[X(k) B];
            Y(k)=[Y(k) zeros(1,length(B))];
            Gachette=0;
        end
        NC=0;
    end
    q=qA;
    L(n)=cout2(X,Y,c,qA);
    Lmin=min(L);
    if n==1 then
        Xmin=X;
        Ymin=Y;
        Lmin1=L(1);
    end
    tau=rho*tau;
    if L(n)<Lmin1 then
        Compteur=Compteur+1;
        disp('youhou')
        disp(Lmin)
        tau=tauA;
        Xmin=X;
        Ymin=Y;
        Lmin1=Lmin;
    end
        for k=1:N
            I=find(Y(k)==1);
            for h=1:(length(I)-1)
                //Traces "intra-tournées"
                tau(X(k)(I(h)),X(k)(I(h)+1),X(k)(I(h+1)),X(k)(I(h+1)+1))=tau(X(k)(I(h)),X(k)(I(h)+1),X(k)(I(h+1)),X(k)(I(h+1)+1))+exp((Lseuil-L(n)))*(Lseuil-L(n)>=0);
            end
        end
        for k=2:N //Traces "inter-tournées"
            I1=find(Y(k-1)==1);
            I2=find(Y(k)==1);
            tau(X(k-1)(I1(length(I1))),X(k-1)(I1(length(I1))+1),X(k)(I2(1)),X(k)(I2(1)+1))=tau(X(k-1)(I1(length(I1))),X(k-1)(I1(length(I1))+1),X(k)(I2(1)),X(k)(I2(1)+1))+exp((Lseuil-L(n)))*(Lseuil-L(n)>=0);
        end
        tau(1,1,X(1)(1),X(1)(2))=tau(1,1,X(1)(1),X(1)(2))+exp((Lseuil-L(n)))*(Lseuil-L(n)>=0); //Trace sur le tout premier arc

end
for i=1:NbIter
    L2(i)=mean(L(i:NbIter));
end
if save==1 then
    for i=1:size(Xmin)
        if i ==1 then
            u = Xmin(i)
            continue
        end
        u=[u,Xmin(i)]
    end
    for i=1:size(Ymin)
         if i ==1 then
            w = Ymin(i)
            continue
        end
        w=[w,Ymin(i)]
    end
    csvWrite(u, "/home/mickael/Téléchargements/donnees_test/test_sofiane/path.csv",";")
    csvWrite(w, "/home/mickael/Téléchargements/donnees_test/test_sofiane/remove.csv",";")
end
