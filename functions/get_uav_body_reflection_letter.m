function [azim2,elev2] = get_uav_body_reflection_letter(azim,elev,all_ori,all_pitch,all_roll,dis2d,hs)
    % input: azimuth and elevation angle of the UAV with respect to
    % Transmitter (Tx), the UAV's Euler orientation angles, its distance from
    % Tx, UAV altitude
    % output: direction of the Tx from the viewpoint of the UAV, after incorporating 3D orientation of the UAV (roll, pitch, yaw)
    azim = azim - pi .* (azim>0) + pi.* (azim<=0); % -pi to pi
    elev = - elev; 
    N = length(azim);
    dis3d = dis2d.^2 + hs.^2;

    azim2 = zeros(size(azim));
    elev2 = zeros(size(elev));

    for ii = 1:N
        % calculate the inverse rotation matrix
        alpha = all_ori(ii)*pi/180;% yaw
        gamma = all_roll(ii)*pi/180; % roll
        beta = all_pitch(ii)*pi/180; % pitch
        
        % with tilt
        R3 = Rx_roll(pi)*Ry_pitch(-gamma)*Rx_roll(beta)*Rz_yaw(-alpha); % eqn \label{eqn:final_rotation}

        [input_x,input_y,input_z] = sph2cart(azim(ii),elev(ii),dis3d(ii)); 
        output_cartesian = R3 * [input_x; input_y; input_z];

        [rcv_azimuth,rcv_elevation,r_r] = cart2sph(output_cartesian(1),output_cartesian(2),output_cartesian(3));

        % calculate tilt towards source
        %pitch_towards_src(ii) = rcv_elevation + elev(ii);

        % the calculated (rcv_azimuth,rcv_elevation) is for LoS from Tx to
        % Rx, now we want from Rx to Tx, so azim + pi and -elev
        azim2(ii) = (rcv_azimuth > 0) .* (rcv_azimuth - pi) + (rcv_azimuth <= 0) .* (rcv_azimuth + pi);
        elev2(ii) = rcv_elevation;
    end

end
