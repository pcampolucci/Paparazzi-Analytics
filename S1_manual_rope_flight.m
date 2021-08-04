%% Read Test Data and Plot

%%  0 : Useful Data

f_cmd = 100;         %[Hz]
f_fp = 4;               %[Hz]
f_optitrack = 315;      %[Hz]
t_start_logger = 42.5;  %[sec]

%%  1 : Process Data from Logger

% extract information to be read
ppz_log_folder = 'logs_csv_logger/test_2021_06_25_landing_to/';
log_name = '21_06_25__13_30_45';
ext = '.csv';

% read the file
log_fp = csvread(strcat(ppz_log_folder,log_name,'_ROTORCRAFT_FP',ext),1,0);

% set start end for big log
start_log = 0.05;
end_log = 0.95;

% flip the order
log_fp = flipud(log_fp);

% get lengths
n.fp = size(log_fp(:,1));

% cut interval
log_fp = log_fp(round(start_log*n.fp):round(end_log*n.fp),:);

% update lengths
n.fp = size(log_fp(:,1));

% get index x axis
x.fp = flipud(log_fp(:,1));

% adjust the x axis wrt frequency
t_fp = n.fp(1)/f_fp;
x.fp = linspace(t_start_logger,t_fp+t_start_logger,n.fp(1));

% populate structure and interpolate to larger array
log_data.phi = log_fp(:,8)*0.0139882;
log_data.theta = log_fp(:,9)*0.0139882;
log_data.psi = log_fp(:,10)*0.0139882;
log_data.thrust = log_fp(:,15);

%% 3 : plot the data

% plot thrust and stuff
figure('Renderer', 'painters', 'Position', [100 200 1400 500])
subplot(4,1,1);
plot(x.fp, log_data.thrust);
title("Nederdrone Landing & Take Off Test");
xlabel("time [sec]");
ylabel("thrust [N]");
subplot(4,1,2);
plot(x.fp, log_data.phi);
xlabel("Time [sec]");
ylabel("phi [rad]");
subplot(4,1,3);
plot(x.fp, log_data.theta);
xlabel("Time [sec]");
ylabel("theta [rad]");
subplot(4,1,4);
plot(x.fp, log_data.psi);
xlabel("Time [sec]");
ylabel("psi [rad]");













