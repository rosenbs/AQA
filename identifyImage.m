%We are going to identify the image (given path to the image and path to
%the plan) and determine whether it was correctly delivered (within a
%pre-difined threshold).
function [imageName,differenceParameters,testResult] = identifyImage(pathImage,pathPlan)
planHeader = dicominfo(pathPlan); %get plan header
imHeader = dicominfo(pathImage); % get image header
referencedUID = imHeader.ReferencedRTPlanSequence.Item_1.ReferencedSOPInstanceUID; %get referenced plan UID
planUID = planHeader.SOPInstanceUID; %get plan UID
if strcmp(referencedUID,planUID)% only continue if the UIDs are the same   
deliveredBeamNumber = imHeader.ReferencedBeamNumber; %get delivered beam number
BeamSequence = planHeader.BeamSequence; %get the planned beam sequence
fieldsBeamSequence = fields(BeamSequence); %list the beams
for j = 1:length(fields(BeamSequence))%look for a match in beam number
plannedItem = BeamSequence.(fieldsBeamSequence{j}); 
if plannedItem.BeamNumber == deliveredBeamNumber % if the match is found, just keep this beam sequence
    break
end
end
planBeamName = plannedItem.BeamName; %get planned beam name
if strcmp(plannedItem.ControlPointSequence.Item_1.GantryRotationDirection,'NONE')  % determine if this is a rotating ganty
planG = plannedItem.ControlPointSequence.Item_1.GantryAngle;%if not, then the first item is the gantry angle
else
fieldsControlPoint = fields(plannedItem.ControlPointSequence);%if it is rotating, we need the last control point gantry angle
lastControlPointItem = fieldsControlPoint{end};
planG = plannedItem.ControlPointSequence.(lastControlPointItem).GantryAngle;
end
planC = plannedItem.ControlPointSequence.Item_1.BeamLimitingDeviceAngle;%get planned collimator
planE = plannedItem.ControlPointSequence.Item_1.NominalBeamEnergy;  % get planned energy
planFFF = nnz(regexp(planBeamName,'\dF'))>0; %determine if flattening filter free (F) is in plan name after a number
planX1 =plannedItem.ControlPointSequence.Item_1.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions(1); %get planned x1
planX2 =plannedItem.ControlPointSequence.Item_1.BeamLimitingDevicePositionSequence.Item_1.LeafJawPositions(2); %get planned x2
planY1 =plannedItem.ControlPointSequence.Item_1.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions(1); %get planned y1
planY2 =plannedItem.ControlPointSequence.Item_1.BeamLimitingDevicePositionSequence.Item_2.LeafJawPositions(2); %get planned y2
planParameters=[planG planC planX1 planX2 planY1 planY2 planE planFFF];%save planned parameters
deliverG = imHeader.GantryAngle;%get the image delivery gantry angle
if abs(deliverG-360)<5
deliverG=deliverG-360; %need to map back onto the difference from 0 when gantry angle is near 360
end
deliverC = imHeader.BeamLimitingDeviceAngle; %get the image delivery collimator angle
if abs(deliverC-360)<5
deliverC=deliverC-360; %need to map back onto the difference from 0 when collimator angle is near 360
end
ex_sequence = imHeader.ExposureSequence.Item_1;
deliverE = ex_sequence.KVP/1000; % get delivered energy
deliverFFF=contains(imHeader.RTImageDescription,'FFF'); % get delivered FFF status
deliverX1 = ex_sequence.BeamLimitingDeviceSequence.Item_1.LeafJawPositions(1); % get delivered x1
deliverX2 = ex_sequence.BeamLimitingDeviceSequence.Item_1.LeafJawPositions(2); % get delivered x2
deliverY1 = ex_sequence.BeamLimitingDeviceSequence.Item_2.LeafJawPositions(1); % get delivered x3
deliverY2 = ex_sequence.BeamLimitingDeviceSequence.Item_2.LeafJawPositions(2); % get delivered x4
imageParameters=[deliverG deliverC deliverX1 deliverX2 deliverY1 deliverY2 deliverE deliverFFF]; %save delivered parameters
imageName = planBeamName; %assign the image name to the planned beam name
differenceParameters = planParameters - imageParameters;%calculate difference 
if nnz(abs(differenceParameters)>=1) %this is a hard-coded criterion. If any of the paramters are exceed by 1 or more then we will report a fail
    testResult = 0;
else
    testResult = 1;
end
else % If UID does not match, then we have a problem and no further testing
    differenceParameters = zeros(1,8);
    testResult = 0;
    imageName = 'ERROR';
end
end

