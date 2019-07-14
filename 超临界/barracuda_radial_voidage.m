%�����϶�ʷֲ�%
clear;clc;
e=1.0e-2;
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
    if contains(tline, 'av_pVolF')
        av_pVolF=10*str2double(tline(2))+str2double(tline(3));  %�õ���϶�����ڵ�����
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
data=data2(:,[2 av_pVolF Tcolnumber-2 Tcolnumber-1 Tcolnumber]);  %��ȡ������
data(:,3)=data(:,3)-0.16243221;  %��x����ʼ����Ϊ0��
data(:,4)=data(:,4)-(-1.634885);  %��y����ʼ����Ϊ0��
data(:,5)=data(:,5)-(-0.102081);  %��z����ʼ����Ϊ0��
for i=1:size(data,1)
    if (data(i,1)>7||abs(data(i,5)-height)>e)
        data(i,:)=0;
    end
end
data(all(data==0,2),:)=[];
x_center=0.0149;%i��1��6
y_center=0.0722853;%j��11��16
R=0.016063;%RxС��Ry��ȡRy��ΪR
data(:,3)=(data(:,3)-x_center)/R;
data(:,4)=(data(:,4)-y_center)/R;
for i=1:size(data,1)
    if data(i,3)>0
        data(i,1)=sqrt(data(i,3)^2+data(i,4)^2);
    else
        data(i,1)=-sqrt(data(i,3)^2+data(i,4)^2);
    end
end
data=data(:,1:2);
data=sortrows(data,1);
data(:,2)=1-data(:,2);%�����϶��
cof=10;%��������ϵ��
surpassnumber=size(data,1)-mod(size(data,1) ,cof);
data=data(1:surpassnumber,:);
data=mat2cell(data,cof*ones(1,size(data,1)/cof),2);%������ָ�ΪԪ�����ڶ�����������еķָ���������������еķָ�
data = cellfun(@mean, data,'UniformOutput',false);%�����ص�ֵ���ܴ���������ʱ�����԰�Ԫ���������ʽ���أ���ʱҪ����'UniformOutput',false
radialvoidage=cell2mat(data);%��Ԫ����ԭΪ����
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %�ַ�������
save(char(str), 'radialvoidage','-ascii');  %ע��save�����ĸ�ʽ
