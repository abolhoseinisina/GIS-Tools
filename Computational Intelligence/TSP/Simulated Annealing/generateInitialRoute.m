function [theCityRoute] = generateInitialRoute(numCities, cC)
    distArray = zeros(numCities);
    for j=1:1:numCities
        for i=1:1:numCities
            distArray(i, j) = computeDistance(i,j,cC);
        end 
    end
    
    initialRoute = zeros(numCities, 1);
    initialRoute(1) = randi(numCities);
    selectedCities = zeros(numCities, 1);
    selectedCities(initialRoute(1)) = 1;
    for i=2:1:numCities
        dists = distArray(initialRoute(i-1),:);
        while 1
            [~, minInd] = min(dists);
            if selectedCities(minInd) ~= 1
                initialRoute(i) = minInd;
                selectedCities(minInd) = 1;
                break;
            else
                dists(minInd) = 10e10;
            end
        end
    end
    theCityRoute = initialRoute';
end

function dist = computeDistance(index1, index2, cC)
    coord1 = [cC(index1,2) cC(index1,3)];
    coord2 = [cC(index2,2) cC(index2,3)];
    dist = ((coord1(1)-coord2(1))^2+(coord1(2)-coord2(2))^2)^0.5;
end