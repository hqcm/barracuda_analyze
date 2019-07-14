%颗粒直径沿床径的分布%
clear;clc;
e=1.0e-2;r=-1:0.1:1;
radialpsd=zeros(length(r),2);
%读取文件%
fileFolder=uigetdir('选择文件夹');  %文件夹的路径
prompt={'请输入床层高度，单位为m:'};
h=str2double(inputdlg(prompt));
dirOutput=dir(fullfile(fileFolder,'*'));%如果存在不同类型的文件，用‘*’读取所有，如果读取特定类型文件，'.'加上文件类型，例如用‘.jpg’
fileNames={dirOutput.name}';
Lengthfiles = size(fileNames,1);
for i = 3 : Lengthfiles%前面两个名字不是文件名
    openfilename = strcat(fileFolder,'\',fileNames(i));
    fid=fopen(openfilename{1,1},'r');  %打开文件
    fidout=fopen('tempfile.txt','w');  %创建临时文件存储第一行数据;'w':写入（文件若不存在，自动创建）
    %读取数据%
    while ~feof(fid)                                  % 判断是否为文件末尾
        tline=fgetl(fid);                                 % 从文件读行
        %得到颗粒半径所在的列数%
        if contains(tline, 'rad')
            if isspace(tline(3))
                rad=str2double(tline(2));  %列数为1位
            else
                rad=10*str2double(tline(2))+str2double(tline(3));  %列数为2位
            end
        end
        if isspace(tline(1))     % 判断首字符是否是空格（此行为数据行）
            fprintf(fidout,'%s\n\n',tline);                  % 如果是数字行，把此行数据写入临时文件
            data1=fscanf(fid,'%f',[Tcolnumber inf]);  %读取数据，读取的顺序是按行读取，存储的时候是按列存储
            break
        else
            Tcolnumber=10*str2double(tline(2))+str2double(tline(3));  %得到数据总列数
        end
    end
    line1=importdata('tempfile.txt');
    fclose(fidout);  %注意在删除文件前要先关闭此文件
    delete tempfile.txt;  %删除创建临时文件
    data2=[line1;data1'];
    data=data2(:,[rad Tcolnumber-2 Tcolnumber-1 Tcolnumber]);  %提取列数据
    data(:,2)=data(:,2)-0.16243221;  %将x的起始点设为0点
    data(:,3)=data(:,3)-(-1.634885);  %将y的起始点设为0点
    data(:,4)=data(:,4)-(-0.102081);  %将z的起始点设为0点
    for j=1:size(data,1)
        if (data(j,2)>0.0298||abs(data(j,4)-h)>e)
            data(j,:)=0;
        end
    end
    data(all(data==0,2),:)=[];
    x_center=0.0149;%i从1到6
    y_center=0.0722853;%j从11到16
    R=0.016063;%Rx小于Ry，取Ry作为R
    data(:,2)=(data(:,2)-x_center)/R;
    data(:,3)=(data(:,3)-y_center)/R;
    data(all(data==0,2),:)=[];  %2表示沿着矩阵的第二个维度（行）的的方向来判断元素是否都是0
    for j=1:size(data,1)
        if data(j,2)>0
            data(j,4)=min(sqrt(data(j,2)^2+data(j,3)^2),1);
        else
            data(j,4)=max(-sqrt(data(j,2)^2+data(j,3)^2),-1);
        end
    end
    data=sortrows(data,4);
    data=data(:,[4 1]);
    data(:,2)=2*data(:,2);%将半径变为直径
    j=1;m=0;psd=zeros(length(r),2);  %注意psd的赋值位置，不要放在第一层循环的外面
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
%将结果以ASCII的方式保存为txt文件%
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %字符串连接
save(char(str), 'radialpsd','-ascii');  %注意save函数的格式
fclose all;
