%��������%
clear;clc;
%��ȡ�ļ�%
[filename,pathname]=uigetfile('*.*','ѡ�������ļ�');
if (isequal(filename,0)||isequal(filename,0))
    disp('��ȡ���˲��������˳�')
    return
else
    fid=fopen(fullfile(pathname, filename),'r');
end
%��ȡ����%
while ~feof(fid)                                  % �ж��Ƿ�Ϊ�ļ�ĩβ
    tline=fgetl(fid);                                 % ���ļ�����
    data=fscanf(fid,'%f',[2 inf]);  %��ȡ���ݣ���ȡ��˳���ǰ��ж�ȡ���洢��ʱ���ǰ��д洢
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
str=strcat(pathname,savefilename);  %�ַ�������
save(char(str), 'flux','-ascii');  %ע��save�����ĸ�ʽ
fclose all;
