%����ֱ���ش����ķֲ�%
clear;clc;
e=1.0e-2;r=-1:0.1:1;
radialpsd=zeros(length(r),2);
%��ȡ�ļ�%
fileFolder=uigetdir('ѡ���ļ���');  %�ļ��е�·��
prompt={'�����봲��߶ȣ���λΪm:'};
h=str2double(inputdlg(prompt));
dirOutput=dir(fullfile(fileFolder,'*'));%������ڲ�ͬ���͵��ļ����á�*����ȡ���У������ȡ�ض������ļ���'.'�����ļ����ͣ������á�.jpg��
fileNames={dirOutput.name}';
Lengthfiles = size(fileNames,1);
for i = 3 : Lengthfiles%ǰ���������ֲ����ļ���
    openfilename = strcat(fileFolder,'\',fileNames(i));
    fid=fopen(openfilename{1,1},'r');  %���ļ�
    fidout=fopen('tempfile.txt','w');  %������ʱ�ļ��洢��һ������;'w':д�루�ļ��������ڣ��Զ�������
    %��ȡ����%
    while ~feof(fid)                                  % �ж��Ƿ�Ϊ�ļ�ĩβ
        tline=fgetl(fid);                                 % ���ļ�����
        %�õ������뾶���ڵ�����%
        if contains(tline, 'rad')
            if isspace(tline(3))
                rad=str2double(tline(2));  %����Ϊ1λ
            else
                rad=10*str2double(tline(2))+str2double(tline(3));  %����Ϊ2λ
            end
        end
        if isspace(tline(1))     % �ж����ַ��Ƿ��ǿո񣨴���Ϊ�����У�
            fprintf(fidout,'%s\n\n',tline);                  % ����������У��Ѵ�������д����ʱ�ļ�
            data1=fscanf(fid,'%f',[Tcolnumber inf]);  %��ȡ���ݣ���ȡ��˳���ǰ��ж�ȡ���洢��ʱ���ǰ��д洢
            break
        else
            Tcolnumber=10*str2double(tline(2))+str2double(tline(3));  %�õ�����������
        end
    end
    line1=importdata('tempfile.txt');
    fclose(fidout);  %ע����ɾ���ļ�ǰҪ�ȹرմ��ļ�
    delete tempfile.txt;  %ɾ��������ʱ�ļ�
    data2=[line1;data1'];
    data=data2(:,[rad Tcolnumber-2 Tcolnumber-1 Tcolnumber]);  %��ȡ������
    data(:,2)=data(:,2)-0.16243221;  %��x����ʼ����Ϊ0��
    data(:,3)=data(:,3)-(-1.634885);  %��y����ʼ����Ϊ0��
    data(:,4)=data(:,4)-(-0.102081);  %��z����ʼ����Ϊ0��
    for j=1:size(data,1)
        if (data(j,2)>0.0298||abs(data(j,4)-h)>e)
            data(j,:)=0;
        end
    end
    data(all(data==0,2),:)=[];
    x_center=0.0149;%i��1��6
    y_center=0.0722853;%j��11��16
    R=0.016063;%RxС��Ry��ȡRy��ΪR
    data(:,2)=(data(:,2)-x_center)/R;
    data(:,3)=(data(:,3)-y_center)/R;
    data(all(data==0,2),:)=[];  %2��ʾ���ž���ĵڶ���ά�ȣ��У��ĵķ������ж�Ԫ���Ƿ���0
    for j=1:size(data,1)
        if data(j,2)>0
            data(j,4)=min(sqrt(data(j,2)^2+data(j,3)^2),1);
        else
            data(j,4)=max(-sqrt(data(j,2)^2+data(j,3)^2),-1);
        end
    end
    data=sortrows(data,4);
    data=data(:,[4 1]);
    data(:,2)=2*data(:,2);%���뾶��Ϊֱ��
    j=1;m=0;psd=zeros(length(r),2);  %ע��psd�ĸ�ֵλ�ã���Ҫ���ڵ�һ��ѭ��������
    for k=1:size(data,1)
        if (data(k,1)<=r(j))
            psd(j,:)=psd(j,:)+data(k,:);
        else
            psd(j,:)=psd(j,:)/m;
            j=j+1;m=0;
            psd(j,:)=psd(j,:)+data(k,:);
        end
        m=m+1;
        if (k==size(data,1))
            psd(j,:)=psd(j,:)/m;
        end
    end
    radialpsd=radialpsd+psd;
end
radialpsd=radialpsd/(Lengthfiles-2);
%�������ASCII�ķ�ʽ����Ϊtxt�ļ�%
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %�ַ�������
save(char(str), 'radialpsd','-ascii');  %ע��save�����ĸ�ʽ
fclose all;
