%��������%
clear;clc;
rho_s=2650;
[filename,pathname]=uigetfile('*.*','ѡ�������ļ�');
if (isequal(filename,0)||isequal(filename,0))
    disp('��ȡ���˲��������˳�')
    return
else
    fid=fopen(fullfile(pathname, filename),'r');
end
fidout=fopen('tempfile.txt','w');  %������ʱ�ļ��洢��һ������;'w':д�루�ļ��������ڣ��Զ�������
%��ȡ����%
while ~feof(fid)                                  % �ж��Ƿ�Ϊ�ļ�ĩβ
    tline=fgetl(fid);                                 % ���ļ�����
    if contains(tline, 'cellVol')
        cellVol=str2double(tline(2));  %�õ�����ѹ�����ڵ�����
    elseif contains(tline, 'av_pVolF')
        av_pVolF=10*str2double(tline(2))+str2double(tline(3));  %�õ������¶����ڵ�����
    elseif contains(tline, 'avP_zVel')
        avP_zVel=10*str2double(tline(2))+str2double(tline(3));  %�õ������¶����ڵ�����
    end
    if isspace(tline(1))     % �ж����ַ��Ƿ��ǿո񣨴���Ϊ�����У�
        fprintf(fidout,'%s\n\n',tline);                  % ����������У��Ѵ�������д����ʱ�ļ�
        data1=fscanf(fid,'%f',[Tcolnumber inf]);  %��ȡ���ݣ���ȡ��˳���ǰ��ж�ȡ���洢��ʱ���ǰ��д洢
        break
    else
        Tcolnumber=10*str2double(tline(2))+str2double(tline(3));  %�õ�����������
    end
end
line1=importdata('tempfile.txt');
fclose(fidout);  %ע����ɾ���ļ�ǰҪ�ȹرմ��ļ�
delete tempfile.txt;  %ɾ��������ʱ�ļ�
data2=[line1;data1'];
data=data2(:,[2 4 cellVol av_pVolF avP_zVel Tcolnumber]);  %��ȡ������
solidflux=0;area=0;
for i=1:size(data,1)
    if (data(i,2)==469&&(data(i,1)<=7))
        solidflux=solidflux+data(i,3)*data(i,4)*data(i,5);
        area=area+data(i,3);
    end
end
solidflux=rho_s*solidflux/area;
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %�ַ�������
save(char(str), 'solidflux','-ascii');  %ע��save�����ĸ�ʽ
fclose all;