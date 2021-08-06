%% Noise Estimation for LiDAR and Optical Flow

%%  0 : Control Panel and Initial Settings

% timestamps and frequencies of signals
t_flow = 0.05;
f_flow = 1/t_flow;
t_start_logger = 0;

% set start end for log
start_log = 0.58;
end_log = 0.68;

%%  1 : Process Data from Logger

% extract information to be read
ppz_log_folder = 'logs_csv_logger/noise_test/';
log_name_1 = '21_08_06__14_49_41';
ext = '.csv';

% read the file
log_flow = csvread(strcat(ppz_log_folder,log_name_1,'_OPTICAL_FLOW',ext),1,0);

% flip the order
log_flow = flipud(log_flow);

% get lengths
n.flow = size(log_flow(:,1));

% cut interval
log_flow = log_flow(round(start_log*n.flow):round(end_log*n.flow),:);

% update lengths
n.flow = size(log_flow(:,1));

% get index x axis
x.log_flow = flipud(log_flow(:,1))/f_flow;

% populate structure and interpolate to larger array
log_data.flow_x = log_flow(:,4);                       
log_data.flow_y = log_flow(:,5);                        
log_data.flow_quality = log_flow(:,8);
log_data.raw_distance = log_flow(:,10);            
log_data.distance_quality = log_flow(:,11);        

%% 2 : Plot to See the Log

figure();
subplot(5,1,1);
plot(x.log_flow, log_data.flow_x);
subplot(5,1,2);
plot(x.log_flow, log_data.flow_y);
subplot(5,1,3);
plot(x.log_flow, log_data.flow_quality);
subplot(5,1,4);
plot(x.log_flow, log_data.raw_distance);
subplot(5,1,5);
plot(x.log_flow, log_data.distance_quality);

%% 3 : estimate noise for optical flow
% low quality interval 0.57 - 0.63 --> 0.03
% high quality interval 0.77 - 0.8 --> 0.01

noise_flow_x = std(log_data.flow_x);
noise_flow_y = std(log_data.flow_y);
noise_flow = (noise_flow_x + noise_flow_y)/2;
noise_flow_rad = deg2rad(noise_flow);

%% 3 : estimate noise for distance
% interval 0.58 - 0.68 --> 0.002

noise_distance = std(log_data.raw_distance);
noise_distance_m = noise_distance / 1000;



