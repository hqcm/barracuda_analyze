%���������ٶȷֲ�%
clear;clc;
e1=1.0e-2;e2=0.03;
prompt={'�����봲��߶ȣ���λΪm:'};
answer=inputdlg(prompt);
[filename,pathname]=uigetfile('*.*','ѡ�������ļ�');
height=str2double(answer);
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
    if contains(tline, 'avP_yVel')
       colnumber=10*str2double(tline(2))+str2double(tline(3));  %�õ���϶�����ڵ�����
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
data=data2(:,[colnumber Tcolnumber-2 Tcolnumber-1 Tcolnumber]);  %��ȡ������
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
data(all(data==0,2),:)=[];  %2��ʾ���ž���ĵڶ���ά�ȣ��У��ĵķ������ж�Ԫ���Ƿ���100
a0=sortrows(data,2);
a=a0(:,[2 1]);
b=uniquetol(a(:,1),e2);  %������СΪe2�������
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
%�������ASCII�ķ�ʽ����Ϊtxt�ļ�%
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %�ַ�������
save(char(str), 'radialvelocity','-ascii');  %ע��save�����ĸ�ʽ
fclose all;
