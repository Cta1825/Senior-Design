clc;clear

loadDir = ['/Users/mattn/Library/CloudStorage/OneDrive-SharedLibraries-' ...
    'UniversityofFlorida/BME 4883 Spring 2024 - Team 01 - Intubator ' ...
    'Trainers - Appendix A4 - Raw Data & Design Verification/Preprocessing' ...
    '/Good Trials/'];
saveDir = ['/Users/mattn/Library/CloudStorage/OneDrive-SharedLibraries-' ...
    'UniversityofFlorida/BME 4883 Spring 2024 - Team 01 - Intubator ' ...
    'Trainers - Appendix A4 - Raw Data & Design Verification/Processed/'];

Directory = dir(strcat(loadDir, '*.csv'));
timeStamps = readtable(strcat(loadDir, 'goodTrialTimeStamps.xlsx'));

for i = 1:length(Directory) %Steps through all files in directory

    trialName = Directory(i).name(1:end-4);
    ImuData = readtable(strcat(loadDir,trialName,'.csv'));
    
    rowInd_timeStamp = find(strcmp(timeStamps.TesterID, trialName));
    startTime = table2array(timeStamps(rowInd_timeStamp,2));
    endTime = table2array(timeStamps(rowInd_timeStamp,3));
    
    startInd = find(round(seconds(table2array(ImuData(:,1)))) == startTime, 1,'first');
    endInd = find(round(seconds(table2array(ImuData(:,1)))) == endTime, 1,'first');
    
    accelData = table2array(ImuData(startInd:endInd, 4:6)); %[Accel_X, Accel_Y, Accel_Z]
    gyroData = table2array(ImuData(startInd:endInd, 7:9)); %[AngleVelocity_X, AngleVelocity_Y, AngleVelocity_Z]
    magData = table2array(ImuData(startInd:endInd, 10:12)); %[MagneticField_X, MagneticField_Y, MagneticField_Z]
    quaternionData = table2array(ImuData(startInd:endInd, 13:16)); %[Quaternion_0, Quaternion_1, Quaternion_2, Quaternion_3]
    timeData = seconds(table2array(ImuData(startInd:endInd,1))); %in seconds
    
    FUSE = ahrsfilter; 
    [orientation,angularVelocity] = FUSE(accelData,gyroData,magData);
    
    orientation = compact(orientation);
    w = orientation(:,1);
    x = orientation(:,2);
    y = orientation(:,3);
    z = orientation(:,4);
    
    p = [0, 0, 0];
    position = p;
    for i = 2:length(timeData)
        n = timeData(i)-timeData(i-1);
        v = [2*x(i)*z(i) - 2*y(i)*w(i),2*y(i)*z(i) + 2*x(i)*w(i),1 - 2*x(i)^2 - 2*y(i)^2];
        p = p + n * v;
        position = [position; p];
    end
    
    labels = {'x-pos', 'y-pos', 'z-pos', 'w-orien', 'x-orien', 'y-orien', 'z-orien', 'x-ang', 'y-ang', 'z-ang'};
    out = [labels; num2cell(position), num2cell(orientation), num2cell(angularVelocity)];
    writecell(out,strcat(saveDir,trialName, '_ahrs.csv'))
end

