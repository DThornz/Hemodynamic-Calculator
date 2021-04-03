%{
    Asad Mirza
    PhD Candidate, Florida International University
    CV-PEUTICS Laboratory, https://cvpeutics.fiu.edu/
    4/01/2021
    
    Code to import Fluent ASCII data and calculate the TAWSS and OSI.
    
    Assumes that each time point file is formatted as such:
    Row: Nodes
    Columns: Variables

    The necessary inputs per line are:
    
    (Node Number, X, Y, Z, Wall Shear Stress Magnitude, Wall Shear X, Wall Shear Y, Wall Shear Z)

    Example data shown in folders titled
    "0 OSI Data - ASCII Text"
    and
    "0.5 OSI Data - ASCII Text"

    Contact Info:
    amirz013@fiu.edu
    amirza.dev
%}
clear;clc;close all
%% Set Parameters
% You must change these values to match your data set
% Simulation start/end and time step
% tend/dt should equal the number of time steps or files you have loaded
prompt = {'Simulation Start (s):','Simulation End (s):','Time Step (s):','Cycle Period (s):'};
dlgtitle = 'Simulation Parameters';
dims = [1 35];
definput = {'0','1','0.01','1'};
answer = inputdlg(prompt,dlgtitle,[1, length(dlgtitle)+25],definput);
tstart=str2double(answer{1}); % Time of simulation start, 0 by default
tend=str2double(answer{2}); % Time of simulation end, 1 by default
dt=str2double(answer{3}); % Time step used in simulation, example is 0.00625 s
Tc=str2double(answer{4}); % Cycle period used in simulation, in seconds

% Set plotting parameters
% If both are set to true then a subplot is used
answer = questdlg('What would you like to plot?', ...
	'Plotting Parameters', ...
	'TAWSS','OSI','TAWSS and OSI','TAWSS and OSI');
% Handle responses
switch answer
    case 'TAWSS'
        TAWSS_plot=true;
        OSI_plot=false;
    case 'OSI'
        TAWSS_plot=false;
        OSI_plot=true;
    case 'TAWSS and OSI'
        TAWSS_plot=true;
        OSI_plot=true;
end

%% Load Data
% Access folder with data
try
    selected_files=uipickfiles;
catch
    folder=uigetdir;
    files_in_folder=dir(fullfile(folder, '*.*'));
