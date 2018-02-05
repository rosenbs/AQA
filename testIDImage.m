clear
files = dir('C:\Users\rosenbs\Box\AQA Software\JM Jan 2018 images\$JM_AQA_phase2_v000\*.dcm');%test files location
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
[imageName,differenceParameters,testResult]=testIDimage(pathImage,pathPlan);
results{i,1}=imageName;
results{i,2}=differenceParameters;
results{i,3}=testResult;
end
