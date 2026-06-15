function [power_all, ori_all, roll_all, pitch_all, azim, elev, dist_3D, dist_2D_new, RSRP_PL_free, RSRP_PL_two, lat_all, lon_all, h_all, speed_all] = baseline_flipx_cole(exp_no, location, use_ground_relfec, save, save_name, use_ori, correct_uav_angle, unknown_angle, ant_filename)
    if nargin < 3
        use_ground_relfec = 0;
    end
    if nargin < 5
        save = 0;
        save_name = "";
    end
    if nargin < 6
        use_ori = 1;
    end
    if nargin < 7
        correct_uav_angle = 1;
    end
    if nargin < 8
        unknown_angle = 0;
    end
    if nargin < 9
        ant_filename = "default";
    end

    if correct_uav_angle > 0
        if location < 3
            ugv_angle = 60.7648 * pi/180;
        else
            ugv_angle = -70.4993 * pi/180;
        end
    else
        ugv_angle = 0; % disable ugv angle
    end

    matdata = load("data_mat/results_useful_ori_exp_"+num2str(exp_no)+"_loc_"+num2str(location)+".mat");
    
    scaler = 111139 ;
    R_earth = 6378.137 * 10^3 ; % [m]
    
    lat_all = matdata.mY;
    lon_all = matdata.mX;
    h_all = matdata.mZ;
    power_all = matdata.mpower;
    vz_all = matdata.mVz;
    q_all = matdata.mquality;
    speed_all = matdata.mSpeed;
    ori_all = matdata.mYaw+unknown_angle; % 0 to 360
    roll_all = matdata.mRoll;
    pitch_all = matdata.mPitch;

    ori_all = ori_all - 360 .* (ori_all>=180) + 360 .* (ori_all<-180);
    roll_all = roll_all - 360 .* (roll_all>=180) + 360 .* (roll_all<-180);
    pitch_all = pitch_all - 360 .* (pitch_all>=180) + 360 .* (pitch_all<-180);
    
    %%
    height_avg = mode(round(h_all));
    
    valid_height = ((h_all>height_avg-5) & (h_all<height_avg+5));
    lat_all = lat_all(valid_height);
    lon_all = lon_all(valid_height);
    h_all = h_all(valid_height);
    power_all = power_all(valid_height);
    vz_all = vz_all(valid_height);
    q_all = q_all(valid_height);
    speed_all = speed_all(valid_height);
    ori_all = ori_all(valid_height);
    roll_all = roll_all(valid_height);
    pitch_all = pitch_all(valid_height);
    
    N_sam = length(power_all);
    
    if location ==1
    origin_y=35.72806709;
    origin_x=-78.69730398;
    end
    
    if location==2
    origin_y=35.72911779;
    origin_x=-78.69918128;
    end
    
    if location==3
    origin_y=35.72985129;
    origin_x=-78.69711002;
    end
    
    lat_BS = origin_y;
    lon_BS = origin_x;
    
    %% 
    h_UAV_new = h_all;
    h_BS = 1.5;
    P_Tx_dBm = 100 ; % [dBm]
    c = 3.0e8;
    f0 = 3.32e9; % what is the actual f0 here
    lamda = c/f0;
    dist_2D_new = R_earth .* acos(sin(lat_BS * pi/180) .* sin(lat_all * pi/180) + cos(lat_BS * pi/180) .* cos(lat_all * pi/180) .* cos( (lon_all - lon_BS)  * pi/180 )) ;
    dist_3D = sqrt( (dist_2D_new).^2 + (h_UAV_new - h_BS).^2 ) ;
    unknown_offset = 0;
    P_Tx_2_dBm = P_Tx_dBm + unknown_offset ;
    P_Tx_2 = 10.^(P_Tx_2_dBm/10) ;
    
    %% Elevation angle
    elev = atan( ( h_UAV_new - h_BS )./dist_2D_new) ;
    
    %% Azimuth angle
    % cos*sin(lat_BS) - cos * sin(mY(ii)) % so it is respect to receiver i!! no
    % the data shows it is respect to the BS
    % guess
    % azim calculation was incorrect i think
    for ii=1:length(lon_all)
        azim(ii,1) = great_circle_azimuth(lat_BS,lon_BS,lat_all(ii),lon_all(ii));
    end
    
    %% Antenna pattern
    if ant_filename == "default"
        load rad_pat.mat
        G_t_dB = SA3300; %RMWB3300_upside_down; % considering SA3300 is for tx mode (right side up)
        %     amp_dB5 = [SA3300(:,61:120), SA3300(:,1:60)]; % 180 degree shift
        %     amp_dB6 = [fliplr(amp_dB5(:,1:60)), fliplr(amp_dB5(:,61:120))]; % flip around 90 degree
        %     G_r_dB = amp_dB6; % G_r_dB SA3300
        % the above code was a just fliplr(SA3300), so that you can put phi,
        % instead of -phi. No need of that, after I have the latex document, follow
        % the document
        G_r_dB = SA3300;
        %theta2 = flipud(theta2);
        %phi2 = fliplr(phi2);

    else
        eval("load "+ant_filename)
        eval("G_t_dB = tx_patt_with_placement_effect;")
        eval("G_r_dB = rx_patt_with_placement_effect;")
        %theta2 = flipud(theta2);
        %phi2 = fliplr(phi2);
    end
    
    G_t_max = 0 ; % [dBi]
    G_r_max = 0 ; % [dBi]
    phi_os = 0; % 0 ~ 119 % 88
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ant_opt = 'measured' ; % 'measured', 'constant', 'dipole'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    switch(ant_opt)
        case('measured')       
            % Antenna pattern from the new measurement
            % with respect to BS
            [~,idx_theta] = min(abs(elev - theta2'*pi/180)') ;
            % with respect to BS
            theta_tx = azim - ugv_angle;
            theta_tx = theta_tx + (theta_tx<-pi).*2*pi - (theta_tx>pi).*2*pi;
            [~,idx_phi] = min(abs(theta_tx - circshift(phi2, phi_os)*pi/180)') ;
            % with respect to UAV %% update: angle should be the same, for
            % receiver it is from source to receiver (direction)
            %[~,idx_theta2] = min(abs(pi/2 - elev - theta2'*pi/180)') ;
            % with respect to UAV
            %azim_from_distance = azim + pi - 2*pi*(azim>0); % from -pi to pi
            if use_ori
                % plus becuase I have used -azim_wrt_uav_ori below
                azim_wrt_uav_ori = azim + ori_all*pi/180;
                % next line adds pi ( or -pi) to add 180 degree as in
                % equation
                azim_wrt_uav_ori = azim_wrt_uav_ori - (azim_wrt_uav_ori>=0).*pi + (azim_wrt_uav_ori<0).*pi;
                [~,idx_phi2] = min(abs(-azim_wrt_uav_ori  - circshift(phi2, phi_os)*pi/180)') ;
            else
                azim_plus_pi = azim - (azim>=0).*pi + (azim<0).*pi;
                [~,idx_phi2] = min(abs(-azim_plus_pi  - circshift(phi2, phi_os)*pi/180)') ;
                %[~,idx_phi2] = min(abs(azim_plus_pi  - circshift(phi2, phi_os)*pi/180)') ;
            end
            
            for ii=1:N_sam
                G_t(ii,1)= G_t_dB(idx_theta(ii), idx_phi(ii)) ; % [dBi]
            end
            for ii=1:N_sam
                % use idx_phi to set orientation set to North (fixed)
                % % use idx_phi2 to set orientation based on pathway
                G_r(ii,1)= G_r_dB(idx_theta(ii), idx_phi2(ii)) + G_r_max ; % [dBi]
            end
            %G_r = G_r_dB(idx_theta,1) + G_r_max ; % [dBi]
        case('constant')
            % Antenna pattern constant gain
            G_t = 0 ;
            G_r = 0 ;
        case('dipole')
            % Antenna pattern dipole shape
            const_gain = 0 ;
            d_len = 0.5*lamda;
            
            G_t_lin = (cos(pi*d_len/lamda*cos(pi/2 - elev))-cos(pi*d_len/lamda))./sin(pi/2 - elev);
            G_r_lin = (cos(pi*d_len/lamda*cos(pi/2 - elev))-cos(pi*d_len/lamda))./sin(pi/2 - elev);
            
            G_t = 20*log10(G_t_lin) + const_gain ;
            G_r = 20*log10(G_r_lin) ;
    end
    
    %% 
    G_t_l = 10.^(G_t/10) ;
    G_r_l = 10.^(G_r/10) ;
    
    RSRP_PL_free_lin = P_Tx_2 * (lamda/(4*pi))^2 * abs( sqrt(G_t_l) .* sqrt(G_r_l) ./ ( dist_3D ) ).^2 ;
    RSRP_PL_free = 10*log10(RSRP_PL_free_lin) ;
    
    %% Two-ray ground reflection pathloss model
    rho = 0.005 ;
    eps = 15 ;
    % rho = 0.02 ;
    % eps = 25 ;
    eps_0 = eps - j*60*rho*lamda ;
    
    th_r = atan( ( h_BS + h_UAV_new ) ./ (dist_2D_new) ) ; % from 0 to pi/2
    th_r_2 = 2*pi - th_r ;
    th_r_22 = - th_r ;
    
    r_1 = h_BS ./ sin(th_r) ;
    r_2 = h_UAV_new ./ sin(th_r) ;
    r_3 = dist_3D ;
    
    phi_del = 2*pi*( r_1 + r_2 - r_3)/lamda ;
    
    z_V = sqrt(eps_0 - cos(th_r).^2) / eps_0 ;
    R_V = (sin(th_r) - z_V) ./ (sin(th_r) + z_V) ;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch(ant_opt)
        case('measured')
            % Antenna pattern from the new measurement
            % for shadow fading, receiver angle is pi/2 - transmitter ang
            % (opposed to LOS), where both angle equal
            [~,idx_theta_t_r] = min(abs(th_r_22 - theta2'*pi/180)') ; % transmitter ray downwards
            [~,idx_theta_r_r] = min(abs(th_r - theta2'*pi/180)') ; % receiver ray recives upward ray
            
            for ii=1:N_sam
                G_t_r_dB(ii,1)= G_t_dB(idx_theta_t_r(ii), idx_phi(ii)) ; % [dBi]
            end
            for ii=1:N_sam
                % use idx_phi to set orientation set to North (fixed)
                % % use idx_phi2 to set orientation based on pathway
                G_r_r_dB(ii,1)= G_r_dB(idx_theta_r_r(ii), idx_phi2(ii)) + G_r_max ; % [dBi]
            end
        case('constant')      
            G_t_r_dB = 0 ;
            G_r_r_dB = 0 ;
        case('dipole')
            % Antenna pattern dipole shape
            G_t_r_lin = (cos(pi*d_len/lamda*cos(pi/2 - th_r_22))-cos(pi*d_len/lamda))./sin(pi/2 - th_r_22);
            G_r_r_lin = (cos(pi*d_len/lamda*cos(pi/2 - th_r))-cos(pi*d_len/lamda))./sin(pi/2 - th_r);
            
            G_t_r_dB = 20*log10(G_t_r_lin) + const_gain ;
            G_r_r_dB = 20*log10(G_r_r_lin)  ;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % figure
    % hold on
    % grid on

    % plot(dist_3D, "DisplayName","Dist 3D")
    % plot(G_t, "DisplayName","Gt")
    % plot(G_r, "DisplayName","Gr")
    % plot(power_all, "DisplayName","power")
    % plot(azim*180/pi, "DisplayName","azim")
    % plot(elev*180/pi, "DisplayName","elev")
    % plot(idx_theta, "DisplayName","idx theta")
    % plot(idx_phi, "DisplayName","idx phi")
    % 
    % legend show
    % 
    % figure
    % imagesc(SA3500)
    
    G_t_r = 10.^(G_t_r_dB/10) ;
    G_r_r = 10.^(G_r_r_dB/10) ;
    
    RSRP_PL_two_lin = P_Tx_2 * (lamda/(4*pi))^2 * abs( sqrt(G_t_l) .* sqrt(G_r_l) ./ ( r_3 ) + R_V .* sqrt(G_t_r) .* sqrt(G_r_r) ./ ( r_1 + r_2) .* exp( -j * phi_del ) ).^2 ;
    RSRP_PL_two = 10*log10(RSRP_PL_two_lin);
end
