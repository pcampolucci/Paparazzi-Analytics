%% Read Test Data and Plot

%%  0 : Useful Data

t_flow = 0.05;
t_gps = 0.1;
t_gyro = 0.075;
t_mag = 0.2;

f_flow = 1/t_flow;
f_gps = 1/t_gps;
f_gyro = 1/t_gyro;
f_mag = 1/t_mag;

t_start_logger = 0;

%%  1 : Process Data from Logger

% extract information to be read
ppz_log_folder = 'logs_csv_logger/optical_flow_test/';
log_name_1 = '21_08_04__22_10_51_SD_no_GPS';
ext = '.csv';

% read the file
log_flow = csvread(strcat(ppz_log_folder,log_name_1,'_OPTICAL_FLOW',ext),1,0);
log_gps = csvread(strcat(ppz_log_folder,log_name_1,'_GPS_INT',ext),1,0);
log_gyro = csvread(strcat(ppz_log_folder,log_name_1,'_IMU_GYRO_SCALED',ext),1,0);
log_mag = csvread(strcat(ppz_log_folder,log_name_1,'_IMU_MAG_RAW',ext),1,0);

% set start end for big log
start_log = 0.01;
end_log = 0.55;

% flip the order
log_flow = flipud(log_flow);
log_gps = flipud(log_gps);
log_gyro = flipud(log_gyro);
log_mag = flipud(log_mag);

% get lengths
n.flow = size(log_flow(:,1));
n.gps = size(log_gps(:,1));
n.gyro = size(log_gyro(:,1));
n.mag = size(log_mag(:,1));

% cut interval
log_flow = log_flow(round(start_log*n.flow):round(end_log*n.flow),:);
log_gps = log_gps(round(start_log*n.gps):round(end_log*n.gps),:);
log_gyro = log_gyro(round(start_log*n.gyro):round(end_log*n.gyro),:);
log_mag = log_mag(round(start_log*n.mag):round(end_log*n.mag),:);

% update lengths
n.flow = size(log_flow(:,1));
n.gps = size(log_gps(:,1));
n.gyro = size(log_gyro(:,1));
n.mag = size(log_mag(:,1));

% get index x axis
x.log_flow = flipud(log_flow(:,1))/f_flow;
x.log_gps = flipud(log_gps(:,1))/f_gps;
x.log_gyro = flipud(log_gyro(:,1))/f_gyro;
x.log_mag = flipud(log_mag(:,1))/f_mag;

% populate structure and interpolate to larger array
log_data.flow_x = log_flow(:,4);
log_data.flow_y = log_flow(:,5);
log_data.flow_quality = log_flow(:,8);
log_data.raw_distance = log_flow(:,9)/1000;
log_data.distance_quality = log_flow(:,11);
log_data.gyro_x = log_gyro(:,2)*0.0139882;
log_data.gyro_y = log_gyro(:,3)*0.0139882;
log_data.mag_x = log_mag(:,2)/2000;
log_data.mag_y = log_mag(:,3)/2000;
log_data.vx_ned = log_gps(:,9)/100;
log_data.vy_ned = log_gps(:,10)/100;

%% 3 : filter data

% fix flow overshooting and distance overshooting
for i = 1:size(log_flow,1)-1
    if abs(log_data.flow_x(i)) > 100
        log_data.flow_x(i) = log_data.flow_x(i-1);
    end
    if abs(log_data.flow_y(i)) > 100
        log_data.flow_y(i) = log_data.flow_y(i-1);
    end
    if abs(log_data.raw_distance(i)) > 3000
        log_data.raw_distance(i) = log_data.raw_distance(i-1);
    end
    if log_data.raw_distance(i) < 0
        log_data.raw_distance(i) = log_data.raw_distance(i-1);
    end
end

% fix magnetometer zero fall
for i = 1:size(log_mag,1)-1
    if log_data.mag_x(i+1) == 0
        log_data.mag_x(i+1) = log_data.mag_x(i);
    end
    if log_data.mag_y(i+1) == 0
        log_data.mag_y(i+1) = log_data.mag_y(i);
    end
