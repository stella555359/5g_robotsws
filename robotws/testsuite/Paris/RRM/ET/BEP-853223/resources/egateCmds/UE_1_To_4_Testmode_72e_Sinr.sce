ul_sinr_testmode_nr profile_id=1 pathloss=28 pusch_tx_power=-394
sleep_script 1

ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1

ue_testmode_set_nr id=2 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1

ue_testmode_set_nr id=3 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1

ue_testmode_set_nr id=4 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1
