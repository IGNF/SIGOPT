tic()
//Importation des données

mclose('val4D.dat');
u=mopen('val4D.dat');
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

//Algo

qA=q;
D=Dijkstra(a,c,depot); //Distance au dépôt
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
CC=0; //Capacité courante utilisée
tau=ones(2*NA,2*NA); //Phéromones (entre deux arcs servis consécutivement)
az=1;
T=zeros(NS,NS);
for i=1:NS
    for j=1:NS
        if a(i,j)==1 then
            T(i,j)=az;
            az=az+1;
        end
    end
end
tau1=a;
tauA=tau; //Quantité initiale de phéromones
rho=0.99; //Coefficient d'évaporation
alpha=1;
beta=1;
Gachette=0;
Lseuil=borne_sup; //Plafond des bonnes solutions
NC=0; //Noeud courant
pp=1; //Probabilité de diversification
K=3;
NbIter=500;
MC=%inf;
Compteur=0;
L=%inf*ones(1,NbIter);
L2=ones(1,NbIter);
L3=ones(1,NbIter);
Lminsol=%inf;

for n=1:NbIter
    pp=0.99*pp;
    X=list();
    Y=list();
    for k=1:N
        X(k)=1;
        Y(k)=[];
    end
    for k=1:N
        while sum(q)>0 & min(q(q>0))<=C-CC
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
//                if n>=490 then
//                    pause
//                end
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
                    CH=pcch(a,c,NC,D);
                    if length(CH)>=2 then
                        e=CH(length(CH)-1);
                    else
//                        e=1;
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
                B=pcch2(a,c,NC,km);
                B=B(B<>NC);
                B=B';
                X(k)=[X(k) B lm];
//                if Gachette==0 then
                    Y(k)=[Y(k) zeros(1,length(B)) 1];
//                else
//                    Y(k)=[Y(k) zeros(1,length(B)) 0];
//                end
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
//                if n>=490 then
//                    pause
//                end
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
                if sum(A)==0 then
                    Gachette=1;
                    CH=pcch(a,c,NC,D);
                    if length(CH)>=2 then
                        e=CH(length(CH)-1);
                    else
//                        e=1;
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
                B=pcch2(a,c,NC,km);
                B=B(B<>NC);
                B=B';
                X(k)=[X(k) B lm];
//                if Gachette==0 then
                    Y(k)=[Y(k) zeros(1,length(B)) 1];
//                else
//                    Y(k)=[Y(k) zeros(1,length(B)) 0];
//                end
                CC=CC+q(km,lm);
                q(km,lm)=0;
                q(lm,km)=0;
                NC=lm;
            end
//            if Gachette==1 then
//                Gachette=0;
//                break
//            end
            Gachette=0;
            //            pause
        end
        if NC<>1 then
            B=pcch2(a,c,NC,1);
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
    L3(n)=coutcarp(X,Y,c,qA);
    Lmin=min(L);
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
        Compteur=Compteur+1;
        tau=tauA;
        tau1=a;
        Xmin=X;
        Ymin=Y;
        Lmin1=Lmin;
    end
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
        if I2<>[] & I1<>[] then
            tau(T(X(k-1)(I1(length(I1))),X(k-1)(I1(length(I1))+1)),T(X(k)(I2(1)),X(k)(I2(1)+1)))=tau(T(X(k-1)(I1(length(I1))),X(k-1)(I1(length(I1))+1)),T(X(k)(I2(1)),X(k)(I2(1)+1)))+exp((Lseuil-L(n)))*(Lseuil-L(n)>=0);
        end
    end
    tau1(X(1)(1),X(1)(2))=tau1(X(1)(1),X(1)(2))+exp((Lseuil-L(n)))*(Lseuil-L(n)>=0); //Trace sur le tout premier arc
    Lseuil=min(Lseuil,Lmin+20);
end
for i=1:NbIter
    L2(i)=mean(L(i:NbIter));
end
t=toc();
