%质量流量%
clear;clc;
%读取文件%
[filename,pathname]=uigetfile('*.*','选择数据文件');
if (isequal(filename,0)||isequal(filename,0))
    disp('您取消了操作，已退出')
    return
else
    fid=fopen(fullfile(pathname, filename),'r');
end
%读取数据%
while ~feof(fid)                                  % 判断是否为文件末尾
    tline=fgetl(fid);                                 % 从文件读行
    data=fscanf(fid,'%f',[2 inf]);  %读取数据，读取的顺序是按行读取，存储的时候是按列存储
end
data=data';
for j=1:size(data,1)
    if (data(j,1)>60||data(j,1)<40)
        data(j,:)=0;
    end
end
data(all(data==0,2),:)=[];
flux=mean(data);
flux=flux(1);
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %字符串连接
save(char(str), 'flux','-ascii');  %注意save函数的格式
fclose all;
