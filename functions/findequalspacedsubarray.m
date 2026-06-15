function [x_sub,y_sub] = findequalspacedsubarray(x,y,numMarker,startWith,endWith)
    %FINDEQUALSPACEDSUBARRAY Summary of this function goes here
    %   Detailed explanation goes here
    % Initialize the subarray
    x_sub = zeros(numMarker,1);
    y_sub = zeros(numMarker,1);

    x_spaced = linspace(startWith,endWith,numMarker);
    now_finding = 1;
    
    % Loop to find equally spaced elements
    for i = 1:length(x)
        if x(i) >= x_spaced(now_finding)
            x_sub(now_finding) = x(i); % Append the element to the subarray
            y_sub(now_finding) = y(i); % Append the element to the subarray
            now_finding = now_finding + 1;
            if now_finding > numMarker
                break
            end
        end
    end
end