%     selected_files=cell(length(files_in_folder),1);
    for ii=1:length(files_in_folder)
        if files_in_folder(ii).bytes<1
            data_to_remove(ii)=ii;
        else
            temp=[files_in_folder(ii).folder '\' files_in_folder(ii).name];
            selected_files{ii,1}=temp;
        end
    end
    selected_files(data_to_remove,:)=[];
end
% Sort files just in case
selected_files=sort(selected_files);
% Check if any files are selected
if isempty(selected_files)
    error('No files selected.')
end
% Number of files selected
num_files=length(selected_files);
% Do a check if the length of the time vector matches the number of files
if tend/dt~=num_files
    fprintf('Number of time steps doesn''t match number of files. \nCode might not work properly. Check again.\n')
end
% Separate counter for loop later
time_point_counter=1;
% Initial read of a file to figure out preallocation values needed
temp=importdata(selected_files{5});
temp=temp.data;
[node_num, var_num]=size(temp);
data=zeros(node_num,var_num,num_files);
% Loop through all files and load into a 3D matrix, if loading fails then
% just continue to next loop
for ii=1:num_files
    try
        fprintf('File %3.0f out of %3.0f imported.\n',ii,num_files)
        data_temp=importdata(selected_files{ii});
        data_temp=data_temp.data;
        data(:,:,time_point_counter)=data_temp;
        time_point_counter=time_point_counter+1;
    catch
        continue
    end
end
%% Calculate TAWSS and OSI
% Pre-allocate variables
TAWSS=zeros(node_num,1);
OSI=zeros(node_num,1);
TAWSS_Mag=zeros(num_files,1);
TAWSS_X=zeros(num_files,1);
TAWSS_Y=zeros(num_files,1);
TAWSS_Z=zeros(num_files,1);

t=tstart+dt:dt:tend; % Create vector of time data

time_point_counter=1;

% Loop through each node and calculate the TAWSS and OSI for it
% Repeat this for all nodes
for jj=1:node_num % All nodes
      fprintf('Node %3.0f out of %3.0f processed.\n',jj,node_num)
    for ii=1:num_files % All timesteps
        try
            % Grab the variable values temporarily
            TAWSS_Mag_temp=data(jj,5,ii);
            TAWSS_X_temp=data(jj,6,ii);
            TAWSS_Y_temp=data(jj,7,ii);
            TAWSS_Z_temp=data(jj,8,ii);
            
            % Add values to separate variable for later, each position is a
            % different point in time.
            TAWSS_Mag(time_point_counter)=TAWSS_Mag_temp;
            TAWSS_X(time_point_counter)=TAWSS_X_temp;
            TAWSS_Y(time_point_counter)=TAWSS_Y_temp;
            TAWSS_Z(time_point_counter)=TAWSS_Z_temp;
            
            % Add 1 to the counter, increasing for each time step
            time_point_counter=time_point_counter+1;
        catch
            % If you can't parse the data just continue to the next loop
            continue
        end
        
    end
    % Calcualte TAWSS using the trapz function to approximate the integral
    TAWSS(jj)=(1/Tc)*trapz(t,TAWSS_Mag);
    % Calcualte OSI using the trapz function to approximate the integral
    top=abs(trapz(t,TAWSS_X+TAWSS_Y+TAWSS_Z));
    bot=TAWSS(jj);
    OSI(jj)=(1/tend)*0.5*(1-top/bot);
    
    % Reset the TAWSS parsed variables for next node
    TAWSS_Mag=zeros(num_files,1);
    TAWSS_X=zeros(num_files,1);
    TAWSS_Y=zeros(num_files,1);
    TAWSS_Z=zeros(num_files,1);
    
    % Reset counter for next node
    time_point_counter=1;
end
% delete(f)
%% Plotting TAWSS
% Assuming locations are in m, multiple by 1000 to convert to mm
X=1000*data(:,2,1);
Y=1000*data(:,3,1);
Z=1000*data(:,4,1);
% Assuming TAWSS is in Pa, multiple by 10 to convert to dynes/cm^2
C=TAWSS*10;

if TAWSS_plot
    % Plot using scatter3
    if TAWSS_plot==OSI_plot
        subplot(1,2,1)
    end
    scatter3(X,Y,Z,20,C,'filled')
    colormap(jet(1024));
    cb=colorbar;
    cb.Color='w';
    cb.Label.String='TAWSS (dynes/cm^{2})';
    cb.FontWeight='bold';
    cb.FontSize=15;
    caxis([min(C) max(C)])
    
    xlabel('X (mm)');
    ylabel('Y (mm)');
    zlabel('Z (mm)');
    grid off
    
    a=gca;
    a.FontWeight='bold';
    a.FontSize=15;
    a.Color='none';
    a.XColor='w';
    a.YColor='w';
    a.ZColor='w';
    
    g=gcf;
    g.Color='k';
    axis equal
end

%% Plotting OSI
% X Y and Z position data
% Assuming locations are in m, multiple by 1000 to convert to mm
X=1000*data(:,2,1);
Y=1000*data(:,3,1);
Z=1000*data(:,4,1);
C=OSI;

if OSI_plot
    % Plot using scatter3
    if TAWSS_plot==OSI_plot
        subplot(1,2,2)
    end
    scatter3(X,Y,Z,20,C,'filled')
    
    colormap(jet(1024));
    cb=colorbar;
    cb.Color='w';
    cb.Label.String='OSI';
    cb.FontWeight='bold';
    cb.FontSize=15;
    caxis([0 0.5])
    
    xlabel('X (mm)');
    ylabel('Y (mm)');
    zlabel('Z (mm)');
    grid off
    
    a=gca;
    a.FontWeight='bold';
    a.FontSize=15;
    a.Color='none';
    a.XColor='w';
    a.YColor='w';
    a.ZColor='w';
    
    g=gcf;
    g.Color='k';
    axis equal
end