end

% OPTITRACK GENERATED BODY VELOCITIES
% transform NED frame for velocity to body frame
vx_body = zeros(1,size(log_gps,1));
vy_body = zeros(1,size(log_gps,1));

% interpolate magneto on gps 
log_data.mag_x_resized = imresize(log_data.mag_x, size(log_data.vx_ned));

for i = 1:size(log_gps,1)-1
    heading_i = acos(log_data.mag_x_resized(i));
    T_Eb_i = [cos(heading_i) sin(heading_i) 0; 
            -sin(heading_i) cos(heading_i) 0;
            0 0 1];
    V_E_i = [log_data.vx_ned(i), log_data.vy_ned(i), 0];
    V_B_i = T_Eb_i * V_E_i.';
    vx_body(i) = V_B_i(2);
    vy_body(i) = V_B_i(1);
end

% FLOW AND GYRO GENERATED BODY VELOCITIES
% use flowx and flowy with distance (from OT) for estimation
vx_body_flow = zeros(1,size(log_flow,1));
vy_body_flow = zeros(1,size(log_flow,1));

% interpolate gyro on optical flow
log_data.gyro_x_r = imresize(log_data.gyro_x, size(log_data.flow_x));
log_data.gyro_y_r = imresize(log_data.gyro_y, size(log_data.flow_y));

for i = 1:size(log_flow,1)-1
    dx_i = log_data.raw_distance(i) * tan(deg2rad(log_data.flow_x(i) - log_data.gyro_x_r(i)));
    dy_i = log_data.raw_distance(i) * tan(deg2rad(log_data.flow_y(i) - log_data.gyro_y_r(i)));
    vx_body_flow(i) = dy_i;
    vy_body_flow(i) = dx_i;
end

% interpolate gps on flow
vx_body_res = imresize(vx_body, size(vx_body_flow));
vy_body_res = imresize(vy_body, size(vy_body_flow));

%% 4 : plot the data

% ot center has an offset in z of the sensor
z_offset = 0.02;

% plot velocity and magneto from Optitrack
figure_1 = figure();
set(figure_1,'defaulttextinterpreter','latex');
subplot(3,2,1);
plot(x.log_flow, log_data.flow_x); hold on;
plot(x.log_flow, log_data.flow_y)
xlabel("Time [sec]");
ylabel("$FLOW$ [m/sec]");
subplot(3,2,2);
plot(x.log_flow, log_data.flow_quality); hold on;
plot(x.log_flow, log_data.distance_quality)
xlabel("Time [sec]");
ylabel("$QUALITY$ [m/sec]");
subplot(3,2,3);
plot(x.log_flow, log_data.raw_distance);
xlabel("Time [sec]");
ylabel("$DISTANCE$ [m/sec]");
subplot(3,2,4);
plot(x.log_gyro, log_data.gyro_x); hold on;
plot(x.log_gyro, log_data.gyro_y);
xlabel("Time [sec]");
ylabel("$GYRO$ [m/sec]");
subplot(3,2,5);
plot(x.log_mag, log_data.mag_x); hold on;
plot(x.log_mag, log_data.mag_y);
xlabel("Time [sec]");
ylabel("$MAG$ [m/sec]");
subplot(3,2,6);
plot(x.log_gps, log_data.vx_ned); hold on;
plot(x.log_gps, log_data.vy_ned);
xlabel("Time [sec]");
ylabel("$GPS$ [m/sec]");

% final computed velocities
figure_2 = figure();
set(figure_2,'defaulttextinterpreter','latex');
subplot(2,1,1);
plot(x.log_flow, vx_body_res); hold on;
plot(x.log_flow, vx_body_flow);
legend('optitrack', 'flow');
xlabel("Time [sec]");
ylabel("$V_x$ [m/sec]");
subplot(2,1,2);
plot(x.log_flow, vy_body_res); hold on;
plot(x.log_flow, vy_body_flow);
xlabel("Time [sec]");
ylabel("$V_y$ [m/sec]");

