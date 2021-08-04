%% Read Test Data and Plot

%%  0 : Useful Data

f_opflow = 100;         %[Hz]
f_fp = 4;               %[Hz]
f_optitrack = 315;      %[Hz]
t_start_logger = 0.3;  %[sec]

%%  1 : Process Data from Logger

% extract information to be read
ppz_log_folder = 'logs_csv_logger/test_2021_06_28_opflow/';
log_name = '21_06_28__18_51_55';
ext = '.csv';

% read the file
log_opflow = csvread(strcat(ppz_log_folder,log_name,'_OPTICAL_FLOW',ext),1,0);
log_fp = csvread(strcat(ppz_log_folder,log_name,'_ROTORCRAFT_FP',ext),1,0);

% set start end for big log
start_log = 0.1;
end_log = 0.9;

% flip the order
log_opflow = flipud(log_opflow);
log_fp = flipud(log_fp);

% get lengths
n.opflow = size(log_opflow(:,1));
n.fp = size(log_fp(:,1));

% cut interval
log_opflow = log_opflow(round(start_log*n.opflow):round(end_log*n.opflow),:);
log_fp = log_fp(round(start_log*n.fp):round(end_log*n.fp),:);

% update lengths
n.opflow = size(log_opflow(:,1));
n.fp = size(log_fp(:,1));

% get index x axis
x.opflow = flipud(log_opflow(:,1));
x.fp = flipud(log_fp(:,1));

% adjust the x axis wrt frequency
t_opflow = n.opflow(1)/f_opflow;
x.opflow = linspace(t_start_logger,t_opflow+t_start_logger,n.opflow(1));

t_fp = n.fp(1)/f_fp;
x.fp = linspace(t_start_logger,t_fp+t_start_logger,n.fp(1));

% populate structure and interpolate to larger array
log_data.ground_distance = log_opflow(:,9);
log_data.distance_quality = log_opflow(:,10);
log_data.flow_x = log_opflow(:,4);
log_data.flow_y = log_opflow(:,5);

log_data.phi = log_fp(:,8)*0.0139882;
log_data.theta = log_fp(:,9)*0.0139882;
log_data.psi = log_fp(:,10)*0.0139882;
log_data.flight_time = log_fp(:,16);

%% 2 : Process Data Optitrack

% extract information to be read
opti_log_folder = 'logs_csv_optitrack/test_2021_06_28_opflow/';
name_1 = 'Take 2021-06-28 06.45.13 PM low middle up 3 times';            
name_2 = 'Take 2021-06-28 06.47.26 PM rotation messy';                  % discard 
name_3 = 'Take 2021-06-28 06.49.20 PM 4 times roll + 4 times pitch';     
name_4 = 'Take 2021-06-28 06.52.36 PM forward backward 3 times';         
name_5 = 'Take 2021-06-28 06.54.17 PM right left 3 times';               

body_frame = {'testbed'};
frame_def = 'ForwardLeftUp';

data = optitrack_import(strcat(opti_log_folder, name_5), body_frame, frame_def);

% extract positions and rotations
time_vel = data.time(2:data.Nframes-1);
time = data.time;
rotation_x = data.CSVdata(:,2);
rotation_y = data.CSVdata(:,3);
rotation_z = data.CSVdata(:,4);
rotation_w = data.CSVdata(:,5);
position_x = data.CSVdata(:,6);
position_y = data.CSVdata(:,7);
position_z = data.CSVdata(:,8);

%% 5 : get velocity given flow and height

% value is in deg/sec therefore does not need to be integrated
log_data.velocity_x = log_data.ground_distance .* tan(deg2rad(log_data.flow_x));
log_data.velocity_y = log_data.ground_distance .* tan(deg2rad(log_data.flow_y));

% optitrack gives position, it is required to integrate over time
velocity_of_x = zeros(1,size(position_x,1));
velocity_of_y = zeros(1,size(position_y,1));

for i = 1:size(position_x,1)-1
    vx = (position_x(i+1) - position_x(i))*f_optitrack;
    vy = (position_y(i+1) - position_y(i))*f_optitrack;
    if abs(vx) > 0.5 
        velocity_of_x(i) = 0;
    else
        velocity_of_x(i) = vx;
    end
    
    if abs(vy) > 3 
        velocity_of_y(i) = 0;
    else
        velocity_of_y(i) = vy;
    end
end

%% 4 : plot the data

% ot center has an offset in z of the sensor
z_offset = 0.02;

% plot optitrack height
figure_1 = figure('Renderer', 'painters', 'Position', [100 200 1400 500]);
set(figure_1,'defaulttextinterpreter','latex');
subplot(2,1,1);
plot(x.opflow, log_data.velocity_x); hold on;
plot(time, velocity_of_x);
legend('matek','optitrack');
title("Test 4 | Forward Backward | No Rotation | Textured Plastic Surface");
xlabel("Time [sec]");
ylabel("Flow X [deg/sec]");
subplot(2,1,2);
plot(x.opflow, log_data.velocity_y); hold on;
plot(time, velocity_of_y);
xlabel("Time [sec]");
ylabel("Flow Y [deg/sec]");










