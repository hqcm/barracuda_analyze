%时均+高度平均轴向空隙率分布%
clear;clc;
rho_s=2650;g=9.81;R=8.314;M=18/1000;
[filename,pathname]=uigetfile('*.*','选择数据文件');
if (isequal(filename,0)||isequal(filename,0))
    disp('您取消了操作，已退出')
    return
else
    fid=fopen(fullfile(pathname, filename),'r');
end
fidout=fopen('tempfile.txt','w');  %创建临时文件存储第一行数据;'w':写入（文件若不存在，自动创建）
%读取数据%
while ~feof(fid)                                  % 判断是否为文件末尾
    tline=fgetl(fid);                                 % 从文件读行
    if contains(tline, 'Pressure')
        P=str2double(tline(2));  %得到轴向压力所在的列数
    elseif contains(tline, 'f-Temp')
        T=10*str2double(tline(2))+str2double(tline(3));  %得到流体温度所在的列数
    elseif contains(tline, 'av_dpdz')
        av_dpdz=10*str2double(tline(2))+str2double(tline(3));  %得到轴向压降所在的列数
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
data=data2(:,[2 P T av_dpdz Tcolnumber]);  %提取列数据
for i=1:size(data,1)
    if (data(i,1)>7)
        data(i,:)=0;
    end
end
data(all(data==0,2),:)=[];
rho_g=data(:,2)./data(:,3)*M/R;
data(:,1)=min(1,(rho_s+data(:,4)/g)./(rho_s-rho_g));
sortdata=sortrows(data,5);
a=sortdata(:,[1 5]);
a(:,2)=a(:,2)-a(1,2);
surpassnumber=size(a,1)-mod(size(a,1) ,1000);%变成1000的整数倍
a=a(1:surpassnumber,:);
a=mat2cell(a,1000*ones(1,size(a,1)/1000),2);%将矩阵分割为元胞，第二个数组控制行的分割，第三个参数控制列的分割
a = cellfun(@mean, a,'UniformOutput',false);%当返回的值不能串联成数组时，可以按元胞数组的形式返回，此时要加上'UniformOutput',false
axialvoidage=cell2mat(a);%将元胞还原为矩阵
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %字符串连接
save(char(str), 'axialvoidage','-ascii');  %注意save函数的格式
fclose all;