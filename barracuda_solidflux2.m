%ʱ��������������%
%ֱ�Ӷ�����������ƽ��%
clear;clc
[filename,pathname]=uigetfile('*.*','ѡ�������ļ�');
if (isequal(filename,0)||isequal(filename,0))
    disp('��ȡ���˲��������˳�')
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


