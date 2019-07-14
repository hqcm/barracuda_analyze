%径向轴向速度分布%
clear;clc;
e1=1.0e-2;e2=0.03;
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
    if contains(tline, 'avP_yVel')
       colnumber=10*str2double(tline(2))+str2double(tline(3));  %得到空隙率所在的列数
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
for i=1:size(data,1)
    if (data(i,2)>0.09||data(i,4)>0.09||abs(data(i,3)-height)>e1)
        data(i,:)=0;
    else
        data(i,1)=data(i,1);
        data(i,2)=(data(i,2)-0.045)/0.045;
        data(i,4)=(data(i,4)-0.045)/0.045;
        data(i,2)=min(sqrt((data(i,2).^2+data(i,4).^2)),1);
    end
end
data(all(data==0,2),:)=[];  %2表示沿着矩阵的第二个维度（行）的的方向来判断元素是否都是100
a0=sortrows(data,2);
a=a0(:,[2 1]);
b=uniquetol(a(:,1),e2);  %给定大小为e2的误差限
radialvelocity=zeros(size(b,1),2);
j=1;m=0;
for i=1:size(a,1)
    if (abs(a(i,1)-b(j))<e2)
        radialvelocity(j,1:2)=radialvelocity(j,1:2)+a(i,1:2);
    else
        radialvelocity(j,1:2)=radialvelocity(j,1:2)/m;
        j=j+1;m=0;
        radialvelocity(j,1:2)=radialvelocity(j,1:2)+a(i,1:2);
    end
    m=m+1;
    if (i==size(a,1))
        radialvelocity(j,1:2)=radialvelocity(j,1:2)/m;
    end
end
radialvelocity(all(radialvelocity==0,2),:)=[];
%将结果以ASCII的方式保存为txt文件%
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %字符串连接
save(char(str), 'radialvelocity','-ascii');  %注意save函数的格式
fclose all;
