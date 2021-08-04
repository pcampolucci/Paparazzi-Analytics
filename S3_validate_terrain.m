%% Read Test Data and Plot

%%  0 : Useful Data

t_opflow = 0.01;
t_fp = 0.05;
t_gps = 0.1;

f_opflow = 1/t_opflow;
f_fp = 1/t_fp;
f_gps = 1/t_gps;

t_start_logger = 0;

%%  1 : Process Data from Logger

% extract information to be read
ppz_log_folder = 'logs_csv_logger/lidar_rotation_test/';
log_name_1 = 'test_1';
log_name_2 = '21_08_04__16_04_12_SD_no_GPS';
ext = '.csv';

% read the file
log_opflow = csvread(strcat(ppz_log_folder,log_name_2,'_OPTICAL_FLOW',ext),1,0);
log_fp = csvread(strcat(ppz_log_folder,log_name_2,'_ROTORCRAFT_FP',ext),1,0);
log_gps = csvread(strcat(ppz_log_folder,log_name_2,'_GPS_INT',ext),1,0);

% set start end for big log
start_log = 0.75;
end_log = 0.88;

% flip the order
log_opflow = flipud(log_opflow);
log_fp = flipud(log_fp);
log_gps = flipud(log_gps);

% get lengths
n.opflow = size(log_opflow(:,1));
n.fp = size(log_fp(:,1));
n.gps = size(log_gps(:,1));

% cut interval
log_opflow = log_opflow(round(start_log*n.opflow):round(end_log*n.opflow),:);
log_fp = log_fp(round(start_log*n.fp):round(end_log*n.fp),:);
log_gps = log_gps(round(start_log*n.gps):round(end_log*n.gps),:);

% update lengths
n.opflow = size(log_opflow(:,1));
n.fp = size(log_fp(:,1));
n.gps = size(log_gps(:,1));

% get index x axis
x.opflow = flipud(log_opflow(:,1));
x.fp = flipud(log_fp(:,1));
x.gps = flipud(log_gps(:,1));

% adjust the x axis wrt frequency
t_opflow = n.opflow(1)/f_opflow;
x.opflow = linspace(t_start_logger,t_opflow+t_start_logger,n.opflow(1));

t_fp = n.fp(1)/f_fp;
x.fp = linspace(t_start_logger,t_fp+t_start_logger,n.fp(1));

t_gps = n.gps(1)/f_gps;
x.gps = linspace(t_start_logger,t_gps+t_start_logger,n.gps(1));

% populate structure and interpolate to larger array
log_data.distance_raw = log_opflow(:,9);
log_data.distance_compensated = log_opflow(:,10);
log_data.distance_quality = log_opflow(:,11);

log_data.phi = log_fp(:,8)*0.0139882;
log_data.theta = log_fp(:,9)*0.0139882;
log_data.psi = log_fp(:,10)*0.0139882;

log_data.altitude = log_gps(:,8);

% filter -1 on raw altitude values
for i = 1:size(log_opflow,1)-1
    if log_data.distance_raw(i) == -1 || log_data.distance_raw(i) > 3000 
        log_data.distance_raw(i) = log_data.distance_raw(i-1);
    end
end

% bring size of gps message to optical flow size
log_data.altitude_resized = imresize(log_data.altitude, size(log_data.distance_raw));


%% 3 : plot the data

% ot center has an offset in z of the sensor
z_offset = 0.02;

% plot optitrack height
figure_1 = figure('Renderer', 'painters', 'Position', [100 200 1400 800]);
set(figure_1,'defaulttextinterpreter','latex');
subplot(3,1,1);
plot(x.opflow, log_data.distance_raw); hold on;
plot(x.opflow, log_data.distance_compensated); hold on;
plot(x.opflow, log_data.altitude_resized);
legend('uncompensated', 'compensated', 'optitrack');
xlabel("Time [sec]");
ylabel("AGL [m]");
title("AGL Estimation Improvement with Rotation Compensation and Filtering - Bad Surface");
subplot(3,1,2);
plot(x.fp, log_data.phi);
xlabel("Time [sec]");
ylabel("$\phi$ [deg]");
subplot(3,1,3);
plot(x.fp, log_data.theta);
xlabel("Time [sec]");
ylabel("$\theta$ [deg]");













