%%%%%测试半监督学习的效果
%%%%根据需求使用数据集和算法
%%%%rate7是最后的结果
%% 
clear;

addpath('Datasets/');
addpath('Functions/');
addpath('LRR');
data_num = 8;
run_time = 10;
dataset_name = {'ORL_32x32','Umist','YaleB_3232','COIL20','mnist_all','CCC40','USPSfu','PD100'};
load(strcat(dataset_name {data_num},'.mat'))
if data_num == 1
    interval = 40;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 2
    fea=X';
    interval = 20;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 3
    interval = 20;%这个是去样本数的间隔
    ttime = 1;
elseif data_num == 4
    interval = 20;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 5
    interval = 10;%这个是去样本数的间隔
    num = 200;
    fea = double([train0(1:num,:);train1(1:num,:);train2(1:num,:);train3(1:num,:);train4(1:num,:);train5(1:num,:);train6(1:num,:);train7(1:num,:);train8(1:num,:);train9(1:num,:)]);
    gnd = double([ones(num,1);2*ones(num,1);3*ones(num,1);4*ones(num,1);5*ones(num,1);6*ones(num,1);7*ones(num,1);8*ones(num,1);9*ones(num,1);10*ones(num,1)]);
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 6
    interval = 50;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 7
    dnum = 20;
    num = dnum;
    fea = [data0(:,1:dnum)';data1(:,1:dnum)';data2(:,1:dnum)';data3(:,1:dnum)';data4(:,1:dnum)';data5(:,1:dnum)';data6(:,1:dnum)';data7(:,1:dnum)';data8(:,1:dnum)';data9(:,1:dnum)'];
    fea = double(fea);
    gnd = double([ones(num,1);2*ones(num,1);3*ones(num,1);4*ones(num,1);5*ones(num,1);6*ones(num,1);7*ones(num,1);8*ones(num,1);9*ones(num,1);10*ones(num,1)]);
    interval = 2;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 8
    interval = 10;
    ttime = floor(length(unique(gnd))/interval);
end
folder_now = pwd;
addpath([folder_now, '\funs']);
samp_num = size(fea,1);
nnClass = length(unique(gnd));  % The number of classes;
num_Class=[];
for i=1:nnClass
  num_Class=[num_Class length(find(gnd==i))]; %The number of samples of each class
