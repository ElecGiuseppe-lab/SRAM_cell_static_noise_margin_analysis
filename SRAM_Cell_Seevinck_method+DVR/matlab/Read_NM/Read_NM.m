% Calcolo Margini di rumore di una cella SRAM in fase di 'read' al variare
% di Vdd tenendo conto delle variazioni di processo che inficiano sulla Vth

clc
close all
clear all

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

Vdd = [0.6 0.7 0.8 0.9 1];

%import max_value butterfly curve
[name1,path1]=uigetfile('*txt','Seleziona i file', 'MultiSelect','on');
cd(path1);
file1=name1; 
for i=1:numel(file1)
    data1= readmatrix(file1{i}, opts1);
    max_value(:,i) = data1(:,2)*10^3;
end

%import min_value butterfly curve
[name2,path2]=uigetfile('*txt','Seleziona i file', 'MultiSelect','on');
cd(path2);
file2=name2; 
for i=1:numel(file1)
    data2= readmatrix(file1{i}, opts2);
    min_value(:,i) = abs(data2(:,2))*10^3;
end

% Read SNM al variare di Vdd tenendo conto delle variazioni di processo
for i=1:numel(file1)
    read_NM(:,i) = min(min_value(:,i),max_value(:,i));
end

% media
mean_NM_read = mean(read_NM);

% deviazione standard
std_SNM = std(read_NM);

% sweep SNM
for i=1:numel(file1)
    range_RNM(:,i) = linspace(min(read_NM(:,i)),max(read_NM(:,i)),180);
end

% Distribuzione di probabilità SNM
for i=1:numel(file1)
    for k=1:length(range_RNM)-1
        count1 = 0;
        for j=1:length(read_NM)
            if(read_NM(j,i) >= range_RNM(k,i) && read_NM(j,i) <= range_RNM(k+1,i))
                count1 = count1 + 1;
            end
        end
        count2(k,i) = count1;
    end
end

figure
for i=1:numel(file1)
    subplot(3,2,i)
    curve_fit= fit(range_RNM(1:end-1,i),count2(:,i),'gauss1');
    bar(range_RNM(1:end-1,i),count2(:,i));
    hold on
    p = plot(curve_fit);
    set(p,'lineWidth',1.5);
    xlabel('Read NM [mV]');
    ylabel('Occurrences');
    legend('hide')
    set(title(sprintf('Vdd = %.1f [V]',Vdd(i))));
end

save('Mean_NM_read.mat','mean_NM_read');
