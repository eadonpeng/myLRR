%这个是测试两个参数的代码根据测试的不一样注释17和18行即可
clear;
addpath('Datasets/');
addpath('Functions/');
ttime = 99;
load ORL_32x32 
data = fea;
datal = gnd;
parfor time =1:ttime
    kk = 10;%2*time2 ;%类别数
    number = find(datal==kk);%每一类的个数
    number=max(number);
    fea=data(1:number,:);%kk *number,:);  
    gnd=datal(1:number);%kk*number);
    kkk=5;
    fea=NormalizeFea(fea); 
    [new4 b4 dis4] =  LRRHWAP(fea',0.1,0.1,kkk,time);
    accuracy4 = zeros(1,10);
    for i = 1:10
        c4 =  NJW(new4,kk);
        idx=bestMap(gnd,c4); % 匹配
        accuracy4(i)=length(find(gnd == idx))/length(gnd);% 找到gnd和已经分类号的idx中相匹配的值并计算总量
    end 
    accuracy4_m(time)=mean(accuracy4);
    NMI4(time) = NormalizedMutualInformation(gnd,c4,length(gnd),kk); 
end
plot(1:ttime,accuracy4_m);
saveas(gcf, 'testk', 'fig')