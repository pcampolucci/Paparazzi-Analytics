%% Read Test Data and Plot

% extract information to be read
opti_log_folder = 'opti_logs/';
name_1 = 'Take 2021-05-21 05.07.33 PM';     % comment: discard
name_2 = 'Take 2021-05-21 05.09.28 PM';     % comment: discard
name_3 = 'Take 2021-05-21 05.19.56 PM';     % comment: discard
name_4 = 'Take 2021-05-21 05.25.37 PM';     % comment: discard
name_5 = 'Take 2021-05-21 05.29.33 PM';     % comment: good path
name_6 = 'Take 2021-05-21 05.30.32 PM';     % comment: good path

body_frame = {'Nederdrone'};
frame_def = 'ForwardLeftUp';

data = optitrack_import(strcat(opti_log_folder, name_5), body_frame, frame_def);

% plot the data

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

% extract velocities (we run at 250 fps)
vsize = data.Nframes - 2;
velocity_x = zeros(vsize,1);
velocity_y = zeros(vsize,1);
velocity_z = zeros(vsize,1);
fps = 250;
dt = 1/fps;

for i=2:(data.Nframes-1)
    dvx = (position_x(i+1) - position_x(i-1))/(2*dt);
    dvy = (position_y(i+1) - position_y(i-1))/(2*dt);
    dvz = (position_z(i+1) - position_z(i-1))/(2*dt);
    velocity_x(i-1) = dvx;
    velocity_y(i-1) = dvy;
    velocity_z(i-1) = dvz;
end

velocity_x_new = lowpass(velocity_x,1,fps);
velocity_y_new = lowpass(velocity_y,10,fps);
velocity_z_new = lowpass(velocity_z,10,fps);

figure(1);
plot3(position_x, position_y, position_z);

figure(2)
subplot(3,1,1);
plot(time_vel, velocity_x_new);
subplot(3,1,2);
plot(time_vel, velocity_y_new);
subplot(3,1,3);
plot(time_vel, velocity_z_new);

figure(3)
subplot(4,1,1);
plot(time, rotation_x);
subplot(4,1,2);
plot(time, rotation_y);
subplot(4,1,3);
plot(time, rotation_z);
subplot(4,1,4);
plot(time, rotation_w);






