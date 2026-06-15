clc;
clear;
close all;

addpath('functions\')
addpath('../functions\')
addpath("../data_gen/Multi_BW_dataset/raw_data/")
rng(32)
%% this is for mutual antenna
% ALEEEERRRTTTTTT: change the 40m/ 100m from mat_name definition as well
%altitudes = ["40m", "70m"]; % train 100m, test on 40m and 70m
altitudes = ["70m"]; % train 100m, test on 40m and 70m
%altitudes = ["40m","70m","100m"]; % for 5 MHZ polar plot
%fss = ["fs20MHz", "fs20MHz", "fs20MHz"]; % for 5 MHZ polar plot
%fss = ["fs20MHz", "fs20MHz"];
fss = ["fs20MHz"];

nk = 10;

% chnannnnnnnnnnnnnnngeeeeeeeeee here
mat_name = "flipx_antenna_tx_rx_updated_" + "40_70_20MHz" + "_smooth.mat"; % for propagation modeling
%mat_name = "flipx_antenna_tx_rx_updated_" + "40_70_100m_20MHz" + "_smooth.mat"; % for Kriging
mat_name = "flipx_antenna_tx_rx_updated_" + "70_20MHz" + ".mat"; % for propagation modeling
mat_name = "patts/mutual_patt_cole_" + altitudes(1) + "_" + fss(1) + "_nk_" + num2str(nk) + ".mat";

% update ant patt for rx
all_az = [];
all_el = [];
all_az2 = [];
all_el2 = [];
all_mutual_gain = [];
for ii=1:length(altitudes)
    altitude = altitudes(ii);
    fs = fss(ii);
    load(altitude + "_" + fs + ".mat") % basic data
    [lat_all,lon_all,h_all,power_all,power_all2,speed_allX,speed_allY,speed_allZ,...
    ori_all,roll_all,pitch_all,dist_2D_new,dist_3D,elev,azim,elev2,azim2] = get_refined_variables_cole_letter(mX, mY, mZ, mSpeedX, mSpeedY, mSpeedZ, mpower1,...
    mpower2, timestamp_power, mYaw, mRoll, mPitch);
    speed_all = speed_allX;

    %if i_iter<2
        RSRP_PL_zero_ant_gain = baseline_flipx_cole_letter(altitude, fs, 1, 0, "", 1, 0,0,"zero");
    %else
        %RSRP_PL_free = baseline_flipx_cole_letter(altitude, fs, 1, 0, "", 1, 0,0,mat_name);
    %end
    % -(phi_t + uav_yaw + 180)

    all_az = [all_az; azim];
    all_el = [all_el; elev];
    all_az2 = [all_az2; azim2];
    all_el2 = [all_el2; elev2];
    all_mutual_gain = [all_mutual_gain; power_all - RSRP_PL_zero_ant_gain];
end

verbose = 1;
% for i_iter=1, prev_patt and G_r_dB are same
[M_estimated, M_est_var, phi_grid, theta_grid, M_anec, phi_grid_anec, theta_grid_anec] = ant_place_effect_cole_letter(all_az,all_el,all_az2,all_el2,all_mutual_gain,nk,1,1,mat_name);

%% Mutual Antenna pat anechoic vs in-field measurement
% condition: iter_number must be 1, otherwise prev_patt will reflect
% intermidiate patt, Z also will be delta
% use [Z, prev_patt]
close all
offset = 40;

figure
histogram(all_mutual_gain(:))

figure
histogram(M_estimated(:))

figure
histogram(all_az(:)*180/pi)

figure
histogram(all_az2(:)*180/pi)

figure
histogram(all_el(:)*180/pi)

figure
histogram(all_el2(:)*180/pi)

%% 
k_azimuth = 1; % k_azimuth = 1 means 45 degree phase shift between tx and rx receiver
for k_d = -1:1 %-3:3

    M_slice = zeros(length(theta_grid),length(phi_grid)) * NaN;
    for ii=1:length(phi_grid)
        for jj=1:length(theta_grid)
            if (jj+k_d >= 1) && (jj+k_d <= length(theta_grid))
                M_slice(jj,ii) = M_estimated(jj,ii,jj+k_d,mod(ii+k_azimuth-1,length(phi_grid))+1);
            end
        end
    end
    
    % phase shift = k_azimuth*(360/length(phi_grid)) = k_azimuth_anec*(360/length(phi_grid_anec))
    k_azimuth_anec = k_azimuth*length(phi_grid_anec)/length(phi_grid);
    M_slice_anec = zeros(length(theta_grid_anec),length(phi_grid_anec)) * NaN;
    for ii=1:length(phi_grid_anec)
        for jj=1:length(theta_grid_anec)
            if (jj+k_d >= 1) && (jj+k_d <= length(theta_grid_anec))
                M_slice_anec(jj,ii) = M_anec(jj,ii,jj+k_d,mod(ii+k_azimuth_anec-1,length(phi_grid_anec))+1);
            end
        end
    end

    % if altitude=="40m"
    %     elMax = 10;
    % elseif altitude=="70m"
    %     elMax = 20;
    % else
    %     elMax = 30;
    % end
    
    % make this adaptive
    theta_filter = ~isnan(nanmean(M_slice,2));
    
    fig = figure;
    fig.Position = [680   629   440   349];
    polarplot(theta_grid_anec,max(mean(M_slice_anec+offset,2,'omitnan'),0),'--', 'DisplayName', 'Radiation Pattern (Isolated)','LineWidth',2)
    hold on;
    polarplot(theta_grid(theta_filter),max(mean(M_slice(theta_filter,:)+offset,2,'omitnan'),0), 'DisplayName', 'Radiation Pattern (Platform-Integrated)','LineWidth',2)
    hold on;
    set(gcf,'color','w');
    rlim([0 45])
    %rticks([-35:10:5])
    legend('Location', 'best');  % Adjust the label location as needed
    % Increase figure text size
    set(gca, 'FontSize', 14);  % Set the axis labels' font size
end

