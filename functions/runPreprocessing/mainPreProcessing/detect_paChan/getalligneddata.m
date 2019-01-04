function [alligned,allignedIndex,K] = getalligneddata(data,index,range,artifact)
% [alligned] = getaligneddata(data,index,range)
% index Tx1 = The sample index of the trigger
% range 1x2 = range(1) samples before and range(2) samples after the
% trigger index
% data : Multichannel data first dimension is the samples and the second
% channels
% alligned data: last dimension is always T and first dimesion is depend on
% the range, other dimenstions are same as input data
% Written by Su Liu
% Modified by : christonik@gmail.com
%%
if nargin<4
    artifact=[0 0];
end

index = index(:);
T = length(index);
K = zeros(T,1);
range = round(range);
try
   alligned = zeros(diff(range)+1,size(data,2),T);
catch ('Out of memory. Type HELP MEMORY for your options.');
    disp('Memory limit reached.')
end

disp([newline '------ Alligning the data ------ '])
allignedIndex = zeros(T,diff(range)+1);



for k = 1:T
    allignedIndex(k,:)=index(k)+(range(1):range(2));
    if ~any(allignedIndex(k,:)<=0) && ~any(allignedIndex(k,:)>length(data))
        if ~any((allignedIndex(k,1)<artifact(:,2) & allignedIndex(k,1)>artifact(:,1)) | (allignedIndex(k,end)<artifact(:,2) & allignedIndex(k,end)>artifact(:,1)))               
            alligned(:,:,k) = data(allignedIndex(k,:),:);
            K(k)=1;
        end
    else
        K(k)=0;
        continue;
    end
end

% Keeping only artifact free trials
alligned=alligned(:,:,logical(K));
allignedIndex=allignedIndex(logical(K),:);
%allignedIndex(del,:)=[];
%alligned(:,:,del)=[];
disp('Allignment completed')
