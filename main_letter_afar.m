clc;
clear;
close all;

addpath('functions\')
addpath("./data_gen\AFAR_dataset\processed_data\")

x1=-78.69953825817279;
y1= 35.72688213193035;
x2=-78.69621514941473;
y2=35.72931030026633;

% 309 loc1 is invalid

%exps = [288, 300, 301, 309, 328];
%locations = [1, 2, 3];
%%
close all
exp_no = 288;
location = 2;

train_exp_no = 300;
location_train = 2;

nk = 10;

fig_rows = 1;
fig_cols = 1;

use_ground_relfec = 0; % no use so far, will produce both, PL_free and two way
save = 0;
save_name = "";

use_fspl = 1;

mat_name = "mutual_ant_patt/patts/mutual_patt_afar_" + num2str(train_exp_no) + "_" + num2str(location_train) + "_nk_" + num2str(nk) + ".mat";

load("./data_gen\AFAR_dataset\processed_data\results_useful_with_tworay_tilt_src_exp_"+num2str(exp_no)+"_loc_"+num2str(location)+".mat")

RSRP_PL_free = baseline_flipx_afar_letter(exp_no, location, use_ground_relfec, save, save_name, 0, 0);
[legends1, legends2] = plot_elements_no_mean_subtract(fig_rows,fig_cols,1,power_all,RSRP_PL_free,RSRP_PL_free,dist_3D,ori_all, roll_all, pitch_all, azim, elev,lat_all, lon_all, h_all, speed_all,exp_no,location,"k",'--', " (Anechoic)",[], [],1,use_fspl, [], [],[],[]);

disp(mean(abs(RSRP_PL_free - power_all)))
disp(median(abs(RSRP_PL_free - power_all)))

% legends1 = [];
% legends2 = [];
% (Airframe shadowing)
RSRP_PL_free = baseline_flipx_afar_letter(exp_no, location, use_ground_relfec, save, save_name, 1, 1, 0, mat_name);
[legends1, legends2] = plot_elements_no_mean_subtract(fig_rows,fig_cols,1,power_all,RSRP_PL_free,RSRP_PL_free,dist_3D,ori_all, roll_all, pitch_all, azim, elev, lat_all, lon_all, h_all, speed_all, exp_no,location,"m",'-^', " (Learned)", legends1, legends2,2, 1,[], [],[],[]);

disp(mean(abs(RSRP_PL_free - power_all)))
disp(median(abs(RSRP_PL_free - power_all)))


%%
close all
exp_no = 301;
location = 2;

train_exp_no = 309; % name 309, but is trained on both 309 and 328
location_train = 2;

nk = 10;

fig_rows = 1;
fig_cols = 1;

use_ground_relfec = 0; % no use so far, will produce both, PL_free and two way
save = 0;
save_name = "";

use_fspl = 1;

mat_name = "mutual_ant_patt/patts/mutual_patt_afar_" + num2str(train_exp_no) + "_" + num2str(location_train) + "_nk_" + num2str(nk) + ".mat";

load("./data_gen\AFAR_dataset\processed_data\results_useful_with_tworay_tilt_src_exp_"+num2str(exp_no)+"_loc_"+num2str(location)+".mat")

RSRP_PL_free = baseline_flipx_afar_letter(exp_no, location, use_ground_relfec, save, save_name, 0, 0);
[legends1, legends2] = plot_elements_no_mean_subtract(fig_rows,fig_cols,1,power_all,RSRP_PL_free,RSRP_PL_free,dist_3D,ori_all, roll_all, pitch_all, azim, elev,lat_all, lon_all, h_all, speed_all,exp_no,location,"k",'--', " (Anechoic)",[], [],1,use_fspl, [], [],[],[]);

disp(mean(abs(RSRP_PL_free - power_all)))
disp(median(abs(RSRP_PL_free - power_all)))

% legends1 = [];
% legends2 = [];
% (Airframe shadowing)
RSRP_PL_free = baseline_flipx_afar_letter(exp_no, location, use_ground_relfec, save, save_name, 1, 1, 0, mat_name);
[legends1, legends2] = plot_elements_no_mean_subtract(fig_rows,fig_cols,1,power_all,RSRP_PL_free,RSRP_PL_free,dist_3D,ori_all, roll_all, pitch_all, azim, elev, lat_all, lon_all, h_all, speed_all, exp_no,location,"m",'-^', " (Learned)", legends1, legends2,2, 1,[], [],[],[]);

disp(mean(abs(RSRP_PL_free - power_all)))
disp(median(abs(RSRP_PL_free - power_all)))