

clc
close all
clear all

% Setup the Import Options
opts1 = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts1.DataLines = [3, inf];
opts1.Delimiter = "\t";

% Specify column names and types
opts1.VariableNames = ["col1", "col2", "col3", "col4"];
opts1.VariableTypes = ["double", "double", "double", "double"];
opts1.ExtraColumnsRule = "ignore";
opts1.EmptyLineRule = "read";

Vdd = [0.4 0.45 0.5 0.6 0.7 0.8 0.9 1];

%import current leakage
[name1,path1]=uigetfile('*txt','Seleziona i file I_leak', 'MultiSelect','on');
cd(path1);
file1=name1; 
for i=1:numel(file1)
    data1= readmatrix(file1{i}, opts1);
    I_leak(:,i) = abs(data1(:,2))*10^6;
end

% media I_leak
mean_Ileak = mean(I_leak);

% deviazione standard
std_Ileak = std(I_leak);

% sweep I_leak
for i=1:numel(file1)
    range_Ileak(:,i) = linspace(min(I_leak(:,i)),max(I_leak(:,i)),180);
end

% Distribuzione di probabilità I_leak
for i=1:numel(file1)
    for k=1:length(range_Ileak)-1
        count1 = 0;
        for j=1:length(I_leak)
            if(I_leak(j,i) >= range_Ileak(k,i) && I_leak(j,i) <= range_Ileak(k+1,i))
                count1 = count1 + 1;
            end
        end
        count2(k,i) = count1;
    end
end

figure(1)
for i=1:numel(file1)
    subplot(4,2,i)
    curve_fit= fit(range_Ileak(1:end-1,i),count2(:,i),'gauss1');
    bar(range_Ileak(1:end-1,i),count2(:,i));
    hold on
    p = plot(curve_fit);
    set(p,'lineWidth',1.5);
    set(xlabel('$I_{leak}$ $[{\mu}A]$'),'Interpreter','latex');
    ylabel('Occurrences');
    legend('hide')
    set(title(sprintf('Vdd = %.2f [V]',Vdd(i))));
end

% figure(2)
% plot(Vdd,mean_Ileak,'.-',MarkerSize=15);
% set(xlabel('$V_{dd}$ [$V$]'),'Interpreter','latex');
% set(ylabel('$I_{leak}$ [${\mu}A$]'),'Interpreter','latex');
