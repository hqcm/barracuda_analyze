%径向空隙率分布%
clear;clc;
e=1.0e-2;
prompt={'请输入床层高度，单位为m:'};
answer=inputdlg(prompt);
[filename,pathname]=uigetfile('*.*','选择数据文件');
height=str2double(answer);
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
    if contains(tline, 'av_pVolF')
        av_pVolF=10*str2double(tline(2))+str2double(tline(3));  %得到空隙率所在的列数
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
data=data2(:,[2 av_pVolF Tcolnumber-2 Tcolnumber-1 Tcolnumber]);  %提取列数据
data(:,3)=data(:,3)-0.16243221;  %将x的起始点设为0点
data(:,4)=data(:,4)-(-1.634885);  %将y的起始点设为0点
data(:,5)=data(:,5)-(-0.102081);  %将z的起始点设为0点
for i=1:size(data,1)
    if (data(i,1)>7||abs(data(i,5)-height)>e)
        data(i,:)=0;
    end
end
data(all(data==0,2),:)=[];
x_center=0.0149;%i从1到6
y_center=0.0722853;%j从11到16
R=0.016063;%Rx小于Ry，取Ry作为R
data(:,3)=(data(:,3)-x_center)/R;
data(:,4)=(data(:,4)-y_center)/R;
for i=1:size(data,1)
    if data(i,3)>0
        data(i,1)=sqrt(data(i,3)^2+data(i,4)^2);
    else
        data(i,1)=-sqrt(data(i,3)^2+data(i,4)^2);
    end
end
data=data(:,1:2);
data=sortrows(data,1);
data(:,2)=1-data(:,2);%输出空隙率
cof=10;%数据收缩系数
surpassnumber=size(data,1)-mod(size(data,1) ,cof);
data=data(1:surpassnumber,:);
data=mat2cell(data,cof*ones(1,size(data,1)/cof),2);%将矩阵分割为元胞，第二个数组控制行的分割，第三个参数控制列的分割
data = cellfun(@mean, data,'UniformOutput',false);%当返回的值不能串联成数组时，可以按元胞数组的形式返回，此时要加上'UniformOutput',false
radialvoidage=cell2mat(data);%将元胞还原为矩阵
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %字符串连接
save(char(str), 'radialvoidage','-ascii');  %注意save函数的格式
