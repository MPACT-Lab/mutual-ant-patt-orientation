function RSRP_PL_free = baseline_flipx_cole_letter(altitude, fs, use_ground_relfec, save, save_name, use_ori, correct_uav_angle, unknown_angle, ant_filename)
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

    ugv_angle = 120*pi/180; % optimized BS orientation to match with measured antenna pattern

    matdata = load(altitude+"_"+fs+".mat");
    %save_filename = "data_mat/"+height+"_"+fs+".mat";
    %save(save_filename, 'mX', 'mY', 'mZ', 'mSpeedX', 'mSpeedY', 'mSpeedZ', 'mpower1', 'mpower2', 'timestamp_power', 'timestamp_power_for_csv', 'mYaw', 'mRoll', 'mPitch')
    
    scaler = 111139 ;
    R_earth = 6378.137 * 10^3 ; % [m]

    [lat_all,lon_all,h_all,power_all,power_all2,speed_allX,speed_allY,speed_allZ,...
    ori_all,roll_all,pitch_all,dist_2D_new,dist_3D,elev,azim,elev2,azim2] = get_refined_variables_cole_letter(matdata.mX, matdata.mY, matdata.mZ,...
    matdata.mSpeedX, matdata.mSpeedY, matdata.mSpeedZ, matdata.mpower1,...
    matdata.mpower2, matdata.timestamp_power, matdata.mYaw, matdata.mRoll, matdata.mPitch);

    
%     ori_all = ori_all-50; % to match with known antenna pattern of the Rx antenna
%     ori_all = ori_all - 360 .* (ori_all>=180) + 360 .* (ori_all<-180);
    
    N_sam = length(power_all);
    

    %% 
    h_UAV_new = h_all;
    h_BS = 10;
    P_Tx_dBm = 70 ; % [dBm]
    c = 3.0e8;
    f0 = 3.3e9; % what is the actual f0 here
    lamda = c/f0;

    unknown_offset = 0;
    P_Tx_2_dBm = P_Tx_dBm + unknown_offset ;
    P_Tx_2 = 10.^(P_Tx_2_dBm/10) ;
    
    %% Antenna pattern
    if ant_filename == "zero"
        disp('no antenna pattern will be used')
        RSRP_PL_free_lin = P_Tx_2 * (lamda/(4*pi))^2 ./ ( dist_3D.^2 ) ;
        RSRP_PL_free = 10*log10(RSRP_PL_free_lin) ;
    else
        if ant_filename == "default"
            load rad_pat.mat
            G_t_dB = RMWB3300_normal; %RMWB3300_upside_down; % considering SA3300 is for tx mode (right side up)
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
            G_t_dB = RMWB3300_normal; %RMWB3300_upside_down; % considering SA3300 is for tx mode (right side up)
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