end
num = 7;
fea =  NormalizeFea(fea);
test = fea;
runtimes = 10;
gama_1 = 50;
gama_2 = 11;
minU0 = 1e-12;
maxU0 = 1e5;
label_r = cell(num,runtimes);
gnd_r = cell(num,runtimes);
rate = zeros(1,runtimes); 
   [A OBJ] = LRSA(test', gama_1, gama_2);%LRRADP
%     [A OBJ] = solve_lrr(test', 1);%LRR
%     [A OBJ] =  LRRHWAP(test', 50, 11,5,99);
    A = NormalizeFea(A); 
    A = A + 0.0000001*ones(size(A));
    AG = A;
    %save('AG','AG');
    %save('OBJ','OBJ');
    W = A;
    D = diag(sum(A));
for time = 1:7
    sele = time;
    rate = zeros(1,runtimes);
    for r=1:runtimes
%---------------------------------------------------------------   
        Y = zeros(samp_num, nnClass);
        cLab = zeros(samp_num, nnClass);
        FF = zeros(samp_num, nnClass);
        TestF = ones(samp_num, nnClass);
        U0 = zeros(samp_num, samp_num);
        Umin = minU0*ones(samp_num, samp_num);
        for  j=1:nnClass
            idx=find(gnd==j);
            cLab(idx, j) = 1;
            randIdx=randperm(num_Class(j)); %randIdx create m random number, m is the size of idx.
            %randIdx = 1:sele;
            Y(idx(randIdx(1:sele)),j) = 1;
            TestF(idx(randIdx(1:sele)),:) = 0;      
            for s = 1:sele
                U0(idx(randIdx(s)),idx(randIdx(s))) = maxU0;
            end                
        end
        F = (D+U0-W+Umin)\U0*Y;
        [maxF, idF] = max(F,[],2);
        for j = 1:samp_num
            FF(j,idF(j)) = 1;
        end
        recogNum = sum(sum((cLab.*FF).*TestF));
        testNum = samp_num-sele*nnClass;
        ratio = double(recogNum)/testNum;
        rate(r) = ratio;
          ll = FF.*TestF;
        ll = (1:nnClass)*ll';
        ll = ll(find(ll>0));
        gndd = cLab.*TestF;
        gndd = (1:nnClass)*gndd';
        gndd = gndd(find(gndd>0));
        label_r{time,r} = ll;
        gnd_r{time,r} = gndd;
        testNum = samp_num-sele*nnClass;
        ratio = double(recogNum)/testNum;
        rate(r) = ratio;
        [aARI(time,r),aAMI(time,r),aNMI(time,r),aACC(time,r)] = evaluate(ll,nnClass,gndd,nnClass);
        aAUC(time,r) = AUC(gndd,ll);
        [aTPR(time,r),aFPR(time,r),aPrecision(time,r),aRecall(time,r),aF1(time,r)] = performanceIndexs(gndd,ll);
    end
    %max(rate)
    rate7(time) = mean(rate);
%     std(rate);
 amARI = mean(aARI,2);
    amAMI = mean(aAMI,2);
    amNMI = mean(aNMI,2);
    amACC = mean(aACC,2);
    amAUC = mean(aAUC,2);
    amTPR = mean(aTPR,2);
    amFPR = mean(aTPR,2);
    amPrecision = mean(aPrecision,2);
    amRecall = mean(aRecall,2);
    amF1 = mean(aF1,2);
    aaresult = [amARI,amAMI,amNMI,amACC,amAUC,amTPR,amFPR,amPrecision,amRecall,amF1];
end
save(strcat('Results/newrevise/',strcat('ss',dataset_name{data_num},'lrradp')))
%% ---------------------------------------------------------------
clear;
addpath('Datasets/');
addpath('Functions/');
addpath('LRR');
data_num = 4;
run_time = 10;
dataset_name = {'ORL_32x32','Umist','YaleB_3232','COIL20','mnist_all','CCC40','USPSfu','PD200'};
load(strcat(dataset_name {data_num},'.mat'))
if data_num == 1
    interval = 40;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 2
    fea=X';
    interval = 20;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 3
    interval = 20;%这个是去样本数的间隔
    ttime = 1;
elseif data_num == 4
    interval = 20;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 5
    interval = 10;%这个是去样本数的间隔
    num = 200;
    fea = double([train0(1:num,:);train1(1:num,:);train2(1:num,:);train3(1:num,:);train4(1:num,:);train5(1:num,:);train6(1:num,:);train7(1:num,:);train8(1:num,:);train9(1:num,:)]);
    gnd = double([ones(num,1);2*ones(num,1);3*ones(num,1);4*ones(num,1);5*ones(num,1);6*ones(num,1);7*ones(num,1);8*ones(num,1);9*ones(num,1);10*ones(num,1)]);
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 6
    interval = 50;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 7
    dnum = 20;
    num = dnum;
    fea = [data0(:,1:dnum)';data1(:,1:dnum)';data2(:,1:dnum)';data3(:,1:dnum)';data4(:,1:dnum)';data5(:,1:dnum)';data6(:,1:dnum)';data7(:,1:dnum)';data8(:,1:dnum)';data9(:,1:dnum)'];
    fea = double(fea);
    gnd = double([ones(num,1);2*ones(num,1);3*ones(num,1);4*ones(num,1);5*ones(num,1);6*ones(num,1);7*ones(num,1);8*ones(num,1);9*ones(num,1);10*ones(num,1)]);
    interval = 2;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 8
    interval = 10;
    ttime = floor(length(unique(gnd))/interval);
end
folder_now = pwd;
addpath([folder_now, '\funs']);
samp_num = size(fea,1);
nnClass = length(unique(gnd));  % The number of classes;
num_Class=[];
for i=1:nnClass
  num_Class=[num_Class length(find(gnd==i))]; %The number of samples of each class
end
num = 7;
fea =  NormalizeFea(fea);
test = fea;
runtimes = 10;
gama_1 = 50;
gama_2 = 11;
minU0 = 1e-12;
maxU0 = 1e5;
label_r = cell(num,runtimes);
gnd_r = cell(num,runtimes);
rate = zeros(1,runtimes); 
   [A OBJ] = LRSA(test', gama_1, gama_2);%LRRADP
%     [A OBJ] = solve_lrr(test', 1);%LRR
%     [A OBJ] =  LRRHWAP(test', 50, 11,5,99);
    A = NormalizeFea(A); 
    A = A + 0.0000001*ones(size(A));
    AG = A;
    %save('AG','AG');
    %save('OBJ','OBJ');
    W = A;
    D = diag(sum(A));
for time = 1:7
    sele = time;
    rate = zeros(1,runtimes);
    for r=1:runtimes
%---------------------------------------------------------------   
        Y = zeros(samp_num, nnClass);
        cLab = zeros(samp_num, nnClass);
        FF = zeros(samp_num, nnClass);
        TestF = ones(samp_num, nnClass);
        U0 = zeros(samp_num, samp_num);
        Umin = minU0*ones(samp_num, samp_num);
        for  j=1:nnClass
            idx=find(gnd==j);
            cLab(idx, j) = 1;
            randIdx=randperm(num_Class(j)); %randIdx create m random number, m is the size of idx.
            %randIdx = 1:sele;
            Y(idx(randIdx(1:sele)),j) = 1;
            TestF(idx(randIdx(1:sele)),:) = 0;      
            for s = 1:sele
                U0(idx(randIdx(s)),idx(randIdx(s))) = maxU0;
            end                
        end
        F = (D+U0-W+Umin)\U0*Y;
        [maxF, idF] = max(F,[],2);
        for j = 1:samp_num
            FF(j,idF(j)) = 1;
        end
        recogNum = sum(sum((cLab.*FF).*TestF));
        testNum = samp_num-sele*nnClass;
        ratio = double(recogNum)/testNum;
        rate(r) = ratio;
          ll = FF.*TestF;
        ll = (1:nnClass)*ll';
        ll = ll(find(ll>0));
        gndd = cLab.*TestF;
        gndd = (1:nnClass)*gndd';
        gndd = gndd(find(gndd>0));
        label_r{time,r} = ll;
        gnd_r{time,r} = gndd;
        testNum = samp_num-sele*nnClass;
        ratio = double(recogNum)/testNum;
        rate(r) = ratio;
        [aARI(time,r),aAMI(time,r),aNMI(time,r),aACC(time,r)] = evaluate(ll,nnClass,gndd,nnClass);
        aAUC(time,r) = AUC(gndd,ll);
        [aTPR(time,r),aFPR(time,r),aPrecision(time,r),aRecall(time,r),aF1(time,r)] = performanceIndexs(gndd,ll);
    end
    %max(rate)
    rate7(time) = mean(rate);
%     std(rate);
 amARI = mean(aARI,2);
    amAMI = mean(aAMI,2);
    amNMI = mean(aNMI,2);
    amACC = mean(aACC,2);
    amAUC = mean(aAUC,2);
    amTPR = mean(aTPR,2);
    amFPR = mean(aTPR,2);
    amPrecision = mean(aPrecision,2);
    amRecall = mean(aRecall,2);
    amF1 = mean(aF1,2);
    aaresult = [amARI,amAMI,amNMI,amACC,amAUC,amTPR,amFPR,amPrecision,amRecall,amF1];
end
save(strcat('Results/newrevise/',strcat('ss',dataset_name{data_num},'lrradp')))

%% 
clear;
addpath('Datasets/');
addpath('Functions/');
addpath('LRR');
data_num = 5;
run_time = 10;
dataset_name = {'ORL_32x32','Umist','YaleB_3232','COIL20','mnist_all','CCC40','USPSfu','PD200'};
load(strcat(dataset_name {data_num},'.mat'))
if data_num == 1
    interval = 40;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 2
    fea=X';
    interval = 20;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 3
    interval = 20;%这个是去样本数的间隔
    ttime = 1;
elseif data_num == 4
    interval = 20;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 5
    interval = 10;%这个是去样本数的间隔
    num = 200;
    fea = double([train0(1:num,:);train1(1:num,:);train2(1:num,:);train3(1:num,:);train4(1:num,:);train5(1:num,:);train6(1:num,:);train7(1:num,:);train8(1:num,:);train9(1:num,:)]);
    gnd = double([ones(num,1);2*ones(num,1);3*ones(num,1);4*ones(num,1);5*ones(num,1);6*ones(num,1);7*ones(num,1);8*ones(num,1);9*ones(num,1);10*ones(num,1)]);
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 6
    interval = 50;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 7
    dnum = 20;
    num = dnum;
    fea = [data0(:,1:dnum)';data1(:,1:dnum)';data2(:,1:dnum)';data3(:,1:dnum)';data4(:,1:dnum)';data5(:,1:dnum)';data6(:,1:dnum)';data7(:,1:dnum)';data8(:,1:dnum)';data9(:,1:dnum)'];
    fea = double(fea);
    gnd = double([ones(num,1);2*ones(num,1);3*ones(num,1);4*ones(num,1);5*ones(num,1);6*ones(num,1);7*ones(num,1);8*ones(num,1);9*ones(num,1);10*ones(num,1)]);
    interval = 2;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 8
    interval = 10;
    ttime = floor(length(unique(gnd))/interval);
end
folder_now = pwd;
addpath([folder_now, '\funs']);
samp_num = size(fea,1);
nnClass = length(unique(gnd));  % The number of classes;
num_Class=[];
for i=1:nnClass
  num_Class=[num_Class length(find(gnd==i))]; %The number of samples of each class
end
num = 7;
fea =  NormalizeFea(fea);
test = fea;
runtimes = 10;
gama_1 = 50;
gama_2 = 11;
minU0 = 1e-12;
maxU0 = 1e5;
label_r = cell(num,runtimes);
gnd_r = cell(num,runtimes);
rate = zeros(1,runtimes); 
   [A OBJ] = LRSA(test', gama_1, gama_2);%LRRADP
%     [A OBJ] = solve_lrr(test', 1);%LRR
%     [A OBJ] =  LRRHWAP(test', 50, 11,5,99);
    A = NormalizeFea(A); 
    A = A + 0.0000001*ones(size(A));
    AG = A;
    %save('AG','AG');
    %save('OBJ','OBJ');
    W = A;
    D = diag(sum(A));
for time = 1:7
    sele = time;
    rate = zeros(1,runtimes);
    for r=1:runtimes
%---------------------------------------------------------------   
        Y = zeros(samp_num, nnClass);
        cLab = zeros(samp_num, nnClass);
        FF = zeros(samp_num, nnClass);
        TestF = ones(samp_num, nnClass);
        U0 = zeros(samp_num, samp_num);
        Umin = minU0*ones(samp_num, samp_num);
        for  j=1:nnClass
            idx=find(gnd==j);
            cLab(idx, j) = 1;
            randIdx=randperm(num_Class(j)); %randIdx create m random number, m is the size of idx.
            %randIdx = 1:sele;
            Y(idx(randIdx(1:sele)),j) = 1;
            TestF(idx(randIdx(1:sele)),:) = 0;      
            for s = 1:sele
                U0(idx(randIdx(s)),idx(randIdx(s))) = maxU0;
            end                
        end
        F = (D+U0-W+Umin)\U0*Y;
        [maxF, idF] = max(F,[],2);
        for j = 1:samp_num
            FF(j,idF(j)) = 1;
        end
        recogNum = sum(sum((cLab.*FF).*TestF));
        testNum = samp_num-sele*nnClass;
        ratio = double(recogNum)/testNum;
        rate(r) = ratio;
          ll = FF.*TestF;
        ll = (1:nnClass)*ll';
        ll = ll(find(ll>0));
        gndd = cLab.*TestF;
        gndd = (1:nnClass)*gndd';
        gndd = gndd(find(gndd>0));
        label_r{time,r} = ll;
        gnd_r{time,r} = gndd;
        testNum = samp_num-sele*nnClass;
        ratio = double(recogNum)/testNum;
        rate(r) = ratio;
        [aARI(time,r),aAMI(time,r),aNMI(time,r),aACC(time,r)] = evaluate(ll,nnClass,gndd,nnClass);
        aAUC(time,r) = AUC(gndd,ll);
        [aTPR(time,r),aFPR(time,r),aPrecision(time,r),aRecall(time,r),aF1(time,r)] = performanceIndexs(gndd,ll);
    end
    %max(rate)
    rate7(time) = mean(rate);
%     std(rate);
 amARI = mean(aARI,2);
    amAMI = mean(aAMI,2);
    amNMI = mean(aNMI,2);
    amACC = mean(aACC,2);
    amAUC = mean(aAUC,2);
    amTPR = mean(aTPR,2);
    amFPR = mean(aTPR,2);
    amPrecision = mean(aPrecision,2);
    amRecall = mean(aRecall,2);
    amF1 = mean(aF1,2);
    aaresult = [amARI,amAMI,amNMI,amACC,amAUC,amTPR,amFPR,amPrecision,amRecall,amF1];
end
save(strcat('Results/newrevise/',strcat('ss',dataset_name{data_num},'lrradp')))

%% 
clear;
addpath('Datasets/');
addpath('Functions/');
addpath('LRR');
data_num = 6;
run_time = 10;
dataset_name = {'ORL_32x32','Umist','YaleB_3232','COIL20','mnist_all','CCC40','USPSfu','PD200'};
load(strcat(dataset_name {data_num},'.mat'))
if data_num == 1
    interval = 40;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 2
    fea=X';
    interval = 20;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 3
    interval = 20;%这个是去样本数的间隔
    ttime = 1;
elseif data_num == 4
    interval = 20;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 5
    interval = 10;%这个是去样本数的间隔
    num = 200;
    fea = double([train0(1:num,:);train1(1:num,:);train2(1:num,:);train3(1:num,:);train4(1:num,:);train5(1:num,:);train6(1:num,:);train7(1:num,:);train8(1:num,:);train9(1:num,:)]);
    gnd = double([ones(num,1);2*ones(num,1);3*ones(num,1);4*ones(num,1);5*ones(num,1);6*ones(num,1);7*ones(num,1);8*ones(num,1);9*ones(num,1);10*ones(num,1)]);
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 6
    interval = 50;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 7
    dnum = 20;
    num = dnum;
    fea = [data0(:,1:dnum)';data1(:,1:dnum)';data2(:,1:dnum)';data3(:,1:dnum)';data4(:,1:dnum)';data5(:,1:dnum)';data6(:,1:dnum)';data7(:,1:dnum)';data8(:,1:dnum)';data9(:,1:dnum)'];
    fea = double(fea);
    gnd = double([ones(num,1);2*ones(num,1);3*ones(num,1);4*ones(num,1);5*ones(num,1);6*ones(num,1);7*ones(num,1);8*ones(num,1);9*ones(num,1);10*ones(num,1)]);
    interval = 2;%这个是去样本数的间隔
    ttime = floor(length(unique(gnd))/interval);
elseif data_num == 8
    interval = 10;
    ttime = floor(length(unique(gnd))/interval);
end
folder_now = pwd;
addpath([folder_now, '\funs']);
samp_num = size(fea,1);
nnClass = length(unique(gnd));  % The number of classes;
num_Class=[];
for i=1:nnClass
  num_Class=[num_Class length(find(gnd==i))]; %The number of samples of each class
end
num = 7;
fea =  NormalizeFea(fea);
test = fea;
runtimes = 10;
gama_1 = 50;
gama_2 = 11;
minU0 = 1e-12;
maxU0 = 1e5;
label_r = cell(num,runtimes);
gnd_r = cell(num,runtimes);
rate = zeros(1,runtimes); 
   [A OBJ] = LRSA(test', gama_1, gama_2);%LRRADP
%     [A OBJ] = solve_lrr(test', 1);%LRR
%     [A OBJ] =  LRRHWAP(test', 50, 11,5,99);
    A = NormalizeFea(A); 
    A = A + 0.0000001*ones(size(A));
    AG = A;
    %save('AG','AG');
    %save('OBJ','OBJ');
    W = A;
    D = diag(sum(A));
for time = 1:7
    sele = time;
    rate = zeros(1,runtimes);
    for r=1:runtimes
%---------------------------------------------------------------   
        Y = zeros(samp_num, nnClass);
        cLab = zeros(samp_num, nnClass);
        FF = zeros(samp_num, nnClass);
        TestF = ones(samp_num, nnClass);
        U0 = zeros(samp_num, samp_num);
        Umin = minU0*ones(samp_num, samp_num);
        for  j=1:nnClass
            idx=find(gnd==j);
            cLab(idx, j) = 1;
            randIdx=randperm(num_Class(j)); %randIdx create m random number, m is the size of idx.
            %randIdx = 1:sele;
            Y(idx(randIdx(1:sele)),j) = 1;
            TestF(idx(randIdx(1:sele)),:) = 0;      
            for s = 1:sele
                U0(idx(randIdx(s)),idx(randIdx(s))) = maxU0;
            end                
        end
        F = (D+U0-W+Umin)\U0*Y;
        [maxF, idF] = max(F,[],2);
        for j = 1:samp_num
            FF(j,idF(j)) = 1;
        end
        recogNum = sum(sum((cLab.*FF).*TestF));
        testNum = samp_num-sele*nnClass;
        ratio = double(recogNum)/testNum;
        rate(r) = ratio;
          ll = FF.*TestF;
        ll = (1:nnClass)*ll';
        ll = ll(find(ll>0));
        gndd = cLab.*TestF;
        gndd = (1:nnClass)*gndd';
        gndd = gndd(find(gndd>0));
        label_r{time,r} = ll;
        gnd_r{time,r} = gndd;
        testNum = samp_num-sele*nnClass;
        ratio = double(recogNum)/testNum;
        rate(r) = ratio;
        [aARI(time,r),aAMI(time,r),aNMI(time,r),aACC(time,r)] = evaluate(ll,nnClass,gndd,nnClass);
        aAUC(time,r) = AUC(gndd,ll);
        [aTPR(time,r),aFPR(time,r),aPrecision(time,r),aRecall(time,r),aF1(time,r)] = performanceIndexs(gndd,ll);
    end
    %max(rate)
    rate7(time) = mean(rate);
%     std(rate);
 amARI = mean(aARI,2);
    amAMI = mean(aAMI,2);
    amNMI = mean(aNMI,2);
    amACC = mean(aACC,2);
    amAUC = mean(aAUC,2);
    amTPR = mean(aTPR,2);
    amFPR = mean(aTPR,2);
    amPrecision = mean(aPrecision,2);
    amRecall = mean(aRecall,2);
    amF1 = mean(aF1,2);
    aaresult = [amARI,amAMI,amNMI,amACC,amAUC,amTPR,amFPR,amPrecision,amRecall,amF1];
end
save(strcat('Results/newrevise/',strcat('ss',dataset_name{data_num},'lrradp')))