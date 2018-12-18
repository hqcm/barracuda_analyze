%时均出口质量流量%
%直接对质量流量求平均%
clear;clc
[filename,pathname]=uigetfile('*.*','选择数据文件');
if (isequal(filename,0)||isequal(filename,0))
    disp('您取消了操作，已退出')
    return
else
    fid=fopen(fullfile(pathname, filename),'r');
end
while ~feof(fid)
    t=fgetl(fid);
    if (t~="&")
        data1=fscanf(fid,'%f',[2 inf]); 
    end
end
data2=data1';
solidflux=0;k=0;
for j=1:size(data2,1)
    if ((25<data2(j,1))&&(data2(j,1)<35))
        k=k+1;
        solidflux=solidflux+data2(j,2);
    end
end
solidflux=solidflux/k;


