%% Read Test Data and Plot

% extract information to be read
ppz_log_folder = 'quad_logs/';
log_name = '21_MAY_OPTITEST';
ext = '.csv';

% read the file
log_debug = csvread(strcat(ppz_log_folder,log_name,'_DEBUG',ext),1,0);
log_fp = csvread(strcat(ppz_log_folder,log_name,'_ROTORCRAFT_FP',ext),1,0);
log_status = csvread(strcat(ppz_log_folder,log_name,'_ROTORCRAFT_STATUS',ext),1,0);

% set start end for big log
start_log = 0.1;
end_log = 0.6;

% flip the order
log_debug = flipud(log_debug);
log_fp = flipud(log_fp);
log_status = flipud(log_status);

% get lengths
n.debug = size(log_debug(:,1));
n.fp = size(log_fp(:,1));
n.status = size(log_status(:,1));

% cut interval

log_debug = log_debug(round(start_log*n.debug):round(end_log*n.debug),:);
log_fp = log_fp(round(start_log*n.fp):round(end_log*n.fp),:);
log_status = log_status(round(start_log*n.status):round(end_log*n.status),:);

% update lengths
n.debug = size(log_debug(:,1));
n.fp = size(log_fp(:,1));
n.status = size(log_status(:,1));

% get index x axis
x.debug = flipud(log_debug(:,1)) - log_debug(end,1);
x.fp = flipud(log_fp(:,1)) - log_fp(end,1);
x.status = flipud(log_status(:,1)) - log_status(end,1);

% get optitrack data
opti_data.rotation_x = data.CSVdata(:,2);
opti_data.rotation_y = data.CSVdata(:,3);
opti_data.rotation_z = data.CSVdata(:,4);
opti_data.rotation_w = data.CSVdata(:,5);
opti_data.position_x = data.CSVdata(:,6);
opti_data.position_y = data.CSVdata(:,7);
opti_data.position_z = data.CSVdata(:,8);

% extract velocities (we run at 250 fps)
vsize = data.Nframes - 2;
opti_data.velocity_x = zeros(vsize,1);
opti_data.velocity_y = zeros(vsize,1);
opti_data.velocity_z = zeros(vsize,1);
fps = 250;
dt = 1/fps;
opti_data.time = data.time;
opti_data.time_vel = data.time(2:data.Nframes-1);

for i=2:(data.Nframes-1)
    dvx = (opti_data.position_x(i+1) - opti_data.position_x(i-1))/(2*dt);
    dvy = (opti_data.position_y(i+1) - opti_data.position_y(i-1))/(2*dt);
    dvz = (opti_data.position_z(i+1) - opti_data.position_z(i-1))/(2*dt);
    opti_data.velocity_x(i-1) = dvx;
    opti_data.velocity_y(i-1) = dvy;
    opti_data.velocity_z(i-1) = dvz;
end

opti_data.velocity_x_lp = lowpass(opti_data.velocity_x,1,fps);
opti_data.velocity_y_lp = lowpass(opti_data.velocity_y,10,fps);
opti_data.velocity_z_lp = lowpass(opti_data.velocity_z,10,fps);

% populate structure and interpolate to larger array
log_data.quality = log_debug(:,2); 
log_data.flowx = log_debug(:,3); 
log_data.flowy = log_debug(:,4);

log_data.east = log_fp(:,2)*0.0039063;
log_data.north = log_fp(:,3)*0.0039063;
log_data.up = log_fp(:,4)*0.0039063;
log_data.veast = log_fp(:,5)*0.0000019;
log_data.vnorth = log_fp(:,6)*0.0000019;
log_data.vup = log_fp(:,7)*0.0000019;
log_data.phi = log_fp(:,8)*0.0139882;
log_data.theta = log_fp(:,9)*0.0139882;
log_data.psi = log_fp(:,10)*0.0139882;
log_data.flight_time = log_fp(:,16);

log_data.gps_status = log_status(:,6);
log_data.ap_mode = log_status(:,7);
log_data.in_flight = log_status(:,8);

