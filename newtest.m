%%%%������������־������Ĵ���
%%%%
%0----kmeans
%1----NJW
%2----NSLLR
%3----LRRADP
%4----LRRHWAP
%��Ҫ�ĸ����ݼ���ĳһ�����ݼ�ǰ���%ȥ������
%����orl����8��ÿ�μ����5����ttime = 8��interval = 5
%���Ľ����accuracy0_m��accuracy4_m��NMI0-NMI4
clear;
ttime = 10;%�����ʵ�����
interval = 2;%�����ȥ�������ļ��
addpath('Datasets/');
addpath('Functions/');
addpath('LRR');
for time1 = 1:1
    for time2 =1:ttime
        %load COIL20;
        %load YaleBext_3232;
%         load ORL_32x32 
        %%%%%%%%%%umist��Ҫ��������һ��ע��
        %load umist 
        %fea=X';
        %%%%%%%%%%%%%
%         load AR_database_60_43
%         fea = [NewTest_DAT;NewTrain_DAT];
%         fea = double(fea);
%         gnd = [testlabels,trainlabels];
%         gnd = double(gnd);
%         fea1 = [];
%         gnd1 = [];
%         for i = 1:100
%             place = find(gnd == i);
%             fea1 = [fea1;fea(place,:)];
%             gnd1 = [gnd1,gnd(place)];
%         end
%         fea = fea1;
%         gnd = gnd1';
        %%%%%%%%%%%%%%%%%%
        load USPSfu
        fea = [];
        gnd = [];
        num = 10;
        for i = 1:10
            save = data(:,:,i);
            save = save';
            fea = [fea;save(1:num,:)];
            gnd = [gnd;i*ones(num,1)];
        end
        fea = double(fea);
        gnd =double(gnd);
            
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%
        data = fea;
        datal = gnd;
        kk = interval*time2;%�����
        number = find(gnd==kk);%ÿһ��ĸ���
        number=max(number);
        fea=data(1:number,:);%kk *number,:);  
        gnd=datal(1:number);%kk*number);
        fea=NormalizeFea(fea); 
        [new1 b1 dis1] = LRSA(fea');
        [new2 b4 dis4] = LRRHWAP(fea',0.1,0.1,5,99);%yale���ݼ��õĵ���k=3
        k=5;%knn��k
        Y = fea';
        Yg = fea';
%         a=fkNN(Yg,k);
%         b=constractmap(a);
%         c = transmit(b,0);
%         d = (c+c')/2;
%         d(find(d>0))=1;
        [b,c]=fkNN(Yg,k);
        aa = constractmap(b);
        aa(find(aa>0))=1;
       % bb = sendknew(aa,99,1/5);
        bb1 = sendknew1(aa,99, 1/5);
        d = bb1;
        d = d+d';
       [new,OBJ] =  sparse_graph_LRR(Yg,d);
        for i = 1:10
            c0 =  kmeans(fea,kk);
            idx=bestMap(gnd,c0); % ƥ��
            accuracy0(i) = length(find(gnd == idx))/length(gnd);% �ҵ�gnd���Ѿ�����ŵ�idx����ƥ���ֵ����������
            c1 =  NJW(fea,kk); 
            idx=bestMap(gnd,c1); % ƥ��
            accuracy1(i) = length(find(gnd == idx))/length(gnd);% �ҵ�gnd���Ѿ�����ŵ�idx����ƥ��� ֵ����������
            c2 =  NJW(new,kk);
            idx=bestMap(gnd,c2); % ƥ��
            accuracy2(i) = length(find(gnd == idx))/length(gnd);% �ҵ�gnd���Ѿ�����ŵ�idx����ƥ���ֵ����������
            c3 =  NJW(new1,kk);
            idx = bestMap(gnd,c3); % ƥ��
            accuracy3(i) = length(find(gnd == idx))/length(gnd);% �ҵ�gnd���Ѿ�����ŵ�idx����ƥ���ֵ����������
            c4 =  NJW(new2,kk);
            idx=bestMap(gnd,c4); % ƥ��
            accuracy4(i)=length(find(gnd == idx))/length(gnd);% �ҵ�gnd���Ѿ�����ŵ�idx����ƥ���ֵ����������
        end 
        accuracy0_m(time1,time2)=mean(accuracy0);
        NMI0(time1,time2) = NormalizedMutualInformation(gnd,c0,length(gnd),kk); 
        accuracy1_m(time1,time2)=mean(accuracy1);
        NMI1(time1,time2) = NormalizedMutualInformation(gnd,c1,length(gnd),kk); 
        accuracy2_m(time1,time2)=mean(accuracy2);
        NMI2(time1,time2) = NormalizedMutualInformation(gnd,c2,length(gnd),kk); 
        accuracy3_m(time1,time2)=mean(accuracy3);
        NMI3(time1,time2) = NormalizedMutualInformation(gnd,c3,length(gnd),kk); 
        accuracy4_m(time1,time2)=mean(accuracy4);
        NMI4(time1,time2) = NormalizedMutualInformation(gnd,c4,length(gnd),kk); 
    end
end