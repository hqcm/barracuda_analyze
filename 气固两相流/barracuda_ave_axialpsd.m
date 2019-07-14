%颗粒直径沿床高的分布%
clear;clc;
h=0.35:0.35:10.5;
axialpsd=zeros(length(h),2);  %将10.5m划分为30段，每段求粒径的均值以及对应的位置均值，再作图
%读取文件%
my_dir=uigetdir('选择文件夹');  %文件夹的路径
files=dir(my_dir);
Lengthfiles=length(files);  %文件夹中文件的个数
prompt={'请输入首位文件名的整数位数字:','请输入步长:'};
input=str2double(inputdlg(prompt));
for i=0:Lengthfiles-3
    name=input(2)+i*input(3);  %起始时间和时间步长
    openfilename=sprintf('%s%s%d',my_dir,'\zh',name);  %得到文件名
    fid=fopen(openfilename,'r');  %打开文件
    fidout=fopen('tempfile.txt','w');  %创建临时文件存储第一行数据;'w':写入（文件若不存在，自动创建）
    %读取数据%
    while ~feof(fid)                                  % 判断是否为文件末尾
        tline=fgetl(fid);                                 % 从文件读行
        %得到颗粒半径所在的列数%
        if contains(tline, 'rad')
            if isspace(tline(3))
                colnumber=str2double(tline(2));  %列数为1位
            else
                colnumber=10*str2double(tline(2))+str2double(tline(3));  %列数为2位
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
    data=data2(:,[colnumber Tcolnumber-2 Tcolnumber-1 Tcolnumber]);  %提取列数据
    for j=1:size(data,1)
        if (data(j,2)>0.09||data(j,4)>0.09)
            data(j,:)=0;
        end
    end
    data(all(data==0,2),:)=[];
    sortdata=sortrows(data,3);
    a=sortdata(:,[1,3]);
    j=1;m=0;psd=zeros(length(h),2);  %注意psd的赋值位置，不要放在第一层循环的外面
    for k=1:size(a,1) %根据轴向高度的分段来进行轴向平均，以减少数据量
        if (a(k,2)<=h(j))
            psd(j,:)=psd(j,:)+a(k,:);
        else
            psd(j,:)=psd(j,:)/m;
            j=j+1;m=0;
            psd(j,:)=psd(j,:)+a(k,:);
        end
        m=m+1;
        if (k==size(a,1))
            psd(j,:)= psd(j,:)/m;
        end
    end
    axialpsd=axialpsd+psd;
end
axialpsd=axialpsd/(Lengthfiles-2);
%将结果以ASCII的方式保存为txt文件%
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %字符串连接
save(char(str), 'axialpsd','-ascii');  %注意save函数的格式
fclose all;
