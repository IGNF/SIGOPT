tic()

mclose('matrice_distance.csv');
u1=mopen('matrice_distance.csv');
i=0;
NS=0;
while i<>[]
    i=mfscanf(u1,';%d');
    NS=NS+1;
end
NS=NS-1;
c=zeros(NS,NS);
for i=1:NS
    mfscanf(u1,'%d');
    for j=1:NS
        c(i,j)=mfscanf(u1,';%f');
    end
end
mclose('trash_quant.csv');
u2=mopen('trash_quant.csv');
for i=1:NS
    mfscanf(u2,';%d');
end
q=zeros(NS,NS);
for i=1:NS
    mfscanf(u2,'%d');
    for j=1:NS
        q(i,j)=mfscanf(u2,';%f');
    end
end
q(q<0)=0;
qA=q;
a=bool2s(c>0);

c=3*c/mean(c);

NA=sum(a); //Nombre d'arcs (orientés)
D=list();
for i=1:NS
    D(i)=Dijkstra(a,c,i);
end

d=zeros(NS,NS); //distances (coûts)
for i=1:NS
    for j=(i+1):NS
        CH=pcch(a,c,i,D(j),j);
        for h=1:(length(CH)-1)
            d(i,j)=d(i,j)+c(CH(h),CH(h+1));
            d(j,i)=d(j,i)+c(CH(h),CH(h+1));
        end
    end
end

PCCH=list();
for i=1:NS
    PCCH(i)=list();
end
for i=1:NS
    for j=1:NS
        PCCH(i)(j)=pcch(a,c,i,D(j),j);
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
N=5; //Nombre de tournées
C=650000; //Capacité d'un véhicule
CC=0; //Capacité courante utilisée
tau=ones(NA,NA); //Phéromones (entre deux arcs servis consécutivement)
az=1;
T=zeros(NS,NS);

for i=1:NS //Indexation des arcs
    for j=1:NS
        if a(i,j)==1 then
            T(i,j)=az;
            az=az+1;
        end
    end
end
tau1=a;
tauA=tau; //Quantité initiale de phéromones
rho=0.98; //Coefficient d'évaporation
alpha=1;
beta=1;

//Path-scanning

//X=list(); //Trajet
//Y=list(); //Déblayages
//NC=1; //Noeud courant
//for k=1:N
//    X(k)=1;
//    Y(k)=[];
//end
//for k=1:N
//    while CC<C/2
//        if V(NC)==[] then
//            V(NC)=VA(NC);
//        end
//        for h=V(NC)
//            A(h)=d(1,h);
//        end
//        NC=find(A==max(A));
//        if length(NC)>1 then
//            NC=NC(grand(1,"uin",1,length(NC)));
//        end
//        X(k)=[X(k) NC];
//        if q(X(k)(length(X(k))-1),NC)<=C-CC & q(X(k)(length(X(k))-1),NC)>0 then
//            Y(k)=[Y(k) 1];
//            CC=CC+q(X(k)(length(X(k))-1),NC);
//            q(X(k)(length(X(k))-1),NC)=0;
//            q(NC,X(k)(length(X(k))-1))=0;
//            V(NC)=V(NC)(V(NC)<>X(k)(length(X(k))-1)); //Fermeture de l'arc
//            V(X(k)(length(X(k))-1))=V(X(k)(length(X(k))-1))(V(X(k)(length(X(k))-1))<>NC);
//        else
//            Y(k)=[Y(k) 0];
//        end
//        clear A
//    end
//    while NC<>1
//        if V(NC)==[] then
//            V(NC)=VA(NC);
//        end
//        for h=1:length(V(NC))
//            A(h)=d(1,V(NC)(h));
//        end
//        h=find(A==min(A));
//        if length(h)>1 then
//            h=h(grand(1,"uin",1,length(h)));
//        end
//        NC=V(NC)(h);
//        X(k)=[X(k) NC];
//        if q(X(k)(length(X(k))-1),NC)<=C-CC & q(X(k)(length(X(k))-1),NC)>0 then
//            Y(k)=[Y(k) 1];
//            CC=CC+q(X(k)(length(X(k))-1),NC);
//            q(X(k)(length(X(k))-1),NC)=0;
//            q(NC,X(k)(length(X(k))-1))=0;
//            V(NC)=V(NC)(V(NC)<>X(k)(length(X(k))-1)); //Fermeture de l'arc
//            V(X(k)(length(X(k))-1))=V(X(k)(length(X(k))-1))(V(X(k)(length(X(k))-1))<>NC);
//        else
//            Y(k)=[Y(k) 0];
//        end
//        clear A
//    end
//    CC=0; //Vidage du camion
//end
//
//L=cout2(X,Y,c,qA);

//Amélioration de la solution par colonie de fourmis

Gachette=0;
q=qA; //Réinitialisation des déchets
V=VA; //Réinitialisation des voisins
Lseuil=120; //Plafond des bonnes solutions
NC=0; //Noeud courant
pp=1; //Probabilité de diversification
K=5;
NbIter=2000;
MC=%inf;
Compteur=0;
tau=tauA;
tau1=a;
L3=ones(1,NbIter);
Lminsol=%inf;
pe=0.005^(1/NbIter);
n=0;

