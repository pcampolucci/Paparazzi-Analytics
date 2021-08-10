%% Read Test Data and Plot

% NOTES

% optical flow peaks are not filtered by quality
% the use of the sin gives better results and delivers better peaks
% the compensated agl works better

%%  0 : Control Panel and Initial Settings

% choose which pictures to show
show_full = false;
show_ekf = false;

% timestamps and frequencies of signals
t_mag = 0.2;
t_fp = 0.05;
t_ekf = 0.1;

f_mag = 1/t_mag;
f_fp = 1/t_fp;
f_ekf = 1/t_ekf;

t_start_logger = 0;

% set start end for log
start_log = 0.07;
end_log = 0.99;

%%  1 : Process Data from Logger

% extract information to be read
ppz_log_folder = 'logs_csv_logger/ekf_test_pc/';
log_name_1 = '21_08_08__21_09_54_SD_no_GPS';
log_name_2 = '21_08_08__21_10_27_SD_no_GPS';
log_name_3 = '21_08_08__21_10_50_SD_no_GPS';
log_telem = '21_07_30__19_15_20';
log = log_telem;
ext = '.csv';

msg_mag = '_IMU_MAG_SCALED';
msg_fp = '_ROTORCRAFT_FP';
msg_ekf = '_INS_EKF2';

% [log_mag,n_mag,idx_mag] = extract_data(ppz_log_folder,log,msg_mag,ext,f_mag,start_log,end_log);

[log_fp,n_fp,idx_fp] = extract_data(ppz_log_folder,log,msg_fp,ext,f_fp,start_log,end_log);

[log_ekf,n_ekf,idx_ekf] = extract_data(ppz_log_folder,log,msg_ekf,ext,f_ekf,start_log,end_log);



%% get data from optitrack

body_name = '';
frame_def = 'ForwardLeftUp';
name_1 = 'logs_csv_optitrack/Take 2021-08-06 05.49.41 PM - yes flow';
name_2 = 'logs_csv_optitrack/Take 2021-08-06 05.51.52 PM - no flow';

package_ot = optitrack_import(name_1,body_name,frame_def);

data_ot = package_ot.CSVdata;

ot.dt = data_ot(:,1);
ot.rx = data_ot(:,2);
ot.ry = data_ot(:,3);
ot.rz = data_ot(:,4);
ot.rw = data_ot(:,5);
ot.x = data_ot(:,6);
ot.y = data_ot(:,7);
ot.z = data_ot(:,8);

%% 2 : Get all messages

% magnetometer
% data.mx = log_mag(:,2);
% data.my = log_mag(:,3);
% data.mz = log_mag(:,4);

% ekf statuses
status.control = log_ekf(:,2);
status.fault = log_ekf(:,3);
status.gps = log_ekf(:,4);
status.solution = log_ekf(:,5);
status.innov = log_ekf(:,6);

% ekf innovations
data.innov_mag = log_ekf(:,7);
data.innov_vel = log_ekf(:,8);
data.innov_pos = log_ekf(:,9);
data.innov_hgt = log_ekf(:,10);
data.innov_tas = log_ekf(:,11);
data.innov_hagl = log_ekf(:,12);
data.innov_flow = log_ekf(:,13);
data.innov_beta = log_ekf(:,14);
data.terrain_status = log_ekf(:,16);
data.dr = log_ekf(:,17);

% rotorcraft
data.pos_x = log_fp(:,2)*0.0039063;
data.pos_y = log_fp(:,3)*0.0039063;
data.pos_z = log_fp(:,4)*0.0039063;
data.vel_x = log_fp(:,5)*0.0000019;
data.vel_y = log_fp(:,6)*0.0000019;
data.vel_z = log_fp(:,7)*0.0000019;
data.phi = log_fp(:,8)*0.0139882;
data.theta = log_fp(:,9)*0.0139882;
data.psi = log_fp(:,10)*0.0139882;

%% Run the debugger for the status

done = status_interpreter(status);

%% 3 : Postprocess data

% % EKF GENERATED BODY VELOCITIES
% % transform NED frame for velocity to body frame
% vx_body = zeros(1,size(log_fp,1));
% vy_body = zeros(1,size(log_fp,1));
% 
% % interpolate magneto on gps 
% data.mx_resized = imresize(data.mx, size(data.vel_x));
% data.my_resized = imresize(data.my, size(data.vel_y));
% data.mz_resized = imresize(data.mz, size(data.vel_z));
% 
% % turn magnetometer data from adc to unit vector
% max_mag_x = abs(max(data.mx_resized));
% max_mag_y = abs(max(data.my_resized));
% max_mag_z = abs(max(data.mz_resized));
% max_all = max(max_mag_x, max(max_mag_y, max_mag_z)) + 10;
% data.mx_resized = data.mx_resized/max_all;
% data.my_resized = data.my_resized/max_all;
% 
% for i = 1:size(log_fp,1)-1
%     heading_i = acos(data.mx_resized(i));
%     T_Eb_i = [cos(heading_i) sin(heading_i) 0; 
%             -sin(heading_i) cos(heading_i) 0;
%             0 0 1];
%     V_E_i = [data.vel_x(i), data.vel_y(i), 0];
%     V_B_i = T_Eb_i * V_E_i.';
%     vx_body(i) = V_B_i(2);
%     vy_body(i) = V_B_i(1);
% end

%% 4 : plot the data

figure_ekf = figure('Visible', show_ekf);
set(figure_ekf,'defaulttextinterpreter','latex');
plot(n_ekf, data.innov_mag); hold on;
plot(n_ekf, data.innov_vel); hold on;
plot(n_ekf, data.innov_pos); hold on;
plot(n_ekf, data.innov_hgt); hold on;
plot(n_ekf, data.innov_tas); hold on;
plot(n_ekf, data.innov_hagl); hold on;
plot(n_ekf, data.innov_flow); hold on;
plot(n_ekf, data.innov_beta);
xlabel("Time [sec]");
ylabel("Flow [deg/sec]");

% plot velocity and magneto from Optitrack
figure_full = figure('Visible', show_full);
set(figure_full,'defaulttextinterpreter','latex');
subplot(4,1,1);
% plot(n_mag, data.mx); hold on;
% plot(n_mag, data.my); hold on;
% plot(n_mag, data.mz);
plot(ot.dt, ot.x); hold on;
plot(ot.dt, ot.y); hold on;
plot(ot.dt, ot.z);
legend("flow x", "flow y");
xlabel("Time [sec]");
ylabel("Flow [deg/sec]");
subplot(4,1,2);
% plot(n_fp, vx_body); hold on;
% plot(n_fp, vy_body);
plot(n_fp, data.vel_x); hold on;
plot(n_fp, data.vel_y); hold on;
plot(n_fp, data.vel_z);
xlabel("Time [sec]");
ylabel("Flow Quality [-]");
subplot(4,1,3);
plot(n_fp, data.pos_x); hold on;
plot(n_fp, data.pos_y); hold on;
plot(n_fp, data.pos_z);
xlabel("Time [sec]");
ylabel("Distance [m]");
subplot(4,1,4);
plot(n_fp, data.phi); hold on;
plot(n_fp, data.theta); hold on;
plot(n_fp, data.psi);
legend("gyro x", "gyro y");
xlabel("Time [sec]");
ylabel("Gyro [deg/sec]");




