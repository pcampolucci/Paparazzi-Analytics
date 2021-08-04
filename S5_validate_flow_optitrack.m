%% Read Test Data and Plot

%%  0 : Useful Data

t_message = 0.05;           %[sec]
f_log = 1/t_message;        %[Hz]

%%  1 : Process Data from Logger

% extract information to be read
ppz_log_folder = 'logs_csv_logger/test_2021_07_31_opflow_w_optitrack/';
log_name_1 = '21_07_30__19_05_46';
log_name_2 = '21_07_30__19_09_12';
log_name_3 = '21_07_30__19_15_20';
ext = '.csv';

% read the file
log = csvread(strcat(ppz_log_folder,log_name_3,'_DEBUG',ext),1,0);

% set start end for big log
start_log = 0.72;
end_log = 0.8;

% flip the order
log = flipud(log);

% get lengths
n.length = size(log(:,1));

% cut interval
log = log(round(start_log*n.length):round(end_log*n.length),:);

% update lengths
n.length = size(log(:,1));

% get index x axis
x.log = flipud(log(:,1))/f_log;

% populate structure and interpolate to larger array
log_data.vel_x = log(:,2);
log_data.vel_y = log(:,3);
log_data.vel_z = log(:,4);
log_data.mag_x = log(:,5)/0.4;
log_data.mag_y = log(:,6)/0.4;
log_data.mag_z = log(:,7)/0.4;
log_data.rng = log(:,8)*0.001;
log_data.flow_x = -log(:,9)/t_message;
log_data.flow_y = -log(:,10)/t_message;
log_data.gyro_x = log(:,11)/t_message;
log_data.gyro_y = log(:,12)/t_message;
log_data.gyro_z = log(:,13)/t_message;
log_data.flow_x_comp = (-log(:,9) + log(:,11))/t_message;
log_data.flow_y_comp = (-log(:,10) + log(:,12))/t_message;

%% 3 : estimate flow sensor noise

% noisy interval for the x flow is 0.75 to 0.99
std_flow_x = std(log_data.flow_x);

%% 4 : plot the data

% ot center has an offset in z of the sensor
z_offset = 0.02;

% plot velocity and magneto from Optitrack
figure_1 = figure();
set(figure_1,'defaulttextinterpreter','latex');
subplot(6,2,1);
plot(x.log, log_data.vel_x);
title("Velocity and Magnetometer with Optitrack");
xlabel("Time [sec]");
ylabel("$V_x$ [m/sec]");
subplot(6,2,3);
plot(x.log, log_data.vel_y);
xlabel("Time [sec]");
ylabel("$V_y$ [m/sec]");
subplot(6,2,5);
plot(x.log, log_data.vel_z);
xlabel("Time [sec]");
ylabel("$V_z$ [m/sec]");
subplot(6,2,2);
plot(x.log, log_data.mag_x);
xlabel("Time [sec]");
ylabel("$M_x$");
subplot(6,2,4);
plot(x.log, log_data.mag_y);
xlabel("Time [sec]");
ylabel("$M_y$");
subplot(6,2,6);
plot(x.log, log_data.mag_z);
xlabel("Time [sec]");
ylabel("$M_z$");
subplot(6,2,7);
plot(x.log, log_data.rng);
title("Range, Flow and Gyro");
xlabel("Time [sec]");
ylabel("h [m]");
subplot(6,2,9);
plot(x.log, log_data.flow_x);
xlabel("Time [sec]");
ylabel("Flow X [rad/sec]");
subplot(6,2,11);
plot(x.log, log_data.flow_y);
xlabel("Time [sec]");
ylabel("Flow Y [rad/sec]");
subplot(6,2,8);
plot(x.log, log_data.gyro_x);
xlabel("Time [sec]");
ylabel("$Gyro X$ [rad/sec]");
subplot(6,2,10);
plot(x.log, log_data.gyro_y);
xlabel("Time [sec]");
ylabel("$Gyro Y$ [rad/sec]");
subplot(6,2,12);
plot(x.log, log_data.gyro_z);
xlabel("Time [sec]");
ylabel("$Gyro Z$ [rad/sec]");

% process data and extrapolate the body velocities

% OPTITRACK GENERATED BODY VELOCITIES
% transform NED frame for velocity to body frame
vx_body = zeros(1,size(log,1));
vy_body = zeros(1,size(log,1));

for i = 1:size(log,1)-1
    heading_i = acos(log_data.mag_x(i));
    T_Eb_i = [cos(heading_i) sin(heading_i) 0; 
            -sin(heading_i) cos(heading_i) 0;
            0 0 1];
    V_E_i = [log_data.vel_x(i), log_data.vel_y(i), log_data.vel_z(i)];
    V_B_i = T_Eb_i * V_E_i.';
    vx_body(i) = V_B_i(2);
    vy_body(i) = V_B_i(1);
end

% FLOW AND GYRO GENERATED BODY VELOCITIES
% use flowx and flowy with distance (from OT) for estimation
vx_body_flow = zeros(1,size(log,1));
vy_body_flow = zeros(1,size(log,1));

for i = 1:size(log,1)-1
    dx_i = log_data.rng(i) * tan(log_data.flow_x(i) + log_data.gyro_x(i));
    dy_i = log_data.rng(i) * tan(log_data.flow_y(i) + log_data.gyro_y(i));
    vx_body_flow(i) = dy_i;
    vy_body_flow(i) = dx_i;
end

figure_2 = figure();
set(figure_2,'defaulttextinterpreter','latex');
subplot(2,1,1);
plot(x.log, vx_body); hold on;
plot(x.log, vx_body_flow); hold on;
xline(30); hold on; xline(47);
axis([0 150 -2 2]);
legend('optitrack', 'optical flow');
title("Body Velocities");
xlabel("Time [sec]");
ylabel("V_x [m/sec]");
subplot(2,1,2);
plot(x.log, vy_body); hold on;
plot(x.log, vy_body_flow); hold on;
xline(30); hold on; xline(47);
axis([0 150 -2 2]);
xlabel("Time [sec]");
ylabel("V_y [m/sec]");








