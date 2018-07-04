%时均轴向空隙率分布%
clear;clc;
rho_s=930;rho_g=1.1795;g=9.81;
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
    if contains(tline, 'av_dpdy')
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
    if (data(i,2)>0.09||data(i,4)>0.09)
        data(i,:)=0;
    end
end
data(all(data==0,2),:)=[];
sortdata=sortrows(data,3);
a=sortdata(:,[1,3]);
b=unique(a(:,2));
axialvoidage=zeros(size(b,1),2);
j=1;m=0;e=0.001;
for i=1:size(a,1)
    if (abs(a(i,2)-b(j))<e)
        axialvoidage(j,:)=axialvoidage(j,:)+a(i,:);
    else
        axialvoidage(j,:)=axialvoidage(j,:)/m;
        j=j+1;m=0;
        axialvoidage(j,:)=axialvoidage(j,:)+a(i,:);
    end
    m=m+1;
    if (i==size(a,1))
        axialvoidage(j,:)=axialvoidage(j,:)/m;
    end
end
axialvoidage(all(axialvoidage==0,2),:)=[];
for i=1:size(axialvoidage,1)
    axialvoidage(i,1)=min(1,(rho_s+axialvoidage(i,1)/g)/(rho_s-rho_g));
end
%将结果以ASCII的方式保存为txt文件%
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %字符串连接
save(char(str), 'axialvoidage','-ascii');  %注意save函数的格式
fclose all;
