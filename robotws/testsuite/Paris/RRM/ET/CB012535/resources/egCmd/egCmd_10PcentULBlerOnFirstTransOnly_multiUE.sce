
bler_testmode_nr profile_id=3 ul_bler=110
bler_testmode_nr profile_id=4 ul_bler=90
sleep_script 2
ue_testmode_set_nr id=1 testmode=bler profile_id=3 action=activate
ue_testmode_set_nr id=2 testmode=bler profile_id=3 action=activate
sleep_script 2
ue_testmode_set_nr id=3 testmode=bler profile_id=4 action=activate
ue_testmode_set_nr id=4 testmode=bler profile_id=4 action=activate
sleep_script 2


ue_stats_nr id=1-4 type=pusch
sleep_script 2

sim_log_set flush
exit