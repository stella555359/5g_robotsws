
ul_sinr_testmode_nr profile_id=1 pathloss=90
ue_testmode_set_nr id=3 testmode=ul_sinr profile_id=1 action=activate
ue_testmode_set_nr id=4 testmode=ul_sinr profile_id=1 action=activate
sleep_script 2

ue_stats_nr id=3-4
sleep_script 2

sim_log_set flush
exit