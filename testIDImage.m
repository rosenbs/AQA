%this finds a set of files (4 images plus a plan) and runs our
%identifyImage function
clear
files = dir('C:\Users\rosenbs\Box\AQA Software\Phase 2\*.dcm');%test files location
%find the RTplan and save information
for i = 1:length(files)   
header = dicominfo([files(i).folder '\' files(i).name]);
if strcmp(header.Modality,'RTPLAN')
  pathPlan  = [files(i).folder '\' files(i).name];
  break;
end
end

results = cell(length(files)-1,3);
for i = 1:length(files)-1     
pathImage = [files(i).folder '\' files(i).name];
[imageName,differenceParameters,testResult]=identifyImage(pathImage,pathPlan);
results{i,1}=imageName;
results{i,2}=differenceParameters;
results{i,3}=testResult;
end
