//Stratégie de modification/réparation
function [MS]=modif(a,SE,Ch) //Entrées: Matrice d'adjacence initiale, sommets submergés et Chemin à réparer
    NS=size(a,1);
    for h=SE //Nouvelle matrice d'adjacence
        a(h,:)=zeros(1,NS);
        a(:,h)=zeros(NS,1);
    end
    for k=1:size(Ch)
        for h=SE
            Ch(k)=Ch(k)(Ch(k)<>h);
        end
        L=length(Ch(k));
        for i=1:(length(Ch(k))-1)
            if a(Ch(k)(i),Ch(k)(i+1))==0 then
                l=length(pcch(a,c,Ch(k)(i),Ch(k)(i+1)))-2;
                for h=0:(length(Ch(k))-i-1)
                    Ch(k)(L+l-h)=Ch(k)(L-h);
                end
                Ch(k)(i:(i+l+1))=pcch(a,c,Ch(k)(i),Ch(k)(i+l+1))';
            end
        end
    end
    MS=Ch;
endfunction
