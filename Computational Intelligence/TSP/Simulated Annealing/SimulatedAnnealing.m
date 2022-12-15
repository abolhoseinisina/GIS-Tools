clc; clear; close all;
%t=cputime;
tic;

cC = load('400.txt');

numCities = size(cC,1);
x=cC(1:numCities, 2);
y=cC(1:numCities, 3);
x(numCities+1)=cC(1,2);
y(numCities+1)=cC(1,3);

figure
plot(x',y','.k','MarkerSize',14)
labels = cellstr( num2str([1:numCities]') );  %' # labels correspond to their order
text(x(1:numCities)', y(1:numCities)', labels, 'VerticalAlignment','bottom', ...
    'HorizontalAlignment','center', 'fontsize', 8);
ylabel('Y Coordinate', 'fontsize', 18, 'fontname', 'Arial');
xlabel('X Coordinate', 'fontsize', 18, 'fontname', 'Arial');
title('City Coordinates', 'fontsize', 20, 'fontname', 'Arial');

numCoolingLoops = 500000;
numEquilbriumLoops = 1000;
pStart = 0.05;        % Probability of accepting worse solution at the start
pEnd = 0.00001;        % Probability of accepting worse solution at the end
tStart = -1.0/log(pStart); % Initial temperature
tEnd = -1.0/log(pEnd);     % Final temperature
frac = (tEnd/tStart)^(1.0/(numCoolingLoops-1.0));% Fractional reduction per cycle

cityRoute_i = generateInitialRoute(numCities, cC); % Get initial route
drawRoute(numCities, cityRoute_i, cC);

cityRoute_b = cityRoute_i;
cityRoute_j = cityRoute_i;
cityRoute_o = cityRoute_i;
% Initial distances
D_j = computeEUCDistance(numCities, cC, cityRoute_i);
D_o = D_j; D_b = D_j; D(1) = D_j;
numAcceptedSolutions = 1.0;
tCurrent = tStart;         % Current temperature = initial temperature
DeltaE_avg = 0.0;   % DeltaE Average

DeltaO = zeros(numCoolingLoops,0);

maxReHeating = 2;
reHeat = 0;
reHeatLoop = 0;

for i=1:numCoolingLoops
    disp(['Cycle: ',num2str(i),' starting temperature: ',num2str(tCurrent)])
    for j=1:numEquilbriumLoops
        cityRoute_j = perturbRoute(numCities, cityRoute_b, cC);
        D_j = computeEUCDistance(numCities, cC, cityRoute_j);
        DeltaE = abs(D_j-D_b);
        if (D_j > D_b) % objective function is worse
            if (i==1 && j==1) DeltaE_avg = DeltaE; end
            p = exp(-DeltaE/(DeltaE_avg * tCurrent));
            if (p > rand()) accept = true; else accept = false; end
        else accept = true; % objective function is better
        end
        if (accept==true)
            cityRoute_b = cityRoute_j;
            D_b = D_j;
            numAcceptedSolutions = numAcceptedSolutions + 1.0;
            DeltaE_avg = (DeltaE_avg * (numAcceptedSolutions-1.0) + ...
                DeltaE) / numAcceptedSolutions;
        end
    end

    DeltaO(i) = D_o - D_b;
    if (DeltaO(i) <= 0) frac = (tEnd/tStart)^(1.0/(numCoolingLoops-1.0)); else frac = 1 / (1+0.00001*DeltaO(i)*i); end

    tCurrent = frac * tCurrent; % Lower the temperature for next cycle
    cityRoute_o = cityRoute_b;  % Update optimal route at each cycle
    D(i+1) = D_b; %record the route distance for each temperature setting
    D_o = D_b; % Update optimal distance

    if(i >= reHeatLoop + 50 && sum(DeltaO(i-49:i)) == 0)
        if reHeat < maxReHeating
            reHeatLoop = i;
            reHeat = reHeat + 1;
            tCurrent = 0.33;
        end
    end

    if(i >= reHeatLoop + 100 && sum(DeltaO(i-99:i)) == 0)
        break;
    end
end
% print solution
disp(['Best solution: ',num2str(cityRoute_o)])

D_b=0; cR = cityRoute_o;
for i=1:numCities-1
    D_b = D_b + sqrt((cC(cR(i),2)-cC(cR(i+1),2))^2 + (cC(cR(i),3)-cC(cR(i+1),3))^2);
end
D_b = D_b + sqrt((cC(cR(numCities),2)-cC(cR(1),2))^2 + (cC(cR(numCities),3)-cC(cR(1),3))^2);
disp(['Best algo   objective: ',num2str(D_b)])
disp(['Best global objective: ',num2str(D_o)])

%Save city route to file
fileID = fopen('BestCR.txt','w');
fprintf(fileID,'%6.2f\n',cR);
fclose(fileID);

hold off
figure
set(0, 'defaultaxesfontname', 'Arial');
set(0, 'defaultaxesfontsize', 14);
plot(D,'r.-')
ylabel('Distance', 'fontsize', 14, 'fontname', 'Arial');
xlabel('Route Number', 'fontsize', 14, 'fontname', 'Arial');
title('Distance vs Route Number', 'fontsize', 16, 'fontname', 'Arial');


for i=1:numCities
    x(i)=cC(cR(i),2);
    y(i)=cC(cR(i),3);
end
x(numCities+1)=cC(cR(1),2);
y(numCities+1)=cC(cR(1),3);
figure
hold on
plot(x',y',...
    'r',...
    'LineWidth',1,...
    'MarkerSize',8,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[1.0,1.0,1.0])
plot(x(1),y(1),...
    'r',...
    'LineWidth',1,...
    'MarkerSize',8,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[1.0,0.0,0.0])
labels = cellstr( num2str([1:numCities]') );  %' # labels correspond to their order
text(x(1:numCities)', y(1:numCities)', labels, 'VerticalAlignment','middle', ...
    'HorizontalAlignment','center', 'fontsize', 6)

ylabel('Y Coordinate', 'fontsize', 18, 'fontname', 'Arial');
xlabel('X Coordinate', 'fontsize', 18, 'fontname', 'Arial');
title('Best City Route', 'fontsize', 20, 'fontname', 'Arial');
endTime = toc;
fprintf('Total time: %d minutes and %.1f seconds\n', floor(endTime/60), rem(endTime,60));
fprintf('time, %.2f solu %.4f \n', toc, D_b);

function drawRoute(numCities, cR, cC)
    for i=1:numCities
        a(i)=cC(cR(i),2);
        b(i)=cC(cR(i),3);
    end
    a(numCities+1)=cC(cR(1),2);
    b(numCities+1)=cC(cR(1),3);
    
    figure;
    hold on;
    plot(a',b',...
        'r',...
        'LineWidth',1,...
        'MarkerSize',8,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor',[1.0,1.0,1.0])
    plot(a(3),b(1),...
        'r',...
        'LineWidth',1,...
        'MarkerSize',8,...
        'MarkerEdgeColor','b',...
        'MarkerFaceColor',[1.0,0.0,0.0])

    ylabel('Y Coordinate', 'fontsize', 18, 'fontname', 'Arial');
    xlabel('X Coordinate', 'fontsize', 18, 'fontname', 'Arial');
    title('Initial Route', 'fontsize', 20, 'fontname', 'Arial');
end