log_data.east = interp1(x.fp,log_data.east,x.debug);
log_data.north = interp1(x.fp,log_data.north,x.debug);
log_data.up = interp1(x.fp,log_data.up,x.debug);
log_data.veast = interp1(x.fp,log_data.veast,x.debug);
log_data.vnorth = interp1(x.fp,log_data.vnorth,x.debug);
log_data.vup = interp1(x.fp,log_data.vup,x.debug);
log_data.phi = interp1(x.fp,log_data.phi,x.debug);
log_data.theta = interp1(x.fp,log_data.theta,x.debug);
log_data.psi = interp1(x.fp,log_data.psi,x.debug);
log_data.flight_time = interp1(x.fp,log_data.flight_time,x.debug);
log_data.gps_status = interp1(x.status,log_data.gps_status,x.debug);
log_data.ap_mode = interp1(x.status,log_data.ap_mode,x.debug);
log_data.in_flight = interp1(x.status,log_data.in_flight,x.debug);

% plot only optical flow 

% filter flow with quality
log_data.flowx_filtered = log_data.flowx;
log_data.flowy_filtered = log_data.flowy;
flow_qual_min = 150;

for i=2:n.debug-1
   if log_data.quality(i) < flow_qual_min
       log_data.flowx_filtered(i) = log_data.flowx_filtered(i-1);
       log_data.flowy_filtered(i) = log_data.flowy_filtered(i-1);
   end
end

figure(1)
subplot(4,2,1);
plot(x.debug, log_data.quality);
subplot(4,2,3);
plot(x.debug, log_data.flowx); hold on;
plot(x.debug, log_data.flowx_filtered);
ylim([-0.3 0.3])
subplot(4,2,5);
plot(x.debug, log_data.flowy); hold on;
plot(x.debug, log_data.flowy_filtered);
ylim([-0.3 0.3])
subplot(4,2,2);
plot(x.debug, log_data.phi);
subplot(4,2,4);
plot(x.debug, log_data.theta);
subplot(4,2,6);
plot(x.debug, log_data.psi);
subplot(4,2,8);
plot(x.debug, log_data.flight_time);

% plot straight
figure(2)
subplot(4,2,1);
plot(x.debug, log_data.east);
subplot(4,2,3);
plot(x.debug, log_data.north);
subplot(4,2,5);
plot(x.debug, log_data.up);
subplot(4,2,2);
plot(x.debug, log_data.veast);
subplot(4,2,4);
plot(x.debug, log_data.vnorth);
subplot(4,2,6);
plot(x.debug, log_data.vup);
subplot(4,2,8);
plot(x.debug, log_data.flight_time);

figure(3)
plot3(log_data.east,log_data.north,log_data.up); hold on;
plot3(opti_data.position_x,opti_data.position_y,opti_data.position_z);

% plot velocities
figure(4)
vylim = 0.8;
title('Velocities');
subplot(4,2,1);
plot(opti_data.time_vel, opti_data.velocity_x_lp);
ylim([-vylim vylim])
subplot(4,2,3);
plot(opti_data.time_vel, opti_data.velocity_y_lp);
ylim([-vylim vylim])
subplot(4,2,5);
plot(opti_data.time_vel, opti_data.velocity_z_lp);
ylim([-vylim vylim])
subplot(4,2,2);
plot(x.debug, log_data.veast);
ylim([-vylim vylim])
subplot(4,2,4);
plot(x.debug, log_data.vnorth);
ylim([-vylim vylim])
subplot(4,2,6);
plot(x.debug, log_data.vup);
ylim([-vylim vylim])
subplot(4,2,8);
plot(x.debug, log_data.flight_time);

% plot positions
figure(5)
subplot(4,2,1);
plot(opti_data.time, opti_data.position_x);
subplot(4,2,3);
plot(opti_data.time, opti_data.position_y);
subplot(4,2,5);
plot(opti_data.time, opti_data.position_z);
subplot(4,2,2);
plot(x.debug, log_data.east);
subplot(4,2,4);
plot(x.debug, log_data.north);
subplot(4,2,6);
plot(x.debug, log_data.up);
subplot(4,2,8);
plot(x.debug, log_data.flight_time);











