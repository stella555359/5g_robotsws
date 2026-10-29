
ue_stats_nr id=1 type=pdsch
sleep_script 2
ue_stats_nr id=1 type=pusch
sleep_script 2

bler_testmode_nr profile_id=3 ul_bler=100,100
sleep_script 1
ue_testmode_set_nr id=1 testmode=bler profile_id=3 action=activate
sleep_script 2

ue_stats_nr id=1 type=pdsch
sleep_script 2
ue_stats_nr id=1 type=pusch
sleep_script 2

sim_log_set flush
exit