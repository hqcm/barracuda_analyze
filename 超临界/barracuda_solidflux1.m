%质量流量%
clear;clc;
rho_s=2650;
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
    if contains(tline, 'cellVol')
        cellVol=str2double(tline(2));  %得到轴向压力所在的列数
    elseif contains(tline, 'av_pVolF')
        av_pVolF=10*str2double(tline(2))+str2double(tline(3));  %得到流体温度所在的列数
    elseif contains(tline, 'avP_zVel')
        avP_zVel=10*str2double(tline(2))+str2double(tline(3));  %得到流体温度所在的列数
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
data=data2(:,[2 4 cellVol av_pVolF avP_zVel Tcolnumber]);  %提取列数据
solidflux=0;area=0;
for i=1:size(data,1)
    if (data(i,2)==469&&(data(i,1)<=7))
        solidflux=solidflux+data(i,3)*data(i,4)*data(i,5);
        area=area+data(i,3);
    end
end
solidflux=rho_s*solidflux/area;
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %字符串连接
save(char(str), 'solidflux','-ascii');  %注意save函数的格式
fclose all;