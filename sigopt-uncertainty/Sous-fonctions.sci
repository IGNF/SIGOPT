//Sous-fonctions
clear

//Dijkstra
function [d]=Dijkstra(a,c,ref) //Matrice d'adjacence, de coûts, sommet de référence
    P=[];
    l=size(a,1);
    c(a==0)=%inf;
    S=1:l;
    d0=%inf*ones(1,l);
    d0(ref)=0;
    while S<>[]
        F=find(d0==min(d0(S)));
        F=intersect(F,S);
        F=F(1);
        P=[P F];
        S=S(S<>F);
        for i=1:length(S)
            d0(S(i))=min(d0(S(i)),d0(F)+c(F,S(i)));
        end
    end
    d=d0;
endfunction

//Prédécesseur dans le plus court chemin du noeud h par rapport au noeud 1
function p=pred(a,c,h,d)
    c(a==0)=%inf;
    l=size(a,1);
    for k=1:l
        if d(h)==d(k)+c(k,h) then
            p=k;
            break
        end
    end
endfunction

//Prédécesseur dans le plus court chemin du noeud h par rapport au noeud ref
function p=pred2(a,c,h,ref)
    d=Dijkstra(a,c,ref);
    c(a==0)=%inf;
    l=size(a,1);
    for k=1:l
        if d(h)==d(k)+c(k,h) then
            p=k;
            break
        end
    end
endfunction

//Plus court chemin de h vers ref
function [CH]=pcch(a,c,h,d,ref)
    CH(1)=h;
    i=1;
    while CH(i)<>ref
        i=i+1;
        CH(i)=pred(a,c,CH(i-1),d);
    end
    CH(i)=ref;
endfunction

//Plus court chemin de h vers ref (coûteux)
function [CH]=pcch2(a,c,h,ref)
    CH(1)=h;
    i=1;
    while CH(i)<>ref
        i=i+1;
        CH(i)=pred2(a,c,CH(i-1),ref);
    end
    CH(i)=ref;
endfunction

//Coût d'une solution (obsolète)
function F=cout(x,y,c,q,N)
    lambda=1;
    gamma=1; //Paramètres d'importances relatives des distances et des déchets
    X=0;
    for k=1:N
        X=X+sum(x(:,:,k).*c);
    end
    Y=sum(y,3);
    Y=1-Y;
    Y(c==-1)=0;
    Y=sum(Y.*q);
    F=lambda*X+gamma*(1/2)*Y;
endfunction

//Coût d'une solution (avec le chemin en entrée) pour Colonie2
function G=cout2(X,Y,c,q)
    lambda=1;
    Gamma=4/mean(q); // 4/mean(q)
    A=0;
    B=sum(q)/2;
    for k=1:size(X)
        for h=1:length(Y(k))
            A=A+c(X(k)(h),X(k)(h+1));
            if Y(k)(h)==1 then
                B=B-q(X(k)(h),X(k)(h+1));
            end
        end
    end
    G=lambda*A+Gamma*B;
endfunction

//Une solution est-elle admissible?
function Rep=IsSolution(X,Y,q)
    B=sum(q)/2;
    for k=1:size(X)
        for h=1:length(Y(k))
            if Y(k)(h)==1 then
                B=B-q(X(k)(h),X(k)(h+1));
            end
        end
    end
    if B==0 then
        Rep=1;
    else
        Rep=0;
    end
endfunction

//Coût pour le CARP traditionnel
function C=coutcarp(X,Y,c,q)
    C=0;
    for k=1:size(X)
        for h=1:length(Y(k))
            C=C+c(X(k)(h),X(k)(h+1));
        end
    end
endfunction

//Parcours d'un hypercube de dimension n (centré en 0 et de rayon 1)
function y=PH(n)
    y=list();
    i=1;
    l=-1*ones(1,n);
    y(i)=l;
    h=1;
    while sum(l)<n
        l(h)=l(h)+1;
        if l(h)>1
            l(h)=-1;
        end
        while l(h)==-1
            h=h+1;
            l(h)=l(h)+1;
            if l(h)>1
                l(h)=-1;
            end
        end
        h=1;
        if l==zeros(1,n) then
            continue
        end
        i=i+1;
        y(i)=l;
    end
