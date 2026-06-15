function RSRP_PL_free = baseline_flipx_afar_letter(exp_no, location, use_ground_relfec, save, save_name, use_ori, correct_uav_angle, unknown_angle, ant_filename)
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

    load("results_useful_with_tworay_tilt_src_exp_"+num2str(exp_no)+"_loc_"+num2str(location)+".mat")
    
    scaler = 111139 ;
    R_earth = 6378.137 * 10^3 ; % [m]

    [azim2, elev2] = get_uav_body_reflection_letter(azim,elev,ori_all,pitch_all,roll_all,dist_2D_new,h_all);
    
%     lat_all = matdata.mY;
%     lon_all = matdata.mX;
%     h_all = matdata.mZ;
%     power_all = matdata.mpower;
%     vz_all = matdata.mVz;
%     q_all = matdata.mquality;
%     speed_all = matdata.mSpeed;
%     ori_all = matdata.mYaw+unknown_angle; % 0 to 360
%     roll_all = matdata.mRoll;
%     pitch_all = matdata.mPitch;
% 
%     ori_all = ori_all - 360 .* (ori_all>=180) + 360 .* (ori_all<-180);
%     roll_all = roll_all - 360 .* (roll_all>=180) + 360 .* (roll_all<-180);
%     pitch_all = pitch_all - 360 .* (pitch_all>=180) + 360 .* (pitch_all<-180);
%     
%     %%
%     height_avg = mode(round(h_all));
%     
%     valid_height = ((h_all>height_avg-5) & (h_all<height_avg+5));
%     lat_all = lat_all(valid_height);
%     lon_all = lon_all(valid_height);
%     h_all = h_all(valid_height);
%     power_all = power_all(valid_height);
%     vz_all = vz_all(valid_height);
%     q_all = q_all(valid_height);
%     speed_all = speed_all(valid_height);
%     ori_all = ori_all(valid_height);
%     roll_all = roll_all(valid_height);
%     pitch_all = pitch_all(valid_height);
    
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
    if ant_filename == "zero"
        disp('no antenna pattern will be used')
        RSRP_PL_free_lin = P_Tx_2 * (lamda/(4*pi))^2 ./ ( dist_3D.^2 ) ;
        RSRP_PL_free = 10*log10(RSRP_PL_free_lin) ;
    else
        if ant_filename == "default"
            load rad_pat.mat
            G_t_dB = SA3300; %RMWB3300_normal; %RMWB3300_upside_down; % considering SA3300 is for tx mode (right side up)
            %     amp_dB5 = [SA3300(:,61:120), SA3300(:,1:60)]; % 180 degree shift
            %     amp_dB6 = [fliplr(amp_dB5(:,1:60)), fliplr(amp_dB5(:,61:120))]; % flip around 90 degree
            %     G_r_dB = amp_dB6; % G_r_dB SA3300
            % the above code was a just fliplr(SA3300), so that you can put phi,
            % instead of -phi. No need of that, after I have the latex document, follow
            % the document
            G_r_dB = SA3300;
            %theta2 = flipud(theta2);
            %phi2 = fliplr(phi2);
            disp("default antenna pattern will be used")
        elseif ant_filename == "zero"
            disp('no antenna pattern will be used')
        else
            eval("load "+ant_filename)
            eval("G_mutual_dB = M_estimated;")
            disp("loading "+ ant_filename)
            disp(size(G_mutual_dB))
            %theta2 = flipud(theta2);
            %phi2 = fliplr(phi2);
            
            % when not available in mutual, fall back to anechoic
            load rad_pat.mat
            G_t_dB = SA3300; %RMWB3300_normal; %RMWB3300_upside_down; % considering SA3300 is for tx mode (right side up)
            %     amp_dB5 = [SA3300(:,61:120), SA3300(:,1:60)]; % 180 degree shift
            %     amp_dB6 = [fliplr(amp_dB5(:,1:60)), fliplr(amp_dB5(:,61:120))]; % flip around 90 degree
            %     G_r_dB = amp_dB6; % G_r_dB SA3300
            % the above code was a just fliplr(SA3300), so that you can put phi,
            % instead of -phi. No need of that, after I have the latex document, follow
            % the document
            G_r_dB = SA3300;
            %theta2 = flipud(theta2);
            %phi2 = fliplr(phi2);
    
        end
        
        G_t_max = 0 ; % [dBi]
        G_r_max = 0 ; % [dBi]
        phi_os = 0; % 0 ~ 119 % 88
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ant_opt = 'measured' ; % 'measured', 'constant', 'dipole'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
             
        % Antenna pattern from the new measurement
        if ant_filename == "default"
            % with respect to BS
            [~,idx_theta] = min(abs(elev - theta2'*pi/180)') ;
            % with respect to BS
            theta_tx = azim - ugv_angle;
            theta_tx = theta_tx + (theta_tx<-pi).*2*pi - (theta_tx>pi).*2*pi;
            [~,idx_phi] = min(abs(theta_tx - circshift(phi2, phi_os)*pi/180)') ;
        
            [~,idx_theta2] = min(abs(elev2 - theta2'*pi/180)') ;
            [~,idx_phi2] = min(abs(azim2 - circshift(phi2, phi_os)*pi/180)') ;
        else
            % with respect to BS
            [~,idx_theta] = min(abs(elev - theta_grid)') ;
            % with respect to BS
            [~,idx_phi] = min(abs(azim - circshift(phi_grid, phi_os))') ;
        
            [~,idx_theta2] = min(abs(elev2 - theta_grid)') ;
            [~,idx_phi2] = min(abs(azim2 - circshift(phi_grid, phi_os))') ;

            % with respect to BS
            [~,idx_theta_anec] = min(abs(elev - theta2'*pi/180)') ;
            % with respect to BS
            theta_tx = azim - ugv_angle;
            theta_tx = theta_tx + (theta_tx<-pi).*2*pi - (theta_tx>pi).*2*pi;
            [~,idx_phi_anec] = min(abs(theta_tx - circshift(phi2, phi_os)*pi/180)') ;
        
            [~,idx_theta2_anec] = min(abs(elev2 - theta2'*pi/180)') ;
            [~,idx_phi2_anec] = min(abs(azim2 - circshift(phi2, phi_os)*pi/180)') ;
        end
        
        n_count = 0;
        for ii=1:N_sam
            if ant_filename == "default"
                G_both(ii,1) = G_t_dB(idx_theta(ii), idx_phi(ii)) + G_r_dB(idx_theta2(ii), idx_phi2(ii)) + G_r_max;
            else
                n_count = n_count + 1;
                %fprintf("ii: %d elev %.2f azim %.2f elev2 %.2f azim2 %.2f\n", ii, elev(ii)*180/pi, azim(ii)*180/pi, elev2(ii)*180/pi, azim2(ii)*180/pi)
                G_both(ii,1) = G_mutual_dB(idx_theta(ii), idx_phi(ii),idx_theta2(ii), idx_phi2(ii));
                %fprintf("ii: %d elev %d azim %d elev2 %d azim2 %d\n", ii, idx_theta(ii), idx_phi(ii),idx_theta2(ii), idx_phi2(ii))
                if isnan(G_both(ii,1))
                    n_count = n_count - 1;
                    G_both(ii,1) = G_t_dB(idx_theta_anec(ii), idx_phi_anec(ii)) + G_r_dB(idx_theta2_anec(ii), idx_phi2_anec(ii)) + G_r_max;
                end
            end
        end
        disp(n_count/N_sam*100)
        disp("percent")

%         figure
%         histogram(G_both(:))
        
        %% 
        G_both_l = 10.^(G_both/10) ;
        % G_m = G1*G2
        RSRP_PL_free_lin = P_Tx_2 * (lamda/(4*pi))^2 * abs( G_both_l ./ ( dist_3D.^2 ) ) ;
        RSRP_PL_free = 10*log10(RSRP_PL_free_lin) ;
    end
    
end
