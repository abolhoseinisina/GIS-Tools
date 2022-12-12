function [D] = computeEUCDistance(numCities, cC, cR)
    D=0;
    for ii=1:numCities-1
        D = D + sqrt((cC(cR(ii),2)-cC(cR(ii+1),2))^2 + (cC(cR(ii),3)-cC(cR(ii+1),3))^2);
    end
    D = D + sqrt((cC(cR(numCities),2)-cC(cR(1),2))^2 + (cC(cR(numCities),3)-cC(cR(1),3))^2);
end
