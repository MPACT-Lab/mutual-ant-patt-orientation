clc;
clear;
close all;

addpath('functions\')
addpath('data_gen\Multi_BW_dataset\raw_data\')

%%
close all

fig_rows = 1;
fig_cols = 1;
i_run = 1;

nk = 10;

use_ground_relfec = 0; % no use so far, will produce both, PL_free and two way
save = 0;
save_name = "";
smooth = ""; % "" for Propagation modeling, "_smooth" for Kriging

%for matname
train_altitude = "70m"; % train 40m (20MHz), test on other MHzs
% output file names saved including training height as well
train_fs = "20MHz";

mat_name = "mutual_ant_patt/patts/mutual_patt_cole_" + train_altitude + "_fs" + train_fs + "_nk_" + num2str(nk) + ".mat";


altitude = "40m"; % test
fs = "fs20MHz"; % test

load("data_gen\Multi_BW_dataset\processed_data\results_cole_with_tworay_tilt_src_alt_" + altitude +"_"+fs+".mat")

plot_fspl = 1;
RSRP_PL_free = baseline_flipx_cole_letter(altitude, fs, use_ground_relfec, save, save_name, 0, 0, 0, "default");
[legends1, legends2] = plot_elements_cole(fig_rows,fig_cols,i_run,power_all,RSRP_PL_free,RSRP_PL_free,dist_3D,ori_all, roll_all, pitch_all, azim, elev,lat_all, lon_all, h_all, speed_all,"k",'--', "",[], [],1,plot_fspl,elev, elev,elev);

%filename_full = "all_data/cole-"+altitude+"-"+fs+"_tworay3"+".mat";
%exec_cmd = "save " + filename_full + " power_all lat_all lon_all h_all speed_allX speed_allY speed_allZ RSRP_PL_two RSRP_PL_free elev azim dist_2D_new dist_3D roll_all ori_all pitch_all pitch_towards_src arm_len roll_towards_src rcv_azimuth_arm_len";
%eval(exec_cmd)
disp(mean(abs(RSRP_PL_free - power_all)))
disp(median(abs(RSRP_PL_free - power_all)))
disp(var(RSRP_PL_free - power_all))


%(Airframe shadowing)
RSRP_PL_free = baseline_flipx_cole_letter(altitude, fs, use_ground_relfec, save, save_name, 0, 0, 0, mat_name);
[legends1, legends2] = plot_elements_cole(fig_rows,fig_cols,i_run,power_all,RSRP_PL_free,RSRP_PL_free,dist_3D,ori_all, roll_all, pitch_all, azim, elev, lat_all, lon_all, h_all, speed_all,"m",'-^', " + AS(\boldmath$\phi_r, \theta_r$)", legends1, legends2,2, plot_fspl,elev, elev,elev);

filename_full = "all_data/cole-"+altitude+"-"+fs+"-"+train_altitude+"-"+train_fs+"_tworay_shadow"+smooth+".mat";
exec_cmd = "save " + filename_full + " power_all lat_all lon_all h_all speed_allX speed_allY speed_allZ RSRP_PL_two RSRP_PL_free elev azim dist_2D_new dist_3D roll_all ori_all pitch_all pitch_towards_src arm_len roll_towards_src rcv_azimuth_arm_len";
%eval(exec_cmd)
disp(mean(abs(RSRP_PL_free - power_all)))
disp(median(abs(RSRP_PL_free - power_all)))

%%
close all

fig_rows = 1;
fig_cols = 1;
i_run = 1;

nk = 10;

use_ground_relfec = 0; % no use so far, will produce both, PL_free and two way
save = 0;
save_name = "";
smooth = ""; % "" for Propagation modeling, "_smooth" for Kriging

%for matname
train_altitude = "100m"; % train 40m (20MHz), test on other MHzs
% output file names saved including training height as well
train_fs = "20MHz";

mat_name = "mutual_ant_patt/patts/mutual_patt_cole_" + train_altitude + "_fs" + train_fs + "_nk_" + num2str(nk) + ".mat";


altitude = "40m"; % test
fs = "fs20MHz"; % test

load("data_gen\Multi_BW_dataset\processed_data\results_cole_with_tworay_tilt_src_alt_" + altitude +"_"+fs+".mat")

plot_fspl = 1;
RSRP_PL_free = baseline_flipx_cole_letter(altitude, fs, use_ground_relfec, save, save_name, 0, 0, 0, "default");
[legends1, legends2] = plot_elements_cole(fig_rows,fig_cols,i_run,power_all,RSRP_PL_free,RSRP_PL_free,dist_3D,ori_all, roll_all, pitch_all, azim, elev,lat_all, lon_all, h_all, speed_all,"k",'--', "",[], [],1,plot_fspl,elev, elev,elev);

%filename_full = "all_data/cole-"+altitude+"-"+fs+"_tworay3"+".mat";
%exec_cmd = "save " + filename_full + " power_all lat_all lon_all h_all speed_allX speed_allY speed_allZ RSRP_PL_two RSRP_PL_free elev azim dist_2D_new dist_3D roll_all ori_all pitch_all pitch_towards_src arm_len roll_towards_src rcv_azimuth_arm_len";
%eval(exec_cmd)
disp(mean(abs(RSRP_PL_free - power_all)))
disp(median(abs(RSRP_PL_free - power_all)))
disp(var(RSRP_PL_free - power_all))


%(Airframe shadowing)
RSRP_PL_free = baseline_flipx_cole_letter(altitude, fs, use_ground_relfec, save, save_name, 0, 0, 0, mat_name);
[legends1, legends2] = plot_elements_cole(fig_rows,fig_cols,i_run,power_all,RSRP_PL_free,RSRP_PL_free,dist_3D,ori_all, roll_all, pitch_all, azim, elev, lat_all, lon_all, h_all, speed_all,"m",'-^', " + AS(\boldmath$\phi_r, \theta_r$)", legends1, legends2,2, plot_fspl,elev, elev,elev);

filename_full = "all_data/cole-"+altitude+"-"+fs+"-"+train_altitude+"-"+train_fs+"_tworay_shadow"+smooth+".mat";
exec_cmd = "save " + filename_full + " power_all lat_all lon_all h_all speed_allX speed_allY speed_allZ RSRP_PL_two RSRP_PL_free elev azim dist_2D_new dist_3D roll_all ori_all pitch_all pitch_towards_src arm_len roll_towards_src rcv_azimuth_arm_len";
%eval(exec_cmd)
disp(mean(abs(RSRP_PL_free - power_all)))
disp(median(abs(RSRP_PL_free - power_all)))

