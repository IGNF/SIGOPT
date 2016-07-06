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

//Plus court chemin de h vers 1
function [CH]=pcch(a,c,h,d)
    CH(1)=h;
    i=1;
    while CH(i)<>1
        i=i+1;
        CH(i)=pred(a,c,CH(i-1),d);
    end
    CH(i)=1;
endfunction

//Plus court chemin de h vers ref
function [CH]=pcch2(a,c,h,ref)
    CH(1)=h;
    i=1;
    while CH(i)<>ref
        i=i+1;
        CH(i)=pred2(a,c,CH(i-1),ref);
    end
    CH(i)=ref;
endfunction

//Coût d'une solution
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
    gamma=1;
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
    G=lambda*A+gamma*B;
endfunction

//Coût pour le CARP traditionnel
function C=coutcarp(x,y,c,q,N)
    ad=a.*bool2s(q>0);
    Y=sum((1-sum(y,3)).*ad);
    if Y>0 then
        Y=%inf;
    end
    x=sum(x,3);
    C=sum(x.*c)+Y;
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
