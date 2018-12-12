%出口质量流量%
clear;clc
rhop=930;
[filename,pathname]=uigetfile('*.*','选择数据文件');
if (isequal(filename,0)||isequal(filename,0))
    disp('您取消了操作，已退出')
    return
else
    fid=fopen(fullfile(pathname, filename),'r');
end
while ~feof(fid)
    fgetl(fid);
    area1=fscanf(fid,'%f',[27 inf]);
end
area2=area1';
area=area2(:,5);
maindir = 'D:\raw_cell';
subdir =  dir( maindir );   % 先确定子文件
solidfluxs=zeros(length(subdir)-2,2);
for i = 1 : length( subdir )
    if( isequal( subdir( i ).name, '.' ) ||  isequal( subdir( i ).name, '..' ))   % 如果不是目录跳过
        continue;
    end
    fid=fopen(fullfile(maindir, subdir( i ).name),'r');
    while ~feof(fid)
        tline=fgetl(fid);
        if contains(tline, 'Time =')
            time=regexp(tline, "=", 'split');   % 获取时间
            solidfluxs(i-2,1)=str2double(time(2));
        end
        data1=fscanf(fid,'%f',[16 inf]);
    end
    data2=data1';
    data3=data2(:,[1 2 3 9 10]);
    data=[data3,area];
    for j=1:size(data,1)
        if (data(j,1)~=50||data(j,2)<876)
            data(j,:)=0;
        end
    end
    data(all(data==0,2),:)=[];
    solidflux=0;
    for k=1:size(data,1)
        if (data(k,2)>0)
            solidflux=solidflux+(1-data(k,4))*data(k,5)*data(k,6);
        end
    end
    solidflux=rhop*solidflux/sum(data(:,6));
    solidfluxs(i-2,2)=solidflux;
    sta=fclose(fid);
end
solidfluxs=sortrows(solidfluxs);
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);
save(char(str), 'solidfluxs','-ascii');
