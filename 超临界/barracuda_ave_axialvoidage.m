%ʱ��+�߶�ƽ�������϶�ʷֲ�%
clear;clc;
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
    if contains(tline, 'av_pVolF')
        av_pVolF=10*str2double(tline(2))+str2double(tline(3));  %�õ�����ѹ�����ڵ�����
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
data=data2(:,[2 av_pVolF Tcolnumber]);  %��ȡ������
for i=1:size(data,1)
    if (data(i,1)>7)
        data(i,:)=0;
    end
end
data(all(data==0,2),:)=[];
sortdata=sortrows(data,3);
a=sortdata(:,[2 3]);
a(:,1)=1-a(:,1);%�����϶��
a(:,2)=a(:,2)-a(1,2);%����ʼ����Ϊ0��
surpassnumber=size(a,1)-mod(size(a,1) ,1000);%���1000��������
a=a(1:surpassnumber,:);
a=mat2cell(a,1000*ones(1,size(a,1)/1000),2);%������ָ�ΪԪ�����ڶ�����������еķָ���������������еķָ�
a = cellfun(@mean, a,'UniformOutput',false);%�����ص�ֵ���ܴ���������ʱ�����԰�Ԫ���������ʽ���أ���ʱҪ����'UniformOutput',false
axialvoidage=cell2mat(a);%��Ԫ����ԭΪ����
[savefilename,pathname]=uiputfile('*.txt');
str=strcat(pathname,savefilename);  %�ַ�������
save(char(str), 'axialvoidage','-ascii');  %ע��save�����ĸ�ʽ
fclose all;