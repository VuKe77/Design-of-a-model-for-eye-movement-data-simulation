close all
clc
clear all


%% Izdvajanje putanja .mat fajlova
folder_path = 'D:\ETF nastava\VIII semsetar\Diplomski\Data\DATA_SAVE';

subfolders = genpath(folder_path);

% Napravi listu putanja 
subfolder_list = regexp(subfolders, pathsep, 'split');
subfolder_list = subfolder_list(2:end-1); %delete sufficient paths


mat_files = {};
% Prolazak kroz svaki fajl i izvlacenje .mat fajlova
for i = 1:length(subfolder_list)
    listing = dir(fullfile(subfolder_list{i}, '*.mat')); 
    for j = 1:length(listing)
        mat_files{i} = fullfile(subfolder_list{i}, listing(j).name);
    end
end
%% obrada .mat fajlova
save_path = "D:\ETF nastava\VIII semsetar\Diplomski\DATAFILTERED";

i=1;
Fs = 250;

for i =1:length(mat_files)
    save_file = fullfile(save_path,['subject' num2str(i,1)]);
    data1 = load(mat_files{i});
    data = data1.D_orig;
    t = data(:,1);
    t = (t-t(1))/250;
    x_data = data(:,2);
    y_data = data(:,3);
    valid_x = x_data<1920 & x_data>0;
    valid_y = y_data<1080 & y_data>0;
    valid = valid_x & valid_y;
    valid_idxs = find(valid==1);
    x_data = x_data(valid_idxs);
    y_data = y_data(valid_idxs);
    raw_data = [x_data  y_data];
    t = (0:1:length(raw_data)-1)/Fs;
    save(save_file, 'raw_data')
end


%% izdvajanje statistickih obelezja i sekvenci
DATA = detekcija_sakada(raw_data,t);
figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.peak_vals)
    xlabel('Amplituda[deg]')
    ylabel("Peak brzine[deg/s]")
    title("Glavna sekvenca")
figure
    scatter(DATA.SACC.amplitudes,DATA.SACC.durations)
    xlabel('Amplituda[deg]')
    ylabel("Trajanje sakade[s]")
    title("Glavna sekvenca")

