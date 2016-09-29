tic()
q2A=q2; //Quantités initiales de déchets
NA=sum(a); //Nombre d'arcs (orientés)
D=list();
for i=1:NS
    D(i)=Dijkstra(a,c,i); //Distances entre les sommets
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
VA=V; //Voisinages initiaux
CC=0; //Capacité courante utilisée
tau=ones(NA,NA,P); //Phéromones (entre deux arcs servis consécutivement)
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
tau1=zeros(NS,NS,P);
for pa=1:P
    tau1(:,:,pa)=a;
end
tauA=tau; //Quantité initiale de phéromones
tau1A=tau1;
rho=0.99; //Coefficient d'évaporation
alpha=1;
beta=1;
N=N*ones(1,P);

for pa=1:P //Adaptation du nombre de camions
    Q=sum(q2A(:,:,pa))/2;
    while Q/(N(pa)*C)>0.9
        N(pa)=N(pa)+1;
    end
end

//Colonie de fourmis intrusive

Gachette=0;
Lseuil=200*ones(1,P); //Plafond des bonnes solutions
NC=0; //Noeud courant
pp=1; //Probabilité de diversification
K=5;
NbIter=300;
Compteur=0;
tau=tauA;
tau1=tau1A;
Lmin=%inf*ones(1,P);
Lmin1=%inf*ones(1,P);
L=%inf*ones(P,NbIter);
X=list();
Y=list();
Xmin=list();
Ymin=list();
t1=zeros(1,NbIter);
t2=zeros(1,NbIter);
pe=0.005^(1/NbIter);