while n<=NbIter
    n=n+1;
    pp=pe*pp;
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
                if length(X(k))==1 then
                    for l=2:NS
                        A(1,l)=q(1,l);
                    end
                else
                    for h=1:NS
                        for l=1:NS
                            if q(h,l)<=C-CC then
                                A(h,l)=q(h,l)*s(NC,h);
                            end
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
                    Gachette=1;
                    CH=PCCH(NC)(1);
                    if length(CH)>=2 then
                        e=CH(length(CH)-1);
                    else
                        break
                    end
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
                B=PCCH(NC)(km);
                B=B(B<>NC);
                B=B';
                X(k)=[X(k) B lm];
                if Gachette==0 then
                    Y(k)=[Y(k) zeros(1,length(B)) 1];
                else
                    Y(k)=[Y(k) zeros(1,length(B)) 0];
                end
                CC=CC+q(km,lm);
                q(km,lm)=0;
                q(lm,km)=0;
                NC=lm;
            else //Intensification
                A=zeros(NS,NS);
                if NC==1 & length(X(k))==1 & k==1 then
                    for l=2:NS
                        if q(1,l)>0 & a(1,l)==1 then
                            A(1,l)=tau1(1,l)^beta;
                        end
                    end
                elseif NC==1 & length(X(k))==1 then
                    I1=find(Y(k-1)==1);
                    for h=1:NS
                        for l=1:NS
                            if q(h,l)>0 & a(h,l)==1 then
                                if I1<>[] then
                                    A(h,l)=tau(T(X(k-1)(I1(length(I1))),X(k-1)(I1(length(I1))+1)),T(h,l))^beta;
                                else
                                    A(h,l)=1;
                                end
                            end
                        end
                    end
                else
                    for h=1:NS
                        for l=1:NS
                            if q(h,l)>0 & q(h,l)<=C-CC & a(h,l)==1 & NC<>1 then
                                A(h,l)=s(NC,h)^alpha*tau(T(X(k)(length(X(k))-1),NC),T(h,l))^beta;
                            end
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
                    Gachette=1;
                    CH=PCCH(NC)(1);
                    if length(CH)>=2 then
                        e=CH(length(CH)-1);
                    else
                        break
                    end
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
//                                pause
                B=PCCH(NC)(km);
                B=B(B<>NC);
                B=B';
                X(k)=[X(k) B lm];
                if Gachette==0 then
                    Y(k)=[Y(k) zeros(1,length(B)) 1];
                else
                    Y(k)=[Y(k) zeros(1,length(B)) 0];
                end
                CC=CC+q(km,lm);
                q(km,lm)=0;
                q(lm,km)=0;
                NC=lm;
            end
            Gachette=0;
            //            pause
        end
        if NC<>1 then
            B=PCCH(NC)(1);
            B=B(B<>NC);
            B=B';
            X(k)=[X(k) B];
            Y(k)=[Y(k) zeros(1,length(B))];
        end
        CC=0;
        NC=0;
    end
    q=qA;
    L(n)=cout2(X,Y,c,qA);
    Lmin=min(L);
    L3(n)=coutcarp(X,Y,c,q);
    if IsSolution(X,Y,qA)==1 & L3(n)<Lminsol then
        Xminsol=X;
        Yminsol=Y;
        Lminsol=L3(n);
    end
    if n==1 then
        Xmin=X;
        Ymin=Y;
        Lmin1=L(1);
    end
    tau=rho*tau;
    tau1=rho*tau1;
    if L(n)<Lmin1 then
        tau=tauA;
        tau1=a;
        Xmin=X;
        Ymin=Y;
        Lmin1=Lmin;
    end
    if IsSolution(X,Y,qA)==1 then //test
        Compteur=Compteur+1;
    for k=1:N
        I=find(Y(k)==1);
        for h=1:(length(I)-1)
            //Traces "intra-tournées"
            tau(T(X(k)(I(h)),X(k)(I(h)+1)),T(X(k)(I(h+1)),X(k)(I(h+1)+1)))=tau(T(X(k)(I(h)),X(k)(I(h)+1)),T(X(k)(I(h+1)),X(k)(I(h+1)+1)))+exp((Lseuil-L(n)))*(Lseuil-L(n)>=0);
        end
    end
    for k=2:N //Traces "inter-tournées"
        I1=find(Y(k-1)==1);
        I2=find(Y(k)==1);
        if I2==[] | I1==[] then
            continue
        end
        tau(T(X(k-1)(I1(length(I1))),X(k-1)(I1(length(I1))+1)),T(X(k)(I2(1)),X(k)(I2(1)+1)))=tau(T(X(k-1)(I1(length(I1))),X(k-1)(I1(length(I1))+1)),T(X(k)(I2(1)),X(k)(I2(1)+1)))+exp((Lseuil-L(n)))*(Lseuil-L(n)>=0);
    end
    tau1(X(1)(1),X(1)(2))=tau1(X(1)(1),X(1)(2))+exp((Lseuil-L(n)))*(Lseuil-L(n)>=0); //Trace sur le tout premier arc
    end //test
    Lseuil=Lmin*1.2;
end
for i=1:NbIter
    L2(i)=mean(L(i:length(L)));
end

t=toc();


ST=mopen('tournee.txt','a');
for i=1:size(Xminsol)
    mfprintf(ST,'%d',Xminsol(i)(1));
    for j=2:length(Xminsol(i))
        mfprintf(ST,' %d',Xminsol(i)(j));
    end
    if i<size(Xminsol) then
        mfprintf(ST,'\n');
    end
end

SR=mopen('deblais.txt','a');
for i=1:size(Yminsol)
    mfprintf(SR,'%d',Yminsol(i)(1));
    for j=2:length(Yminsol(i))
        mfprintf(SR,' %d',Yminsol(i)(j));
    end
    if i<size(Yminsol) then
        mfprintf(SR,'\n');
    end
end