endfunction

//Grille d'indices inversée
function ind=GIinv(k,n,l)
    ind=l(1);
    for i=1:(k-1)
        ind=ind+(l(i+1)-1)*n^i;
    end
endfunction

//Stratégie de modification/réparation (obsolète)
function [MS1,MS2]=modif(a,SE,X,Y) //Entrées: Matrice d'adjacence initiale, sommets engloutis, tournée à réparer et vecteur des déblayages
    NS=size(a,1);
    for h=SE //Nouvelle matrice d'adjacence
        a(h,:)=zeros(1,NS);
        a(:,h)=zeros(NS,1);
    end
    for k=1:size(X)
        for b=2:(length(Y(k))-1)
            if sum(X(k)(b)==SE)>=1 | sum(X(k)(b+1)==SE)>=1 then
                Y(k)(b)=2;
            end
        end
        Y(k)=Y(k)(Y(k)<>2);
        for h=SE
            X(k)=X(k)(X(k)<>h);
        end
        L=length(X(k));
        L2=length(Y(k));
        for i=1:(L-1)
            if a(X(k)(i),X(k)(i+1))==0 then
                l=length(pcch2(a,c,X(k)(i),X(k)(i+1)))-2;
                for h=0:(L-i-1)
                    X(k)(L+l-h)=X(k)(L-h);
                end
                for h=0:(L2-i)
                    Y(k)(L2+l+1-h)=Y(k)(L2-h);
                end
                X(k)(i:(i+l+1))=pcch2(a,c,X(k)(i),X(k)(i+l+1))';
                Y(k)(i:(i+l))=zeros(1,l+1);
            end
        end
    end
    MS1=X;
    MS2=Y;
endfunction

//Stratégie de modification/réparation
function [MS1,MS2]=modif2(a,SE,X,Y) //Entrées: Matrice d'adjacence initiale, sommets engloutis, tournée à réparer et vecteur des déblayages
    NS=size(a,1);
    MS1=list();
    MS2=list();
    for h=SE //Nouvelle matrice d'adjacence
        a(h,:)=zeros(1,NS);
        a(:,h)=zeros(NS,1);
    end
    for k=1:size(X)
        MS1(k)=[];
        MS2(k)=[];
        AS=list();
        l=1;
        for h=1:length(Y(k))
            if Y(k)(h)==1 then
                if intersect([X(k)(h) X(k)(h+1)],SE)<>[] then
                    Y(k)(h)=0;
                else
                    AS(l)=[X(k)(h) X(k)(h+1)];
                    l=l+1;
                end
            end
        end
        MS1(k)=pcch2(a,c,1,AS(1)(1))';
        MS2(k)=[zeros(1,length(MS1(k))-1) 1];
        if size(AS)>1 then
        for h=2:size(AS)
            MS1(k)=[MS1(k) pcch2(a,c,AS(h-1)(2),AS(h)(1))'];
            MS2(k)=[MS2(k) zeros(1,length(pcch2(a,c,AS(h-1)(2),AS(h)(1)))-1) 1];
        end
        end
        MS1(k)=[MS1(k) pcch2(a,c,AS(size(AS))(2),1)'];
        MS2(k)=[MS2(k) zeros(1,length(pcch2(a,c,AS(size(AS))(2),1))-1)];
    end
endfunction

//Cout d'une solution pour Colonie3
function C=cout3(L,arc,d)
    C=0;
    i=1;
    while L(i)<>[]
        C=C+d(arc(L(i))(1),arc(L(i))(2));
        if L(i+1)<>"retour" & L(i+1)<>[] then
            C=C+d(arc(L(i))(2),arc(L(i+1))(1));
            i=i+1;
        elseif L(i+1)=="retour" & L(i+2)<>[] & L(i+2)<>"retour" then
            C=C+d(arc(L(i))(2),1)+d(1,arc(L(i+2))(1));
            i=i+2;
        elseif L(i+1)=="retour" & L(i+2)==[] then
            C=C+d(arc(L(i))(2),1);
            i=i+1;
        end
    end
endfunction
