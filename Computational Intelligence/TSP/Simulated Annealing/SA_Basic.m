clc; clear; close all;
%t=cputime;
tic;
cC = load('dj44.txt');
numCities = size(cC,1);
x=cC(1:numCities, 2);
y=cC(1:numCities, 3);
x(numCities+1)=cC(1,2);
y(numCities+1)=cC(1,3);
figure
hold on
plot(x',y','.k','MarkerSize',14)
labels = cellstr( num2str([1:numCities]') );  %' # labels correspond to their order
text(x(1:numCities)', y(1:numCities)', labels, 'VerticalAlignment','bottom', ...
                             'HorizontalAlignment','center');
ylabel('Y Coordinate', 'fontsize', 18, 'fontname', 'Arial');
xlabel('X Coordinate', 'fontsize', 18, 'fontname', 'Arial');
title('City Coordinates', 'fontsize', 20, 'fontname', 'Arial');

numCoolingLoops = 200;
numEquilbriumLoops = 10000;
pStart = 0.1;        % Probability of accepting worse solution at the start
pEnd = 0.00001;        % Probability of accepting worse solution at the end
tStart = -1.0/log(pStart); % Initial temperature
tEnd = -1.0/log(pEnd);     % Final temperature
frac = (tEnd/tStart)^(1.0/(numCoolingLoops-1.0));% Fractional reduction per cycle
cityRoute_i = randperm(numCities); % Get initial route
cityRoute_b = cityRoute_i;
cityRoute_j = cityRoute_i;
cityRoute_o = cityRoute_i;
% Initial distances
D_j = computeEUCDistance(numCities, cC, cityRoute_i);
D_o = D_j; D_b = D_j; D(1) = D_j;
numAcceptedSolutions = 1.0;
tCurrent = tStart;         % Current temperature = initial temperature
DeltaE_avg = 0.0;   % DeltaE Average
for i=1:numCoolingLoops
    numChanges = 0;
    disp(['Cycle: ', num2str(i), ' starting temperature: ', num2str(tCurrent)])
    for j=1:numEquilbriumLoops
        cityRoute_j = perturbRoute(numCities, cityRoute_b, cC);
        D_j = computeEUCDistance(numCities, cC, cityRoute_j);
        DeltaE = abs(D_j-D_b);
        if (D_j > D_b) % objective function is worse
            if (i==1 && j==1) 
                DeltaE_avg = DeltaE; 
            end
            
            p = exp(-DeltaE/(DeltaE_avg * tCurrent));
            if (p > rand())
                accept = true;
                numChanges = numChanges + 1;
            else
                accept = false; 
            end
        else
            accept = true; % objective function is better
        end
        
        if (accept==true)
            cityRoute_b = cityRoute_j;
            D_b = D_j;
            numAcceptedSolutions = numAcceptedSolutions + 1.0;
            DeltaE_avg = (DeltaE_avg * (numAcceptedSolutions-1.0) + ... 
                                            DeltaE) / numAcceptedSolutions;
        end
    end
    
    disp([' Global: ', num2str(D_o), ' Best: ', num2str(D_b), ' Changes: ', num2str(numChanges)])
    
    frac = 1 / (1+0.00001*i^2);
    tCurrent = frac * tCurrent; % Lower the temperature for next cycle
    cityRoute_o = cityRoute_b;  % Update optimal route at each cycle
    D(i+1) = D_b; %record the route distance for each temperature setting
    D_o = D_b; % Update optimal distance
end
% print solution
disp(['Best solution: ',num2str(cityRoute_o)])
% Compute distance
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
axis equal
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
                             'HorizontalAlignment','center')

%plot(x',y','MarkerSize',24)
ylabel('Y Coordinate', 'fontsize', 18, 'fontname', 'Arial');
xlabel('X Coordinate', 'fontsize', 18, 'fontname', 'Arial');
title('Best City Route', 'fontsize', 20, 'fontname', 'Arial');
%fprintf('Total CPU time: %.2f s\n',cputime-t);
endTime = toc
fprintf('Total time: %d minutes and %.1f seconds\n', floor(endTime/60), rem(endTime,60));
%fprintf('Total Clock time: %.2f s\n',toc);