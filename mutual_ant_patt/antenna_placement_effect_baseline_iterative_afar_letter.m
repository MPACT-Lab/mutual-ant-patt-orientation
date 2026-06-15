clc;
clear;
close all;

addpath('functions\')
addpath('../functions\')
addpath("../data_gen\AFAR_dataset\processed_data\")

rng(32)
%rng(111)
%% this is for mutual antenna
exps = [309,328]; % for simplicity it will be named only on 309
%exps = [300];

locations = [2];

nk = 10;

mat_name = "patts/mutual_patt_afar_" + num2str(exps(1)) + "_" + num2str(locations(1)) + "_nk_" + num2str(nk) + ".mat";

% update ant patt for rx
all_az = [];
all_el = [];
all_az2 = [];
all_el2 = [];
all_mutual_gain = [];
for ii=1:length(exps)
    for jj=1:length(locations)
        exp_no = exps(ii);
        location = locations(jj);
        if exp_no==309 && location==1
            continue
        end

        load("../data_gen\AFAR_dataset\processed_data\results_useful_with_tworay_tilt_src_exp_"+num2str(exp_no)+"_loc_"+num2str(location)+".mat")
        [azim2, elev2] = get_uav_body_reflection_letter(azim,elev,ori_all,pitch_all,roll_all,dist_2D_new,h_all);

        %if i_iter<2
            RSRP_PL_zero_ant_gain = baseline_flipx_afar_letter(exp_no, location, 1, 0, "", 1, 0, 0, "zero");
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
k_azimuth = 4; % k_azimuth = 1 means 45 degree phase shift between tx and rx receiver
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

