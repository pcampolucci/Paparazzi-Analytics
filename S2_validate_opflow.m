%% Read Test Data and Plot

% extract information to be read
ppz_log_folder = 'quad_logs/';
log_name = '21_MAY_OPTITEST';
ext = '.csv';

% read the file
log_opflow = csvread(strcat(ppz_log_folder,log_name,'_OPTICAL_FLOW',ext),1,0);
log_debug = csvread(strcat(ppz_log_folder,log_name,'_DEBUG',ext),1,0);
log_fp = csvread(strcat(ppz_log_folder,log_name,'_ROTORCRAFT_FP',ext),1,0);
log_status = csvread(strcat(ppz_log_folder,log_name,'_ROTORCRAFT_STATUS',ext),1,0);

% set start end for big log
start_log = 0.1;
end_log = 0.9;

% flip the order
log_opflow = flipud(log_opflow);
log_debug = flipud(log_debug);
log_fp = flipud(log_fp);
log_status = flipud(log_status);

% get lengths
n.opflow = size(log_opflow(:,1));
n.debug = size(log_debug(:,1));
n.fp = size(log_fp(:,1));
n.status = size(log_status(:,1));

% cut interval

log_opflow = log_opflow(round(start_log*n.opflow):round(end_log*n.opflow),:);
log_debug = log_debug(round(start_log*n.debug):round(end_log*n.debug),:);
log_fp = log_fp(round(start_log*n.fp):round(end_log*n.fp),:);
log_status = log_status(round(start_log*n.status):round(end_log*n.status),:);

% update lengths
n.opflow = size(log_opflow(:,1));
n.debug = size(log_debug(:,1));
n.fp = size(log_fp(:,1));
n.status = size(log_status(:,1));

% get index x axis
x.opflow = flipud(log_opflow(:,1)) - log_opflow(end,1);
x.debug = flipud(log_debug(:,1));
x.fp = flipud(log_fp(:,1));
x.status = flipud(log_status(:,1));


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











