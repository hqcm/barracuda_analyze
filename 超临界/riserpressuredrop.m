%������ѹ��%
clear;clc;
e=1.0e-4;
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
    if contains(tline, 'Pressure')
        Pressure=str2double(tline(2));  %�õ���϶�����ڵ�����
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
data=data2(:,[2 Pressure Tcolnumber]);  %��ȡ������
data(:,3)=data(:,3)-(-0.102081);  %��z����ʼ����Ϊ0��
x_t=2.4974;x_b=0.0026;%�趨�����ܵ���͵����ߵ�
p_b=0;p_t=0;n_b=0;n_t=0;
for i=1:size(data,1)
    if data(i,1)<7
        if abs(data(i,3)-x_b)<e
            p_b=p_b+data(i,2);
            n_b=n_b+1;
        elseif abs(data(i,3)-x_t)<e
            p_t=p_t+data(i,2);
            n_t=n_t+1;
        end
    end
end
pressuredrop=p_b/n_b-p_t/n_t;
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %�ַ�������
save(char(str), 'pressuredrop','-ascii');  %ע��save�����ĸ�ʽ
