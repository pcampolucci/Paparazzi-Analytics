function [log,idx_log,n_log] = extract_data(ppz_log_folder,log_name,message,ext,f_message,start_log,end_log)

% file 
path = strcat(ppz_log_folder,log_name,message,ext);

% read the file
log = csvread(path,1,0);

% flip the order
log= flipud(log);

% get lengths
n_log = size(log(:,1));

% cut interval
log = log(round(start_log*n_log):round(end_log*n_log),:);

% update lengths
n_log = size(log(:,1));

% get index x axis
idx_log = flipud(log(:,1))/f_message;

end

