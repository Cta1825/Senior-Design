%Step 1: Import .csv
clc;clear; close all
fileLoc = ['/Users/mattn/Library/CloudStorage/OneDrive-SharedLibraries-UniversityofFlorida/BME 4883 Spring 2024 - Team 01 - Intubator Trainers - Raw Data/Intubation Trials/Expert Data Feb 22nd'];
trialName = ['017-2-1'];

addpath(fileLoc)
ImuData = readtable(strcat(trialName,'.csv'));

%Step 2: read data from .csv 
accelData = table2array(ImuData(:, 4:6)); %[Accel_X, Accel_Y, Accel_Z]
gyroData = table2array(ImuData(:, 7:9)); %[AngleVelocity_X, AngleVelocity_Y, AngleVelocity_Z]
magData = table2array(ImuData(:, 10:12)); %[MagneticField_X, MagneticField_Y, MagneticField_Z]
quaternionData = table2array(ImuData(:, 13:16)); %[Quaternion_0, Quaternion_1, Quaternion_2, Quaternion_3]
timeData = seconds(table2array(ImuData(:,1))); %in seconds

%Step 3: AHRS Filter
FUSE = ahrsfilter; 
[orientation,angularVelocity] = FUSE(accelData,gyroData,magData);

orientation = compact(orientation);
w = orientation(:,1);
x = orientation(:,2);
y = orientation(:,3);
z = orientation(:,4);


%Step 4: Display z-graph
p = [0, 0, 0];
position = p;
for i = 2:length(timeData)
    n = timeData(i)-timeData(i-1);
    v = [2*x(i)*z(i) - 2*y(i)*x(i),2*y(i)*z(i) + 2*x(i)*w(i),1 - 2*x(i)^2 - 2*y(i)^2];
    p = p + n * v;
    position = [position; p];
end

fig1 = figure;
hold on;
plot(timeData, position(:,3)); title('Z-graph') 

%Step 5: Find starting time indicie
[~, startInd] = max(position(:,3));
timeStart = timeData(startInd - floor(.1*length(timeData)));
plot(timeStart, position(startInd- floor(.1*length(timeData)),3), 'rx')

%Step 6: Find end point time
disp("Mark area to zoom in on")
zoomRegion = drawpoint()
pointInd = zoomRegion.Position;

xlim([pointInd(1) * .99995, pointInd(1) * 1.00005])

% Enable data cursor mode
datacursormode on
dcm_obj = datacursormode(fig1);
disp('Click line to display a data tip, then press "Return"')
pause 
% Export cursor to workspace
timeEnd = getCursorInfo(dcm_obj);


fig2 = figure; hold on;
plot(timeData, position(:,3)); title('Z-graph')
plot(timeStart, position(startInd- floor(.1*length(timeData)),3), 'rx')
plot(timeEnd.Position(1), timeEnd.Position(2), 'rx')

exportData = {trialName, timeStart, timeEnd.Position(1)}


% function output_txt = myupdatefcn(~,event_obj)
%   % ~            Currently not used (empty)
%   % event_obj    Object containing event data structure
%   % output_txt   Data cursor text
%   pos = get(event_obj, 'Position');
%   output_txt = {['x: ' num2str(pos(1))], ['y: ' num2str(pos(2))]};
% end

