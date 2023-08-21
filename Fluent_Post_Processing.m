%{
    Asad Mirza
    PhD Candidate, Florida International University
    CV-PEUTICS Laboratory, https://cvpeutics.fiu.edu/
    4/10/2021
    
    Code to import Fluent ASCII data and calculate TAWSS, OSI, RRT, and transWSS.
    
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
list = {'TAWSS','OSI','RRT',...                   
'transWSS'};
[indx,tf] = listdlg('Name','Plotting Parameters','PromptString',{'What would you like to plot?','Hold CTRL/Command for multi-select'},'ListString',list,'ListSize',[250 80]);
% Handle responses
TAWSS_plot=false;
OSI_plot=false;
RRT_plot=false;
transWSS_plot=false;
if isempty(indx)
    warndlg('No data selected for plotting, values will still be calculated but not shown.','Warning');
else
    for ii=1:length(indx)
        if indx(ii)==1
            TAWSS_plot=true;
        elseif indx(ii)==2
            OSI_plot=true;
        elseif indx(ii)==3
            RRT_plot=true;
        else 
            transWSS_plot=true;
        end
    end
end
%% Load Data
% Access folder with data
try
    selected_files=uipickfiles;
catch
    folder=uigetdir;
    files_in_folder=dir(fullfile(folder, '*.*'));
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
if int16(tend/dt)~=int16(num_files)
    error('Number of time steps doesn''t match number of files. Check again.')
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

%% Extract Position Data
% Assuming locations are in m, multiple by 1000 to convert to mm
X=1000*data(:,2,1);
Y=1000*data(:,3,1);
Z=1000*data(:,4,1);
% Try calculating normals using MATLAB computer vision toolbox, otherwise
% use 3rd party script.
try
    ptCloud=pointCloud([X,Y,Z]);
    normals=pcnormals(ptCloud,6);
catch
    [normals,~]=findPointNormals([X,Y,Z],6);
end
%% Calculate TAWSS and OSI
% Pre-allocate variables
TAWSS=zeros(node_num,1);
OSI=zeros(node_num,1);
RRT=zeros(node_num,1);
transWSS=zeros(node_num,1);
WSS_Mag=zeros(num_files,1);
WSS_X=zeros(num_files,1);
WSS_Y=zeros(num_files,1);
WSS_Z=zeros(num_files,1);

t=tstart+dt:dt:tend; % Create vector of time data

time_point_counter=1;

% Loop through each node and calculate the TAWSS and OSI for it
% Repeat this for all nodes
for jj=1:node_num % All nodes
      fprintf('Node %3.0f out of %3.0f processed.\n',jj,node_num)
    for ii=1:num_files % All timesteps
        try
            % Grab the variable values temporarily
            WSS_Mag_temp=data(jj,5,ii);
            WSS_X_temp=data(jj,6,ii);
            WSS_Y_temp=data(jj,7,ii);
            WSS_Z_temp=data(jj,8,ii);
            
            % Add values to separate variable for later, each position is a
            % different point in time.
            WSS_Mag(time_point_counter)=WSS_Mag_temp;
            WSS_X(time_point_counter)=WSS_X_temp;
            WSS_Y(time_point_counter)=WSS_Y_temp;
            WSS_Z(time_point_counter)=WSS_Z_temp;
            
            % Add 1 to the counter, increasing for each time step
            time_point_counter=time_point_counter+1;
        catch
            % If you can't parse the data just continue to the next loop
            continue
        end
        
    end
    % Calculate TAWSS using the trapz function to approximate the integral
    TAWSS(jj)=(1/Tc)*trapz(t,WSS_Mag);
    % Calculate OSI using the trapz function to approximate the integral
    top=abs(trapz(t,WSS_X+WSS_Y+WSS_Z));
    bot=TAWSS(jj);
    OSI(jj)=0.5*(1-top/bot);
    % Calculate RRT using TAWSS and OSI
    RRT(jj)=1/(TAWSS(jj)*(1-2*OSI(jj)));
    % Calculate transWSS
    top=[trapz(t,WSS_X),trapz(t,WSS_Y),trapz(t,WSS_Z)]';
    bot=abs(trapz(t,WSS_X+WSS_Y+WSS_Z));
    inner=cross(normals(jj,:),top/bot);
    outer=dot([WSS_X,WSS_Y,WSS_Z],ones(num_files,3).*inner);
    transWSS(jj)=(1/Tc)*trapz(abs(outer));
    % Reset the WSS parsed variables for next node
    WSS_Mag=zeros(num_files,1);
    WSS_X=zeros(num_files,1);
    WSS_Y=zeros(num_files,1);
    WSS_Z=zeros(num_files,1);
    
    % Reset counter for next node
    time_point_counter=1;
end

%% Subplot Parameter
subplot_counter=1;

%% Plotting TAWSS
% Assuming TAWSS is in Pa, multiple by 10 to convert to dynes/cm^2
C=TAWSS*10;
% C2=remap(C,[min(C) max(C)],[0 5]);

if TAWSS_plot
    % Plot using scatter3
    if length(indx)>1
        subplot(1,length(indx),subplot_counter)
        subplot_counter=subplot_counter+1;
    end
    scatter3(X,Y,Z,20,C,'filled')
    colormap(jet(1024));
    cb=colorbar;
    cb.Color='w';
    cb.Label.String='TAWSS (dynes/cm^{2})';
    cb.FontWeight='bold';
    cb.FontSize=15;
    
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
C=OSI;
if OSI_plot
    % Plot using scatter3
    if length(indx)>1
        subplot(1,length(indx),subplot_counter)
        subplot_counter=subplot_counter+1;
    end
    scatter3(X,Y,Z,20,C+.05,'filled')
    
    colormap(jet(1024));
    cb=colorbar;
    cb.Color='w';
    cb.Label.String='OSI';
    cb.FontWeight='bold';
    cb.FontSize=15;
    caxis([0 0.5])
% caxis([0.15 0.25])
    
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

%% Plotting RRT
% Find if RRT has outliers due to very distrubed/stationary flow
RRT_Outlier_Found= sum(isoutlier(RRT,'mean'));
% If found log the data for better visuals, otherwise leave as normal units
% of (1/Pa)
if RRT_Outlier_Found>0
    C=log(RRT);
else
    C=RRT;
end

if RRT_plot
    % Plot using scatter3
    if length(indx)>1
        subplot(1,length(indx),subplot_counter)
        subplot_counter=subplot_counter+1;
    end
    scatter3(X,Y,Z,20,C,'filled')
    
    colormap(jet(1024));
    cb=colorbar;
    cb.Color='w';
    if RRT_Outlier_Found>0
        cb.Label.String='log(RRT (1/Pa))';
    else
        cb.Label.String='RRT (1/Pa)';
    end
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

%% Plotting transWSS
% Find if transWSS has outliers due to very distrubed/stationary flow
transWSS_Outlier_Found= sum(isoutlier(transWSS,'mean'));
% If found log the data for better visuals, otherwise leave as normal units
% of (dynes/cm^2)
if transWSS_Outlier_Found>0
    C=log(10*transWSS);
else
    C=transWSS*10;
end

if transWSS_plot
    % Plot using scatter3
    if length(indx)>1
        subplot(1,length(indx),subplot_counter)
        subplot_counter=subplot_counter+1;
    end
    scatter3(X,Y,Z,20,C,'filled')
    
    colormap(jet(1024));
    cb=colorbar;
    cb.Color='w';
    if transWSS_Outlier_Found>0
        cb.Label.String='log(transWSS (dynes/cm^{2}))';
    else
        cb.Label.String='transWSS (dynes/cm^{2})';
    end
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
