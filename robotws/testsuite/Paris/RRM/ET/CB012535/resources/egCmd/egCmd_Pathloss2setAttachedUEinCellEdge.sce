ue_stats_nr id=1 type=pdsch
sleep_script 2
ue_stats_nr id=1 type=pusch
sleep_script 2

ul_sinr_testmode_nr profile_id=1 pathloss=101
ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate
sleep_script 2

ue_stats_nr id=1 type=pdsch
sleep_script 2
ue_stats_nr id=1 type=pusch
sleep_script 2

sim_log_set flush
exit
