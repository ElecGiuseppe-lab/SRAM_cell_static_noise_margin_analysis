% Calcolo Margini di rumore di una cella SRAM in fase di 'hold' al variare di Vdd

clc
close all
clear all

Hold_DVR_approx;

% Setup the Import Options
opts1 = delimitedTextImportOptions("NumVariables", 4);
opts2 = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts1.DataLines = [3, 10002];
opts1.Delimiter = "\t";
opts2.DataLines = [10006, 20005];
opts2.Delimiter = "\t";

% Specify column names and types
opts1.VariableNames = ["col1", "col2", "col3", "col4"];
opts1.VariableTypes = ["double", "double", "double", "double"];
opts1.ExtraColumnsRule = "ignore";
opts1.EmptyLineRule = "read";
opts2.VariableNames = ["col1", "col2", "col3", "col4"];
opts2.VariableTypes = ["double", "double", "double", "double"];
opts2.ExtraColumnsRule = "ignore";
opts2.EmptyLineRule = "read";

Vdd = [0.16:0.02:0.44]';
Vdd_approx = [0.15:0.05:0.45]';

%import max_value butterfly curve
[name1,path1]=uigetfile('*txt','Seleziona i file DVR', 'MultiSelect','on');
cd(path1);
file1=name1; 
for i=1:numel(file1)
    data1= readmatrix(file1{i}, opts1);
    max_value(:,i) = data1(:,2)*10^3;
end

%import min_value butterfly curve
[name2,path2]=uigetfile('*txt','Seleziona i file DVR', 'MultiSelect','on');
cd(path2);
file2=name2; 
for i=1:numel(file1)
    data2= readmatrix(file1{i}, opts2);
    min_value(:,i) = abs(data2(:,2))*10^3;
end


for i=1:numel(file1)
    hold_SNM(:,i) = min(min_value(:,i),max_value(:,i));
end

for i=1:numel(Vdd)
    count1 = 0;
    for j=1:10000
        if(hold_SNM(j,i)<60)
            count1 = count1 +1;
        end
    end
    count2(1,i) = count1;
end

count3 = zeros(size(count2));
count3(1,end) = count2(1,end);
for i=1:numel(Vdd)-1
    count3(1,end-i) = count2(1,end-i)-count2(1,end-i+1);
end

figure
subplot(1,2,1)
curve_fit= fit(Vdd_approx*10^3,count4','gauss2');
bar(Vdd_approx*10^3,count4);
hold on
p = plot(curve_fit);
set(p,'lineWidth',1.5);
xlabel('DVR [mV]');
ylabel('Occurrences');
legend('hide')

subplot(1,2,2)
curve_fit= fit(Vdd*10^3,count3','gauss2');
bar(Vdd*10^3,count3);
hold on
p = plot(curve_fit);
set(p,'lineWidth',1.5);
xlabel('DVR [mV]');
ylabel('Occurrences');
legend('hide')

