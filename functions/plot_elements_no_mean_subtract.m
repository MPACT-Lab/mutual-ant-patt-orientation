function [legends1, legends2] = plot_elements_no_mean_subtract(fig_rows,fig_cols,i_run,power_all,RSRP_PL_free,RSRP_PL_two,dist_3D, ori_all, roll_all, pitch_all, azim, elev, lats, lons, hs, speeds,exp_no,location,color,marker,name,legends1,legends2,num_method,use_fspl,rcv_azimuth_arm_len, pitch_towards_src, arm_len, roll_towards_src)
    figure(1)
    subplot(fig_rows,fig_cols,i_run)
    hold on
    shadow1 = power_all - RSRP_PL_free;
    shadow2 = power_all - RSRP_PL_two;

    scaler = 111139 ;
    numMarkers = 10;

    markerLineStyleOnly = regexp(marker, '-*', 'match'); % '--s'
    markerOnly = marker(~ismember(marker, [markerLineStyleOnly{:}])); %'s'
    markerLineStyleOnly = markerLineStyleOnly{1}; % '--'
    %disp(markerOnly)


    if nargin<25
        fspl = 0;
        twpl = 1;
    else
        fspl = use_fspl;
        twpl = 1-use_fspl;
    end

    plot_shadow = 0;
    plot_abs_error = 1;

    subtract_mean = 0;

    if subtract_mean
        shadow1 = shadow1 - mean(shadow1);
        shadow2 = shadow2 - mean(shadow2);
    end

    if plot_abs_error>0
        shadow1 = abs(shadow1);
        shadow2 = abs(shadow2);
        xlim0 = 0;
        xlabel_text = 'Absolute Error (dB)';
    else
        xlim0 = -50;
        xlabel_text = 'Prediction Error (dB)';
    end

    if fspl
        [f,xi] = ksdensity(shadow1);  % Kernel density estimation
        active_shadow = shadow1;
        active_PL = RSRP_PL_free;
    else
        [f,xi] = ksdensity(shadow2);  % Kernel density estimation
        active_shadow = shadow2;
        active_PL = RSRP_PL_two;
    end
    
    if fspl
        [f, xi] = ecdf(shadow1); % Empirical CDF
        %h1 = cdfplot(shadow1);
        h1 = plot(xi, f, markerLineStyleOnly, 'Color', color, 'MarkerSize', 1,  'HandleVisibility', 'off');
        xlim([xlim0,50])
        set(h1, 'LineWidth', 2.0); %, 'Color', color, 'LineStyle', marker);  % Blue line for data1
        legends1 = [legends1, "FSPL "+name];
        hold on
        if length(markerOnly)>0
            [xi_sub, f_sub] = findequalspacedsubarray(xi,f,numMarkers,xlim0+num_method,50+num_method);
            %scatter(xi_sub, f_sub, 40, 'd', 'MarkerEdgeColor', color, 'LineWidth', 2.0, 'HandleVisibility', 'off');
            plot(xi_sub, f_sub, markerOnly, 'MarkerSize', 8, 'MarkerEdgeColor', color, 'MarkerFaceColor', 'none', 'HandleVisibility', 'off'); % Overlay markers
        end
        % dummy plot for legend
        plot([55,60],[0.5,1.0],marker,'Color',color,'MarkerEdgeColor',color)
    end
    hold on;
    if twpl
        [f, xi] = ecdf(shadow2); % Empirical CDF
        %h1 = cdfplot(shadow1);
        h1 = plot(xi, f, markerLineStyleOnly, 'Color', color, 'MarkerSize', 1,  'HandleVisibility', 'off');
        xlim([xlim0,50])
        set(h1, 'LineWidth', 2.0); %, 'Color', color, 'LineStyle', marker);  % Blue line for data1
        legends1 = [legends1, "Two-ray "+name];
        hold on
        if length(markerOnly)>0
            [xi_sub, f_sub] = findequalspacedsubarray(xi,f,numMarkers,xlim0+num_method,50+num_method);
            %scatter(xi_sub, f_sub, 40, 'd', 'MarkerEdgeColor', color, 'LineWidth', 2.0, 'HandleVisibility', 'off');
            plot(xi_sub, f_sub, markerOnly, 'MarkerSize', 8, 'MarkerEdgeColor', color, 'MarkerFaceColor', 'none', 'HandleVisibility', 'off'); % Overlay markers
        end
        % dummy plot for legend
        plot([55,60],[0.5,1.0],marker,'Color',color,'MarkerEdgeColor',color)
    end
    xlabel(xlabel_text);
    ylabel('CDF');
    xlim([xlim0,50])
    ylim([0,1])
    grid on
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    legend(legends1, 'Location', 'southeast', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    

    figure(10)
    subplot(fig_rows,fig_cols,i_run)
    [f, xi] = ksdensity(active_shadow); % Kernel density estimate
    h1 = plot(xi, f, 'LineWidth', 2);
    hold on
    set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    hold on
    xlim([xlim0,50])
    xlabel(xlabel_text);
    ylabel('PDF');
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    %disp(legends1)
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis

    figure(2)
    subplot(fig_rows,fig_cols,i_run)
    
    if num_method==1
        h1 = scatter(dist_3D, power_all, 5, 'g');
        %set(h1, 'LineWidth', 1, 'Color', "g", 'LineStyle', marker);  % Blue line for data1
        legends2 = [legends2, "Measured "];
    end
    hold on

    if num_method==1
        select_marker = 'x';
    else
        select_marker = '+';
    end
    
    hold on;
    if fspl
        h2 = scatter(dist_3D, RSRP_PL_free, 5, color, 'Marker', select_marker);
        %set(h2, 'LineWidth', 1, 'Color', color, 'LineStyle', marker);  % Blue line for data1
        legends2 = [legends2, "FSPL "+name];
    end
    if twpl
        h3 = scatter(dist_3D, RSRP_PL_two, 5, color, 'Marker', select_marker);
        %set(h3, 'LineWidth', 1, 'Color', color, 'LineStyle', marker);  % Red line for data2
        legends2 = [legends2, "Two-ray "+name];
    end
    
    % Add title and labels
    xlabel('3D Distance (m)');
    ylabel('RSRP (dB)');
    xlim([30, 330])
    ylim([-60, 50])
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    set(gca, 'FontSize', 14); % Change font size for the current axis
    
    % Add legend
    legend(legends2, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');

    if num_method == 20
        figure(3)
        subplot(fig_rows,fig_cols,i_run)
        plot_heatmap(azim*180/pi, elev*180/pi, shadow1, 'Azimuth[deg]', 'Elev[deg]', 'Shadow(dB)')
        xlim([-180, 180])
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))

        ori_all = ori_all - 360 * (ori_all>180);

        figure(4)
        subplot(fig_rows,fig_cols,i_run)
        plot_heatmap(azim*180/pi, roll_all, shadow1, 'Azimuth[deg]', 'Roll[deg]', 'Shadow(dB)')
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))
        xlim([-180, 180])

        figure(5)
        subplot(fig_rows,fig_cols,i_run)
        plot_heatmap(azim*180/pi, ori_all, shadow1, 'Azimuth[deg]', 'Yaw[deg]', 'Shadow(dB)')
        xlim([-180, 180])
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))

        figure(6)
        subplot(fig_rows,fig_cols,i_run)
        plot_heatmap(azim*180/pi, pitch_all, shadow1, 'Azimuth[deg]', 'Pitch[deg]', 'Shadow(dB)')
        xlim([-180, 180])
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))

        figure(7)
        subplot(fig_rows,fig_cols,i_run)
        plot_heatmap(azim*180/pi, speeds, shadow1, 'Azimuth[deg]', 'Speed[m/s]', 'Shadow(dB)')
        xlim([-180, 180])
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))


        figure(8)
        subplot(fig_rows,fig_cols,i_run)
        plot_heatmap(elev*180/pi, roll_all, shadow1, 'Elev[deg]', 'Roll[deg]', 'Shadow(dB)')
        xlim([0, 90])
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))

        figure(9)
        subplot(fig_rows,fig_cols,i_run)
        plot_heatmap(elev*180/pi, ori_all, shadow1, 'Elev[deg]', 'Yaw[deg]', 'Shadow(dB)')
        xlim([0, 90])
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))

        figure(10)
        subplot(fig_rows,fig_cols,i_run)
        plot_heatmap(elev*180/pi, pitch_all, shadow1, 'Elev[deg]', 'Pitch[deg]', 'Shadow(dB)')
        xlim([0, 90])
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))

        figure(11)
        subplot(fig_rows,fig_cols,i_run)
        plot_heatmap(elev*180/pi, speeds, shadow1, 'Elev[deg]', 'Speed[m/s]', 'Shadow(dB)')
        xlim([0, 90])
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    end

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

    if num_method==4

        num_segments = 8;
        dur_len_step = ceil(length(lats)/num_segments); % 10 categories

        figure(20)
        subplot(fig_rows,fig_cols,i_run)
        hold on
        grid on
        %cmap = jet(num_segments);
        cmap = jet;
        x1=-78.69953825817279;
        y1= 35.72688213193035;
        x2=-78.69621514941473;
        y2=35.72931030026633;
        scatter(scaler*(lons-x1),scaler*(lats-y1),4,(1:length(lats))/30);
        %scatter3(lons,lats,hs,8,floor((1:length(lats))/dur_len_step)) % 
        scatter(scaler*(origin_x-x1),scaler*(origin_y-y1),10,0,'MarkerEdgeColor', 'red')
        scatter(scaler*(origin_x-x1),scaler*(origin_y-y1),100,0, 'MarkerEdgeColor', 'red')
        colormap(cmap);
        colorbar;
        %xlabel('Longitude')
        %ylabel('Latitude')
        zlabel('Altitude')
        xlabel('X [m]')
        ylabel('Y [m]')
        xlim([-10, 400])
        ylim([-10, 350])
        hcb=colorbar;
        colorTitleHandle = get(hcb,'Title');
        titleString = 'Time (sec)';
        set(colorTitleHandle ,'String',titleString);
        set(gca, 'FontSize', 14); % Change font size for the current axis
        % x1=-78.69953825817279;
        % y1= 35.72688213193035;
        % x2=-78.69621514941473;
        % y2=35.72931030026633;
        %rectangle('Position',[x1 y1 (x2-x1) (y2-y1)])
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))

        figure(21)
        subplot(fig_rows,fig_cols,i_run)
        hold on
        grid on
        scatter3(lons,lats,hs,8,active_shadow)
        %scatter3(lons,lats,hs,8,power_all)
        scatter3(origin_x,origin_y,0,10,0)
        scatter3(origin_x,origin_y,0,100,0)
        colormap("jet");
        colorbar;
        xlabel('Longitude')
        ylabel('Latitude')
        zlabel('Altitude')
        clim([-50,50])
        hcb=colorbar;
        colorTitleHandle = get(hcb,'Title');
        titleString = 'Shadow (dB)';
        %titleString = 'RSRP (dB)';
        set(colorTitleHandle ,'String',titleString);
        % x1=-78.69953825817279;
        % y1= 35.72688213193035;
        % x2=-78.69621514941473;
        % y2=35.72931030026633;
        rectangle('Position',[x1 y1 (x2-x1) (y2-y1)])
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))


        figure(22)
        subplot(fig_rows,fig_cols,i_run)
        hold on
        grid on
        cmap = jet(num_segments);
        %scatter3(dist_3D, active_PL,hs,8,floor((1:length(lats))/dur_len_step))
        scatter3(dist_3D, power_all,hs,8,floor((1:length(lats))/dur_len_step))
        colormap(cmap);
        colorbar;
        xlabel('3D Distance [m]')
        ylabel('RSRP [dB]')
        zlabel('Altitude')
        xlim([70, 400])
        ylim([-60, 25])
        hcb=colorbar;
        colorTitleHandle = get(hcb,'Title');
        titleString = 'Time';
        set(colorTitleHandle ,'String',titleString);
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))

        figure(23)
        subplot(fig_rows,fig_cols,i_run)
        hold on
        grid on
        cmap = jet(num_segments);
        scatter3(dist_3D, power_all,hs,8,floor((1:length(lats))/dur_len_step))
        colormap(cmap);
        colorbar;
        xlabel('3D Distance [m]')
        ylabel('RSRP [dB]')
        zlabel('Altitude')
        xlim([70, 400])
        hcb=colorbar;
        colorTitleHandle = get(hcb,'Title');
        titleString = 'Time';
        set(colorTitleHandle ,'String',titleString);
        %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    end
    
    % dist vs cum error
    figure(30)
    subplot(fig_rows,fig_cols,i_run)
    [sorted_dist, sort_idx] = sort(dist_3D);
    sorted_actv_shadow = active_shadow(sort_idx);
    adjusted_err = zeros(size(sorted_actv_shadow));
    adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    h1 = plot(sorted_dist, cum_adjusted_err, 'LineWidth', 2);
    hold on
    set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    hold on
    xlim([50,330])
    xlabel('3D Distance [m]');
    ylabel('Cumulative Absolute Error [dB]');
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    %disp(legends1)
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    grid on
    
    % azim vs cum error
    figure(31)
    subplot(fig_rows,fig_cols,i_run)
    [sorted_dist, sort_idx] = sort(azim);
    sorted_actv_shadow = active_shadow(sort_idx);
    adjusted_err = zeros(size(sorted_actv_shadow));
    adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    h1 = plot(sorted_dist*180/pi, cum_adjusted_err, 'LineWidth', 2);
    hold on
    set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    hold on
    %xlim([50,330])
    xlabel('Azimuth [degree]');
    ylabel('Cumulative Absolute Error [dB]');
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    %disp(legends1)
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    grid on
    
    % % elev vs cum error
    % figure(32)
    % subplot(fig_rows,fig_cols,i_run)
    % [sorted_dist, sort_idx] = sort(elev);
    % sorted_actv_shadow = active_shadow(sort_idx);
    % adjusted_err = zeros(size(sorted_actv_shadow));
    % adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    % cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    % h1 = plot(sorted_dist*180/pi, cum_adjusted_err, 'LineWidth', 2);
    % hold on
    % set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    % hold on
    % %xlim([50,330])
    % xlabel('Elevation [degree]');
    % ylabel('Cumulative Absolute Error [dB]');
    % %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    % %disp(legends1)
    % legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    % set(gca, 'FontSize', 14); % Change font size for the current axis
    % grid on

    % elev vs error (not cdf, not pdf, x vs MAE)
    figure(32)
    subplot(fig_rows,fig_cols,i_run)
    [sorted_dist, sort_idx] = sort(elev);
    sorted_actv_shadow = active_shadow(sort_idx);
    [x_centers, mae_err] = grid_moving_avg(sorted_dist*180/pi, sorted_actv_shadow, 0, 90, 0.01, 6);
    yyaxis left;
    plot(x_centers, mae_err, 'LineWidth', 2, 'Color', color, 'LineStyle', '-', 'Marker','none');
    hold on
    %set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', '-');  % Blue line for data1 markerLineStyleOnly
    hold on
    %xlim([50,330])
    xlabel('Elevation, \boldmath$\theta_\mathrm{u}$ [degree]', 'Interpreter', 'latex');
    ylabel('Mean Absolute Error [dB]', 'Interpreter', 'latex');
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    xlim([0,90])
    %axis tight
    grid on
    if num_method==2
        light_violet = [0.5, 0.3, 0.8];  % Example RGB for light violet
        yyaxis right;
        [f, xi] = ksdensity(sorted_dist*180/pi);  % Scaling data as in your example
        fill([xi, fliplr(xi)], [f, zeros(size(f))], light_violet, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        %hold on;
        %plot(xi, f, 'LineWidth', 1);
        % Set the y-axis color to light violet
        ax = gca;
        ax.YAxis(2).Color = light_violet;  % Set the right y-axis color
        ylabel('Probability Density'); % Label for the right y-axis
        % Set the limits for the right y-axis (adjust as needed)
        %ylim([0 2.0]);
    end

    % roll vs cum error
    figure(33)
    subplot(fig_rows,fig_cols,i_run)
    [sorted_dist, sort_idx] = sort(roll_all);
    sorted_actv_shadow = active_shadow(sort_idx);
    adjusted_err = zeros(size(sorted_actv_shadow));
    adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    h1 = plot(sorted_dist, cum_adjusted_err, 'LineWidth', 2);
    hold on
    set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    hold on
    %xlim([50,330])
    xlabel('Roll [degree]');
    ylabel('Cumulative Absolute Error [dB]');
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    %disp(legends1)
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    axis tight
    grid on

    % pitch vs cum error
    figure(34)
    subplot(fig_rows,fig_cols,i_run)
    [sorted_dist, sort_idx] = sort(pitch_all);
    sorted_actv_shadow = active_shadow(sort_idx);
    adjusted_err = zeros(size(sorted_actv_shadow));
    adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    h1 = plot(sorted_dist, cum_adjusted_err, 'LineWidth', 2);
    hold on
    set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    hold on
    %xlim([50,330])
    xlabel('Pitch [degree]');
    ylabel('Cumulative Absolute Error [dB]');
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    %disp(legends1)
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    axis tight
    grid on

    % speed vs cum error
    figure(35)
    subplot(fig_rows,fig_cols,i_run)
    [sorted_dist, sort_idx] = sort(speeds);
    sorted_actv_shadow = active_shadow(sort_idx);
    adjusted_err = zeros(size(sorted_actv_shadow));
    adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    h1 = plot(sorted_dist, cum_adjusted_err, 'LineWidth', 2);
    hold on
    set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    hold on
    %xlim([50,330])
    xlabel('Speed [m/s]');
    ylabel('Cumulative Absolute Error [dB]');
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    %disp(legends1)
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    axis tight
    grid on

    % rcv_azim (arm len) vs cum error
    figure(36)
    subplot(fig_rows,fig_cols,i_run)
    [sorted_dist, sort_idx] = sort(rcv_azimuth_arm_len);
    sorted_actv_shadow = active_shadow(sort_idx);
    adjusted_err = zeros(size(sorted_actv_shadow));
    adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    h1 = plot(sorted_dist*180/pi, cum_adjusted_err, 'LineWidth', 2);
    hold on
    set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    hold on
    %xlim([50,330])
    xlabel('Azim_rcv [degree]');
    ylabel('Cumulative Absolute Error [dB]');
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    %disp(legends1)
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    grid on

    % pitch_src vs cum error
    figure(37)
    subplot(fig_rows,fig_cols,i_run)
    [sorted_dist, sort_idx] = sort(pitch_towards_src);
    sorted_actv_shadow = active_shadow(sort_idx);
    adjusted_err = zeros(size(sorted_actv_shadow));
    adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    h1 = plot(sorted_dist*180/pi, cum_adjusted_err, 'LineWidth', 2);
    hold on
    set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    hold on
    %xlim([50,330])
    xlabel('Tilt Towards Source [degree]');
    ylabel('Cumulative Absolute Error [dB]');
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    %disp(legends1)
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    axis tight
    grid on

    % % pitch_src vs cum error (pdf)
    % figure(37)
    % subplot(fig_rows,fig_cols,i_run)
    % [sorted_dist, sort_idx] = sort(pitch_towards_src);
    % sorted_actv_shadow = active_shadow(sort_idx);
    % adjusted_err = zeros(size(sorted_actv_shadow));
    % adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    % cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    % % calc pdf
    % x_pdf = -12.01:0.01: 12;
    % y_cdf = interp1(sorted_dist*180/pi, cum_adjusted_err, x_pdf, 'linear');
    % x_pdf = x_pdf(2:end);
    % y_pdf = y_cdf(2:end) - y_cdf(1:end-1);
    % h1 = plot(x_pdf, movmean(y_pdf, 100), 'LineWidth', 2);
    % hold on
    % set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    % hold on
    % %xlim([50,330])
    % xlabel('Tilt Towards Source [degree]');
    % ylabel('pdf of Cumulative Absolute Error [dB]');
    % %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    % %disp(legends1)
    % legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    % set(gca, 'FontSize', 14); % Change font size for the current axis
    % axis tight
    % grid on

    % % pitch_src vs error (not cdf, not pdf, x vs MAE)
    % figure(37)
    % subplot(fig_rows,fig_cols,i_run)
    % [sorted_dist, sort_idx] = sort(pitch_towards_src);
    % sorted_actv_shadow = active_shadow(sort_idx);
    % [x_centers, mae_err] = grid_moving_avg(sorted_dist*180/pi, sorted_actv_shadow, -12, 12, 0.01, 1.5);
    % yyaxis left;
    % plot(x_centers, mae_err, 'LineWidth', 2, 'Color', color, 'LineStyle', '-', 'Marker','none');
    % hold on
    % %set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', '-');  % Blue line for data1 markerLineStyleOnly
    % hold on
    % %xlim([50,330])
    % xlabel('Tilt Towards Source [degree]');
    % ylabel('Mean Absolute Error [dB]');
    % legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    % set(gca, 'FontSize', 14); % Change font size for the current axis
    % xlim([-12,12])
    % %axis tight
    % grid on
    % if num_method==5
    %     light_violet = [0.5, 0.3, 0.8];  % Example RGB for light violet
    %     yyaxis right;
    %     [f, xi] = ksdensity(sorted_dist*180/pi);  % Scaling data as in your example
    %     fill([xi, fliplr(xi)], [f, zeros(size(f))], light_violet, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    %     %hold on;
    %     %plot(xi, f, 'LineWidth', 1);
    %     % Set the y-axis color to light violet
    %     ax = gca;
    %     ax.YAxis(2).Color = light_violet;  % Set the right y-axis color
    %     ylabel('Probability Density'); % Label for the right y-axis
    %     % Set the limits for the right y-axis (adjust as needed)
    %     ylim([0 2.0]);
    % end


    % arm_len vs cum error
    figure(38)
    subplot(fig_rows,fig_cols,i_run)
    [sorted_dist, sort_idx] = sort(arm_len);
    sorted_actv_shadow = active_shadow(sort_idx);
    adjusted_err = zeros(size(sorted_actv_shadow));
    adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    h1 = plot(sorted_dist, cum_adjusted_err, 'LineWidth', 2);
    hold on
    set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    hold on
    %xlim([50,330])
    xlabel('Reflection Distance [m]');
    ylabel('Cumulative Absolute Error [dB]');
    xlim([-12,12])
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    %disp(legends1)
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    grid on

    % % arm_len vs cum error (pdf)
    % figure(38)
    % subplot(fig_rows,fig_cols,i_run)
    % [sorted_dist, sort_idx] = sort(arm_len);
    % sorted_actv_shadow = active_shadow(sort_idx);
    % adjusted_err = zeros(size(sorted_actv_shadow));
    % adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    % cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    % % calc pdf
    % x_pdf = -12.01:0.01:12;
    % y_cdf = interp1(sorted_dist, cum_adjusted_err, x_pdf, 'linear');
    % x_pdf = x_pdf(2:end);
    % y_pdf = y_cdf(2:end) - y_cdf(1:end-1);
    % h1 = plot(x_pdf, movmean(y_pdf, 100), 'LineWidth', 2);
    % hold on
    % set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    % hold on
    % %xlim([50,330])
    % xlabel('Reflection Distance [m]');
    % ylabel('Cumulative Absolute Error pdf [dB]');
    % xlim([-12,12])
    % %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    % %disp(legends1)
    % legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    % set(gca, 'FontSize', 14); % Change font size for the current axis
    % grid on


    % % arm_len vs error (not cdf, not pdf, x vs MAE)
    % figure(38)
    % subplot(fig_rows,fig_cols,i_run)
    % [sorted_dist, sort_idx] = sort(arm_len);
    % sorted_actv_shadow = active_shadow(sort_idx);
    % [x_centers, mae_err] = grid_moving_avg(sorted_dist, sorted_actv_shadow, -12, 12, 0.01, 1.5);
    % yyaxis left;
    % plot(x_centers, mae_err, 'LineWidth', 2, 'Color', color, 'LineStyle', '-', 'Marker','none');
    % hold on
    % %set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', '-');  % Blue line for data1 markerLineStyleOnly
    % hold on
    % %xlim([50,330])
    % xlabel('Reflection Distance [m]');
    % ylabel('Mean Absolute Error [dB]');
    % legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    % set(gca, 'FontSize', 14); % Change font size for the current axis
    % xlim([-12,12])
    % %axis tight
    % grid on
    % if num_method==5
    %     light_violet = [0.5, 0.3, 0.8];  % Example RGB for light violet
    %     yyaxis right;
    %     %histogram(sorted_dist, 'Normalization', 'pdf', 'FaceAlpha', 0.5, 'FaceColor', light_violet);
    %     sorted_dist_modified = sorted_dist;
    %     sorted_dist_modified(sorted_dist_modified>10) = 10;
    %     sorted_dist_modified(sorted_dist_modified<-10) = -10;
    %     [f, xi] = ksdensity(sorted_dist_modified, 'NumPoints',2000);  % Scaling data as in your example
    %     fill([xi, fliplr(xi)], [f, zeros(size(f))], light_violet, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    %     hold on;
    %     %plot(xi, f, 'LineWidth', 1);
    %     % Set the y-axis color to light violet
    %     ax = gca;
    %     ax.YAxis(2).Color = light_violet;  % Set the right y-axis color
    %     ylabel('Probability Density'); % Label for the right y-axis
    %     % Set the limits for the right y-axis (adjust as needed)
    %     ylim([0 2.0]);
    % end


    % acceleration vs cum error
    figure(39)
    acclrns = zeros(size(speeds));
    acclrns(2:end) = (speeds(2:end)-speeds(1:end-1))*30;
    subplot(fig_rows,fig_cols,i_run)
    [sorted_acclrn, sort_idx] = sort(acclrns);
    sorted_actv_shadow = active_shadow(sort_idx);
    adjusted_err = zeros(size(sorted_actv_shadow));
    adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    h1 = plot(sorted_acclrn, cum_adjusted_err, 'LineWidth', 2);
    hold on
    set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    hold on
    %xlim([50,330])
    xlabel('Acceleration [m/s^2]');
    ylabel('Cumulative Absolute Error [dB]');
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    %disp(legends1)
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    axis tight
    grid on

    % figure(40)
    % scatter(sorted_acclrn,pitch_towards_src(sort_idx),4)
    % xlabel('Acceleration [m/s^2]');
    % ylabel('Tilt Towards Source [degree]');
    % set(gca, 'FontSize', 14); % Change font size for the current axis
    % axis tight

    % roll_src vs cum error
    figure(41)
    subplot(fig_rows,fig_cols,i_run)
    roll_towards_src = roll_towards_src + 2*pi*(roll_towards_src<-pi) - 2*pi*(roll_towards_src>pi);
    [sorted_dist, sort_idx] = sort(roll_towards_src);
    sorted_actv_shadow = active_shadow(sort_idx);
    adjusted_err = zeros(size(sorted_actv_shadow));
    adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    h1 = plot(sorted_dist*180/pi, cum_adjusted_err, 'LineWidth', 2);
    hold on
    set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    hold on
    xlim([-20,20])
    xlabel('Roll Towards Source [degree]');
    ylabel('Cumulative Absolute Error [dB]');
    %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    %disp(legends1)
    legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14); % Change font size for the current axis
    %axis tight
    grid on

    % % roll_src vs cum error (pdf)
    % figure(41)
    % subplot(fig_rows,fig_cols,i_run)
    % roll_towards_src = roll_towards_src + 2*pi*(roll_towards_src<-pi) - 2*pi*(roll_towards_src>pi);
    % [sorted_dist, sort_idx] = sort(roll_towards_src);
    % sorted_actv_shadow = active_shadow(sort_idx);
    % adjusted_err = zeros(size(sorted_actv_shadow));
    % adjusted_err(2:end) = sorted_actv_shadow(2:end);% .* (sorted_dist(2:end)-sorted_dist(1:end-1));
    % cum_adjusted_err = cumsum(abs(adjusted_err))/length(adjusted_err);
    % % calc pdf
    % x_pdf = -12.01:0.01: 12;
    % y_cdf = interp1(sorted_dist*180/pi, cum_adjusted_err, x_pdf, 'linear');
    % x_pdf = x_pdf(2:end);
    % y_pdf = y_cdf(2:end) - y_cdf(1:end-1);
    % h1 = plot(x_pdf, movmean(y_pdf, 100), 'LineWidth', 2);
    % hold on
    % set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', markerLineStyleOnly);  % Blue line for data1
    % hold on
    % xlim([-12,12])
    % xlabel('Roll Towards Source [degree]');
    % ylabel('Cumulative Absolute Error pdf [dB]');
    % %title("exp "+num2str(exp_no)+" loc "+num2str(location))
    % %disp(legends1)
    % legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    % set(gca, 'FontSize', 14); % Change font size for the current axis
    % %axis tight
    % grid on

    % % arm_len vs error (not cdf, not pdf, x vs MAE)
    % figure(41)
    % subplot(fig_rows,fig_cols,i_run)
    % roll_towards_src = roll_towards_src + 2*pi*(roll_towards_src<-pi) - 2*pi*(roll_towards_src>pi);
    % [sorted_dist, sort_idx] = sort(roll_towards_src);
    % sorted_actv_shadow = active_shadow(sort_idx);
    % [x_centers, mae_err] = grid_moving_avg(sorted_dist*180/pi, sorted_actv_shadow, -12, 12, 0.01, 1.5);
    % yyaxis left;
    % plot(x_centers, mae_err, 'LineWidth', 2, 'Color', color, 'LineStyle', '-', 'Marker','none');
    % hold on
    % %set(h1, 'LineWidth', 2, 'Color', color, 'LineStyle', '-');  % Blue line for data1 markerLineStyleOnly
    % hold on
    % %xlim([50,330])
    % xlabel('Roll Towards Source [degree]');
    % ylabel('Mean Absolute Error [dB]');
    % legend(legends1, 'Location', 'best', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    % set(gca, 'FontSize', 14); % Change font size for the current axis
    % xlim([-12,12])
    % %axis tight
    % grid on
    % if num_method==5
    %     light_violet = [0.5, 0.3, 0.8];  % Example RGB for light violet
    %     yyaxis right;
    %     [f, xi] = ksdensity(sorted_dist*180/pi);  % Scaling data as in your example
    %     fill([xi, fliplr(xi)], [f, zeros(size(f))], light_violet, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    %     %hold on;
    %     %plot(xi, f, 'LineWidth', 1);
    %     % Set the y-axis color to light violet
    %     ax = gca;
    %     ax.YAxis(2).Color = light_violet;  % Set the right y-axis color
    %     ylabel('Probability Density'); % Label for the right y-axis
    %     % Set the limits for the right y-axis (adjust as needed)
    %     ylim([0 2.0]);
    % end

    % arm_len cdf
    figure(42)
    % Define custom bins
    bins = -250:0.5:250; % Bins from -3 to 3 with a step size of 0.5
    subplot(fig_rows,fig_cols,i_run)
    histogram(arm_len,bins)
    xlabel('Reflection Distance [m]')
end

function [x_centers, mean_y] = grid_moving_avg(x, y, x_start, x_end, x_res, x_window)
    % Ensure column vectors
    x = x(:);
    y = y(:);

    % Define bin edges from min to max with given bin width
    min_x = x_start;
    max_x = x_end;
    x_centers = x_start:x_res:x_end;

    mean_y = zeros(size(x_centers));

    % Compute mean y for each bin
    for i = 1:length(x_centers)
        x_window_active = x_window;
        while(1)
            in_bin = x >= x_centers(i)-x_window_active/2 & x < x_centers(i)+x_window_active/2;
            if sum(in_bin) > 0
                break
            end
            x_window_active = x_window_active*2;
        end
        current_bin_start = x_centers(i)-x_window_active/2;
        current_bin_end = x_centers(i)+x_window_active/2;
        if i==1
            current_bin_start = -inf;
        end
        if i== length(x_centers)
            current_bin_end = inf;
        end
        in_bin = x >= current_bin_start & x < current_bin_end;

        mean_y(i) = mean(y(in_bin));

    end
end

