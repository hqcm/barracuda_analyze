%ʱ��+�߶�ƽ�������϶�ʷֲ�%
%��ʵ������Ŀ�϶�������и߶�ƽ��%
clear;clc;
rho_s=930;rho_g=1.1795;g=9.81;
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
    if contains(tline, 'av_dpdy')
       colnumber=10*str2double(tline(2))+str2double(tline(3));  %�õ�����ѹ�����ڵ�����
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
axialvoidage=zeros(12,2);voidage=[0.6925 1.6497 2.7088 3.4012 3.7678 4.3177 5.0713 5.7230 6.6191 7.5967 8.7373 9.7963];
for i=1:size(data,1)
    if (data(i,2)>0.09||data(i,4)>0.09)
        data(i,:)=0;
    end
end
data(all(data==0,2),:)=[];
sortdata=sortrows(data,3);
a=sortdata(:,[1,3]);
b=unique(a(:,2));
c=zeros(size(b,1),2);
j=1;m=0;e1=1.0e-3;
for i=1:size(a,1)
    if (abs(a(i,2)-b(j))<e1)
        c(j,:)=c(j,:)+a(i,:);
    else
        c(j,:)=c(j,:)/m;
        j=j+1;m=0;
        c(j,:)=c(j,:)+a(i,:);
    end
    m=m+1;
    if (i==size(a,1))
        c(j,:)=c(j,:)/m;
    end
end
c(all(c==0,2),:)=[];
j=1;m=0;e2=1.0e-2;n=100;
for i=1:size(c,1)
    if (abs(n-voidage(j))>e2)
        axialvoidage(j,:)=axialvoidage(j,:)+c(i,:);
    else
        axialvoidage(j,:)=axialvoidage(j,:)/m;
        j=j+1;m=0;
    end
    if (j==13)
        break;
    end
    m=m+1;n=axialvoidage(j,2)/m;
end
for i=1:12
    axialvoidage(i,1)=min(1,(rho_s+axialvoidage(i,1)/g)/(rho_s-rho_g));
end
%�������ASCII�ķ�ʽ����Ϊtxt�ļ�%
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %�ַ�������
save(char(str), 'axialvoidage','-ascii');  %ע��save�����ĸ�ʽ
fclose all;