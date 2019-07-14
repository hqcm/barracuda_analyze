%ʱ��+�߶�ƽ�������϶�ʷֲ�%
clear;clc;
rho_s=2650;g=9.81;R=8.314;M=18/1000;
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
        P=str2double(tline(2));  %�õ�����ѹ�����ڵ�����
    elseif contains(tline, 'f-Temp')
        T=10*str2double(tline(2))+str2double(tline(3));  %�õ������¶����ڵ�����
    elseif contains(tline, 'av_dpdz')
        av_dpdz=10*str2double(tline(2))+str2double(tline(3));  %�õ�����ѹ�����ڵ�����
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
data=data2(:,[2 P T av_dpdz Tcolnumber]);  %��ȡ������
for i=1:size(data,1)
    if (data(i,1)>7)
        data(i,:)=0;
    end
end
data(all(data==0,2),:)=[];
rho_g=data(:,2)./data(:,3)*M/R;
data(:,1)=min(1,(rho_s+data(:,4)/g)./(rho_s-rho_g));
sortdata=sortrows(data,5);
a=sortdata(:,[1 5]);
a(:,2)=a(:,2)-a(1,2);
surpassnumber=size(a,1)-mod(size(a,1) ,1000);%���1000��������
a=a(1:surpassnumber,:);
a=mat2cell(a,1000*ones(1,size(a,1)/1000),2);%������ָ�ΪԪ�����ڶ�����������еķָ���������������еķָ�
a = cellfun(@mean, a,'UniformOutput',false);%�����ص�ֵ���ܴ���������ʱ�����԰�Ԫ���������ʽ���أ���ʱҪ����'UniformOutput',false
axialvoidage=cell2mat(a);%��Ԫ����ԭΪ����
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %�ַ�������
save(char(str), 'axialvoidage','-ascii');  %ע��save�����ĸ�ʽ
fclose all;