for n=1:NbIter
    pp=pe*pp;
    for pa=15
        X(pa)=list();
        Y(pa)=list();
        for k=1:N(pa)
            X(pa)(k)=1;
            Y(pa)(k)=[];
        end
        for k=1:N(pa)
            while NC<>1
                p=rand(1,'uniform');
                if NC==0 then
                    NC=1;
                end
                if p<=pp then //Diversification
                    A=zeros(NS,NS);
                    if length(X(pa)(k))==1 then
                        for l=2:NS
                            A(1,l)=q2(1,l,pa);
                        end
                    else
                        for h=1:NS
                            for l=1:NS
                                if q2(h,l,pa)<=C-CC then
                                    A(h,l)=q2(h,l,pa)*s(NC,h);
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
//                    if n>=50 & pa==1 then
//                        pause
//                    end
                    B=PCCH(NC)(km);
                    B=B(B<>NC);
                    B=B';
                    X(pa)(k)=[X(pa)(k) B lm];
                    if Gachette==0 then
                        Y(pa)(k)=[Y(pa)(k) zeros(1,length(B)) 1];
                    else
                        Y(pa)(k)=[Y(pa)(k) zeros(1,length(B)) 0];
                    end
                    CC=CC+q2(km,lm,pa);
                    q2(km,lm,pa)=0;
                    q2(lm,km,pa)=0;
                    NC=lm;
                else //Intensification
                    A=zeros(NS,NS);
                    if NC==1 & length(X(pa)(k))==1 & k==1 then
                        for l=2:NS
                            if q2(1,l,pa)>0 & a(1,l)==1 then
                                A(1,l)=tau1(1,l,pa)^beta;
                            end
                        end
                    elseif NC==1 & length(X(pa)(k))==1 then
                        I1=find(Y(pa)(k-1)==1);
                        for h=1:NS
                            for l=1:NS
                                if q2(h,l,pa)>0 & a(h,l)==1 then
                                    if I1<>[] then
                                        A(h,l)=tau(T(X(pa)(k-1)(I1(length(I1))),X(pa)(k-1)(I1(length(I1))+1)),T(h,l),pa)^beta;
                                    else
                                        A(h,l)=1;
                                    end
                                end
                            end
                        end
                    else
                        for h=1:NS
                            for l=1:NS
                                if q2(h,l,pa)>0 & q2(h,l,pa)<=C-CC & a(h,l)==1 & NC<>1 then
                                    A(h,l)=s(NC,h)^alpha*tau(T(X(pa)(k)(length(X(pa)(k))-1),NC),T(h,l),pa)^beta;
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
//                    if n>=50 & pa==1 then
//                        pause
//                    end
                    B=PCCH(NC)(km);
                    B=B(B<>NC);
                    B=B';
                    X(pa)(k)=[X(pa)(k) B lm];
                    if Gachette==0 then
                        Y(pa)(k)=[Y(pa)(k) zeros(1,length(B)) 1];
                    else
                        Y(pa)(k)=[Y(pa)(k) zeros(1,length(B)) 0];
                    end
                    CC=CC+q2(km,lm,pa);
                    q2(km,lm,pa)=0;
                    q2(lm,km,pa)=0;
                    NC=lm;
                end
                Gachette=0;
            end
            if NC<>1 then
                B=PCCH(NC)(1);
                B=B(B<>NC);
                B=B';
                X(pa)(k)=[X(pa)(k) B];
                Y(pa)(k)=[Y(k) zeros(1,length(B))];
            end
            CC=0;
            NC=0;
        end

        L(pa,n)=cout2(X(pa),Y(pa),c,q2A(:,:,pa));
        Lmin(pa)=min(L(pa,:));
        if n==1 then
            Xmin(pa)=X(pa);
            Ymin(pa)=Y(pa);
            Lmin1(pa)=L(pa,1);
        end
        tau(:,:,pa)=rho*tau(:,:,pa);
        tau1(:,:,pa)=rho*tau1(:,:,pa);
        if L(pa,n)<Lmin1(pa) then
            tau(:,:,pa)=tauA(:,:,pa);
            tau1(:,:,pa)=tau1A(:,:,pa);
            for v=VP(pa)
                tau(:,:,v)=(1/2)*tau(:,:,v)+(1/2)*tauA(:,:,v);
                tau1(:,:,v)=(1/2)*tau1(:,:,v)+(1/2)*tau1A(:,:,v);
            end
            Xmin(pa)=X(pa);
            Ymin(pa)=Y(pa);
            Lmin1(pa)=Lmin(pa);
        end
        for k=1:N(pa)
            I=find(Y(pa)(k)==1);
            for h=1:(length(I)-1) //Traces "intra-tournées"
                tau(T(X(pa)(k)(I(h)),X(pa)(k)(I(h)+1)),T(X(pa)(k)(I(h+1)),X(pa)(k)(I(h+1)+1)),pa)=tau(T(X(pa)(k)(I(h)),X(pa)(k)(I(h)+1)),T(X(pa)(k)(I(h+1)),X(pa)(k)(I(h+1)+1)),pa)+exp((Lseuil(pa)-L(pa,n)))*(Lseuil(pa)-L(pa,n)>=0);
                for v=VP(pa)(1)
                    tau(T(X(pa)(k)(I(h)),X(pa)(k)(I(h)+1)),T(X(pa)(k)(I(h+1)),X(pa)(k)(I(h+1)+1)),v)=tau(T(X(pa)(k)(I(h)),X(pa)(k)(I(h)+1)),T(X(pa)(k)(I(h+1)),X(pa)(k)(I(h+1)+1)),v)+(1/2)*exp((Lseuil(pa)-L(pa,n)))*(Lseuil(pa)-L(pa,n)>=0);
                end
            end
        end
        for k=2:N(pa) //Traces "inter-tournées"
            I1=find(Y(pa)(k-1)==1);
            I2=find(Y(pa)(k)==1);
            if I1<>[] & I2<>[] then
                tau(T(X(pa)(k-1)(I1(length(I1))),X(pa)(k-1)(I1(length(I1))+1)),T(X(pa)(k)(I2(1)),X(pa)(k)(I2(1)+1)),pa)=tau(T(X(pa)(k-1)(I1(length(I1))),X(pa)(k-1)(I1(length(I1))+1)),T(X(pa)(k)(I2(1)),X(pa)(k)(I2(1)+1)),pa)+exp((Lseuil(pa)-L(pa,n)))*(Lseuil(pa)-L(pa,n)>=0);
                for v=VP(pa)(1)
                    tau(T(X(pa)(k-1)(I1(length(I1))),X(pa)(k-1)(I1(length(I1))+1)),T(X(pa)(k)(I2(1)),X(pa)(k)(I2(1)+1)),v)=tau(T(X(pa)(k-1)(I1(length(I1))),X(pa)(k-1)(I1(length(I1))+1)),T(X(pa)(k)(I2(1)),X(pa)(k)(I2(1)+1)),v)+(1/2)*exp((Lseuil(pa)-L(pa,n)))*(Lseuil(pa)-L(pa,n)>=0);
                end
            end
        end
        if length(X(pa)(1))>1 then
            tau1(X(pa)(1)(1),X(pa)(1)(2),pa)=tau1(X(pa)(1)(1),X(pa)(1)(2),pa)+exp((Lseuil(pa)-L(pa,n)))*(Lseuil(pa)-L(pa,n)>=0); //Trace sur le tout premier arc
            for v=VP(pa)(1)
                tau1(X(pa)(1)(1),X(pa)(1)(2),v)=tau1(X(pa)(1)(1),X(pa)(1)(2),v)+(1/2)*exp((Lseuil(pa)-L(pa,n)))*(Lseuil(pa)-L(pa,n)>=0);
            end
        end
        Lseuil(pa)=min(Lseuil(pa),Lmin(pa)*1.15);
    end
    q2=q2A;
end

//Opérateur de réparation
//Réalisations

ks=[25 35]; //Shape parameters
mu=[6 7]; //Moyennes
Beta=ks./mu; //Rate parameters
xi(1)=grand(1,1,'gam',ks(1),Beta(1));
xi(2)=grand(1,1,'gam',ks(2),Beta(2));
hcrue=6.5;
SE=1:NS;
SE=SE(alt(SE)<=hcrue);
A=zeros(1,pa);
for pa=1:P
    A(pa)=norm([xi(1),xi(2)]-G(pa),2);
end
I=find(A==min(A));
I=I(1);
xib=zeros(1,NPE);
for h=1:NPE
    xib(h)=G(I)(h);
end
Xsol=Xmin(I);
Ysol=Ymin(I);
[Xsol,Ysol]=modif2(a,SE,Xsol,Ysol);

t=toc();
