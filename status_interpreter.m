function [done] = status_interpreter(status)
% EKF STATUS READER
% The code gets a status struct, reads the binary digits and
% returns an excel file will all the information frame by frame

%% 1 : Library for Conversion

% control dictionary
control_dict = {
        'title_align';
        'yaw_align';
        'gps';
        'opt_flow';
        'mag_hdg';
        'mag_3D';
        'mag_dec';
        'in_air';
        'wind';
        'baro_hgt';
        'rng_hgt';
        'gps_hgt';
        'ev_pos';
        'ev_yaw';
        'ev_hgt';
        'fuse_beta';
        'update_mag';
        'fixed_wing';
        'mag_fault';
        'fuse_aspd';
        'gnd_effect';
        'rng_stuck';
        'gps_yaw';
        'mag_align_good'
};

% fault dictionary
fault_dict = {
        'bad_mag_x';
        'bad_mag_y';
        'bad_mag_z';
        'bad_hdg';
        'bad_mag_decl';
        'bad_airspeed';
        'bad_sideslip';
        'bad_optflow_X';
        'bad_optflow_Y';
        'bad_vel_N';
        'bad_vel_E';
        'bad_vel_D';
        'bad_pos_N';
        'bad_pos_E';
        'bad_pos_D';
        'bad_acc_bias';
};

% gps dictionary
gps_dict = {
        'no_fix';
        'no_nsats';
        'no_gdop';
        'bad_hacc';
        'bad_vacc';
        'bad_sacc';
        'high_hdrift';
        'high_vdrift';
        'high_hspeed';
        'high_vspeed';
};

% solution dictionary
solution_dict = {
        'attitude';
        'vhoriz';
        'vvert';
        'pos_horiz_rel';
        'pos_horiz_abs';
        'pos_vert_abs';
        'pos_vert_agl';
        'const_pos';
        'pred_pos_horiz_rel';
        'pred_pos_horiz_abs';
        'gps_glitch';
        'accel_error';
};

% innovation dictionary
innov_dict = {
        'reject_vel_NED';
        'reject_pos_NE';
        'reject_pos_D';
        'reject_mag_x';
        'reject_mag_y';
        'reject_mag_z';
        'reject_yaw';
        'reject_airspeed';
        'reject_sideslip';
        'reject_hagl';
        'reject_flow_x';
        'reject_flow_y';
};

%% 2 : get status codes

% for every sample
for i = 1:length(status.control(:,1))
    
    disp('===========================================================');
    disp('New Sample');
    
    bit_length = 32;
    
    % values
    control = dec2bin(status.control(i),bit_length);
    fault = dec2bin(status.fault(i),bit_length);
    gps = dec2bin(status.gps(i),bit_length);
    solution = dec2bin(status.solution(i),bit_length);
    innov = dec2bin(status.innov(i),bit_length);

    % list of all binary codes for this iteration
    bin_list = {control,fault,gps,solution,innov};
    
    % list of all dicts
    dict_list = {control_dict,fault_dict,gps_dict,solution_dict,innov_dict};
    
    % list of messages
    msg_list = {'controls status','fault status','gps fail status','solution status','innovation status'};
    
    % for every check datatype
    for j = 1:length(bin_list)
        
        digit_string = char(bin_list(j));
        dict_current = dict_list{j};
        
        disp(' ');
        mess = [msg_list{j},' ',digit_string];
        disp(mess);
        disp('-----------------------------------------');
        
        for k = 1:bit_length
        
            single_digit = str2double(digit_string(bit_length-k+1));
            
            if single_digit == 1
                disp(char(dict_current(k,:)));
            end
        end
    end
end

done = 1;




