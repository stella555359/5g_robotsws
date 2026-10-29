#Degrade ul path Loss

###Pathloss Test Mode ###
ul_sinr_testmode_nr profile_id=1 pathloss=120
###Pathloss Test Mode activation for UE-1######
ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1
sleep_script 1
###Pathloss Test Mode activation for UE-2######
ue_testmode_set_nr id=21 testmode=ul_sinr action=activate profile_id=1
sleep_script 1

ue_stats_nr id=1,21 type=pdsch
ue_stats_nr id=1,21 type=pusch

#UEs should be in TPON mode here.

