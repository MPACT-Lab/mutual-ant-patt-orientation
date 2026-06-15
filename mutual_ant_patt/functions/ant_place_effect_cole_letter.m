function [M_estimated, M_est_var, phi_grid, theta_grid, M_anec, phi_grid_anec, theta_grid_anec] = ant_place_effect_cole_letter(all_az,all_el,all_az2,all_el2,error_all,nk,save_patt, verbose, save_name)
%ANT_PLACE_EFFECT Summary of this function goes here
%   Detailed explanation goes here
all_shadow = error_all;
%% plot
if verbose
    figure
    scatter(all_az, all_el, 50, all_shadow, 'filled'); % 'filled' option fills the markers
    %caxis([-50,20])
    
    % Adding labels and title
    xlabel('Azimuth [deg]');
    ylabel('Elevation [deg]');
    title('Shadow Fading (dB)');
    colormap(jet);
    % Adding a colorbar
    colorbar;
end

%% interpolation
phi_grid = [135,45,-45,-135]*pi/180;
d_grid_phi = 45*pi/180;
theta_grid = (90:-5:-90)*pi/180;
d_grid_theta = 5*pi/180;
%theta_grid_full = (90:-3:-90)*pi/180;
% phi_grid = (-177:3:180)*pi/180;
% theta_grid = (0:3:90)*pi/180;
% theta_grid_full = (-90:3:90)*pi/180;


% outputs meshgrid(x,y) have the size of (Ny,Nx)
% outputs ndgrid(x,y) have the size of (Nx,Ny)
[phi_mesh,theta_mesh,phi_mesh2,theta_mesh2] = ndgrid(theta_grid,phi_grid,theta_grid,phi_grid);

Z = zeros(size(phi_mesh))*NaN;
Z_var = zeros(size(phi_mesh))*NaN;
for ii=1:length(phi_grid)
    for jj=1:length(theta_grid)
        for ii2=1:length(phi_grid)
            for jj2=1:length(theta_grid)
                phi_this = phi_grid(ii);
                theta_this = theta_grid(jj);
                phi_this2 = phi_grid(ii2);
                theta_this2 = theta_grid(jj2);
                shadow_this = all_shadow((abs(all_az-phi_this)<d_grid_phi) & (abs(all_el-theta_this)<d_grid_theta)...
                    &(abs(all_az2-phi_this2)<d_grid_phi) & (abs(all_el2-theta_this2)<d_grid_theta));
                if (length(shadow_this)>=nk)
                    shadow_this_selected = randperm(length(shadow_this),nk);
                    Z(jj,ii,jj2,ii2) = mean(shadow_this(shadow_this_selected)); % mean([]) will be nan
                    Z_var(jj,ii,jj2,ii2) = var(shadow_this_selected);
                end
            end
        end
    end
end

% for ii=1
%     for jj=17
%         for ii2=4
%             for jj2=22
%                 phi_this = phi_grid(ii);
%                 theta_this = theta_grid(jj);
%                 phi_this2 = phi_grid(ii2);
%                 theta_this2 = theta_grid(jj2);
%                 shadow_this = all_shadow((abs(all_az-phi_this)<d_grid_phi) & (abs(all_el-theta_this)<d_grid_theta)...
%                     &(abs(all_az2-phi_this2)<d_grid_phi) & (abs(all_el2-theta_this2)<d_grid_theta));
%                  fprintf("%.2f %.2f %.2f %.2f\n", (all_az(506))*180/pi, (all_el(506))*180/pi,...
%                     (all_az2(506))*180/pi, (all_el2(506))*180/pi)
%                 fprintf("%.2f %.2f %.2f %.2f\n", (phi_this)*180/pi, (theta_this)*180/pi,...
%                     (phi_this2)*180/pi, (theta_this2)*180/pi)
%                 fprintf("%.2f %.2f %.2f %.2f\n", (all_az(506)-phi_this)*180/pi, (all_el(506)-theta_this)*180/pi,...
%                     (all_az2(506)-phi_this2)*180/pi, (all_el2(506)-theta_this2)*180/pi)
% %                 if (length(shadow_this)>=nk)
% %                     shadow_this_selected = randperm(length(shadow_this),nk);
% %                     Z(jj,ii,jj2,ii2) = mean(shadow_this(shadow_this_selected)); % mean([]) will be nan
% %                     Z_var(jj,ii,jj2,ii2) = var(shadow_this_selected);
% %                 end
%                 fprintf("found length %d\n", length(shadow_this))
%             end
%         end
%     end
% end

% Z_filled = inpaint_nans(Z,1);
% % % Z_filled = Z;
% % % Z_filled(isnan(Z_filled)) = 0;
% % Define Gaussian kernel parameters
% sigma = 3; % Standard deviation of the Gaussian
% filterSize = 15; % Size of the filter (e.g., 5x5)
% gaussianKernel = fspecial('gaussian', filterSize, sigma);
% Z_filled = conv2(Z_filled, gaussianKernel, 'same'); % 'same' keeps output size
% Z_filled = conv2(Z_filled, gaussianKernel, 'same'); % 'same' keeps output size

if verbose
    for k_d = -3:3
        Z_slice = zeros(length(theta_grid),length(phi_grid)) * NaN;
        for ii=1:length(phi_grid)
            for jj=1:length(theta_grid)
                if (jj+k_d >= 1) && (jj+k_d <= length(theta_grid))
                    Z_slice(jj,ii) = Z(jj,ii,jj+k_d+ii);
                end
            end
        end
    
        figure
        mesh(phi_grid*180/pi,theta_grid*180/pi,Z_slice,'FaceColor','flat')
        % Adding labels and title
        xlabel('Azimuth [deg]');
        ylabel('Elevation [deg]');
        title('Shadow Fading (dB)');
        colormap(jet);
        % Adding a colorbar
        colorbar
        %caxis([-50,20])
        view(2)
        
        % figure
        % histogram(Z(:))
        % 
        % figure
        % histogram(Z_filled(:))
    end
end

M_estimated = Z;
M_est_var = Z_var;

load rad_pat.mat
G_r_dB = SA3300; % G_r_dB SA3300
G_t_dB = RMWB3300_normal; %RMWB3300_upside_down; % considering SA3300 is for tx mode (right side up)

phi_grid_anec = (180:-3:-177)*pi/180;
theta_grid_anec = (90:-3:-90)*pi/180;

[phi_mesh,theta_mesh,phi_mesh2,theta_mesh2] = ndgrid(theta_grid_anec,phi_grid_anec,theta_grid_anec,phi_grid_anec);

M_anec = zeros(size(phi_mesh));
for ii=1:length(phi_grid_anec)
    for jj=1:length(theta_grid_anec)
        for ii2=1:length(phi_grid_anec)
            for jj2=1:length(theta_grid_anec)
                M_anec(jj,ii,jj2,ii2) = G_t_dB(jj,ii) + G_r_dB(jj2,ii2); 
            end
        end
    end
end


if save_patt
    eval("save " + save_name + " M_estimated M_est_var phi_grid theta_grid M_anec phi_grid_anec theta_grid_anec")
end
end

