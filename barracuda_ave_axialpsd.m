%����ֱ���ش��ߵķֲ�%
clear;clc;
h=0.35:0.35:10.5;
axialpsd=zeros(length(h),2);  %��10.5m����Ϊ30�Σ�ÿ���������ľ�ֵ�Լ���Ӧ��λ�þ�ֵ������ͼ
%��ȡ�ļ�%
my_dir=uigetdir('ѡ���ļ���');  %�ļ��е�·��
files=dir(my_dir);
Lengthfiles=length(files);  %�ļ������ļ��ĸ���
prompt={'��������λ�ļ���������λ����:','�����벽��:'};
input=str2double(inputdlg(prompt));
for i=0:Lengthfiles-3
    name=input(2)+i*input(3);  %��ʼʱ���ʱ�䲽��
    openfilename=sprintf('%s%s%d',my_dir,'\zh',name);  %�õ��ļ���
    fid=fopen(openfilename,'r');  %���ļ�
    fidout=fopen('tempfile.txt','w');  %������ʱ�ļ��洢��һ������;'w':д�루�ļ��������ڣ��Զ�������
    %��ȡ����%
    while ~feof(fid)                                  % �ж��Ƿ�Ϊ�ļ�ĩβ
        tline=fgetl(fid);                                 % ���ļ�����
        %�õ������뾶���ڵ�����%
        if contains(tline, 'rad')
            if isspace(tline(3))
                colnumber=str2double(tline(2));  %����Ϊ1λ
            else
                colnumber=10*str2double(tline(2))+str2double(tline(3));  %����Ϊ2λ
            end
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
    for j=1:size(data,1)
        if (data(j,2)>0.09||data(j,4)>0.09)
            data(j,:)=0;
        end
    end
    data(all(data==0,2),:)=[];
    sortdata=sortrows(data,3);
    a=sortdata(:,[1,3]);
    j=1;m=0;psd=zeros(length(h),2);  %ע��psd�ĸ�ֵλ�ã���Ҫ���ڵ�һ��ѭ��������
    for k=1:size(a,1) %��������߶ȵķֶ�����������ƽ�����Լ���������
        if (a(k,2)<=h(j))
            psd(j,:)=psd(j,:)+a(k,:);
        else
            psd(j,:)=psd(j,:)/m;
            j=j+1;m=0;
            psd(j,:)=psd(j,:)+a(k,:);
        end
        m=m+1;
        if (k==size(a,1))
            psd(j,:)= psd(j,:)/m;
        end
    end
    axialpsd=axialpsd+psd;
end
axialpsd=axialpsd/(Lengthfiles-2);
%�������ASCII�ķ�ʽ����Ϊtxt�ļ�%
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %�ַ�������
save(char(str), 'axialpsd','-ascii');  %ע��save�����ĸ�ʽ
fclose all;
