function [theCityRoute] = genRoute(numCities, theCityRoute, cC)
    selectMethodRandomly = rand();
    if (selectMethodRandomly < 0.25)
        theCityRoute = swap(numCities, theCityRoute);
    elseif (selectMethodRandomly < 0.50)
        theCityRoute = inverse(numCities, theCityRoute);
    elseif (selectMethodRandomly < 0.75)
        theCityRoute = insert(numCities, theCityRoute);
    else
        theCityRoute = opt2(theCityRoute, cC);
    end
end

function pathsCrossed = ArePathsCrossed(startLine1, endLine1, startLine2, endLine2, cC)
    coordStartLine1 = [cC(startLine1, 2) cC(startLine1, 3)];
    coordEndLine1 = [cC(endLine1, 2) cC(endLine1, 3)];
    coordStartLine2 = [cC(startLine2, 2) cC(startLine2, 3)];
    coordEndLine2 = [cC(endLine2, 2) cC(endLine2, 3)];
    
    pathsCrossed = line_intersection([coordStartLine1(1),coordStartLine1(2),coordEndLine1(1),coordEndLine1(2)], [coordStartLine2(1),coordStartLine2(2),coordEndLine2(1),coordEndLine2(2)]);
end

function [theCityRoute] = opt2(theCityRoute, cC)
    numberOfModifications = randi(5);
    for j=1:1:numberOfModifications
        for i=2:1:size(theCityRoute')-2
            route = theCityRoute(i-1:i+2);
            if ArePathsCrossed(route(1), route(2), route(3), route(4), cC) ~= inf
                theCityRoute(i-1:i+2) = [theCityRoute(i-1) theCityRoute(i+1) theCityRoute(i) theCityRoute(i+2)];
                break;
            end
        end
    end
end

function [theCityRoute] = swap(numCities, theCityRoute)
    randIndex1 = randi(numCities);
    alreadyChosen = true;
    while alreadyChosen == true
        randIndex2 = randi(numCities);
        if randIndex2 ~= randIndex1
            alreadyChosen = false;
        end
    end
    dummy = theCityRoute(randIndex1);
    theCityRoute(randIndex1) = theCityRoute(randIndex2);
    theCityRoute(randIndex2) = dummy;
end

function [theCityRoute] = inverse(numCities, theCityRoute)
    randIndex1 = randi(numCities);
    alreadyChosen = true;
    while alreadyChosen == true
        randIndex2 = randi(numCities);
        if randIndex2 ~= randIndex1
            alreadyChosen = false;
        end
    end
    
    if randIndex1 < randIndex2
        index1 = randIndex1;
        index2 = randIndex2;
    else
        index2 = randIndex1;
        index1 = randIndex2;
    end
    
    theCityRoute(index1:index2) = flip(theCityRoute(index1:index2));
end

function [theCityRoute] = insert(numCities, theCityRoute)
    randIndex1 = randi(numCities);
    alreadyChosen = true;
    while alreadyChosen == true
        randIndex2 = randi(numCities);
        if randIndex2 ~= randIndex1
            alreadyChosen = false;
        end
    end
    valIndex1 = theCityRoute(randIndex1);
    theCityRoute(randIndex1) = [];
    theCityRoute = [theCityRoute(1:randIndex2-1) valIndex1 theCityRoute(randIndex2:end)];

end