//Sous-fonctions

//Dijkstra
function [d]=Dijkstra(a,c)
    P=[];
    l=size(a,1);
    c(a==0)=%inf;
    S=1:l;
    d0=%inf*ones(1,l);
    d0(1)=0;
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

//Prédécesseur dans le plus court chemin
function p=pred(a,c,h)
    d=Dijkstra(a,c);
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
function [CH]=pcch(a,c,h)
    CH(1)=h;
    i=1;
    while CH(i)<>1
        i=i+1;
        CH(i)=pred(a,c,CH(i-1));
    end
    CH(i)=1;
endfunction

//Coût d'une solution
function F=cout(x,y,c,q,N)
    lambda=1;
    gamma=3; //Paramètres d'importances relatives des distances et des déchets
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
