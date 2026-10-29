#Goal of this Test case:
#Activate CB007103-A Test case conditions
#TP ON FOR PUSCH by increasing pathloss
#Generate TPC commands for the Pusch by setting AP in Powerboost conditions for Pusch


###Pathloss Test Mode###
ul_sinr_testmode_nr profile_id=3 pathloss=120
###Pathloss Test Mode activation for UE 1###
ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=3
sleep_script 1
###Pathloss Test Mode activation for UE 21###
ue_testmode_set_nr id=21 testmode=ul_sinr action=activate profile_id=3
sleep_script 1

###The UEs are now in DFT-S-OFDM state (TP ON STATE)###

###PHR override Test mode NR to trigger TPC for Pusch and set the UE in PowerBoost conditions###
phr_override_testmode_nr profile_id=4 phr_mode=Oneway phr_start=3 phr_min=0 phr_step_size=-1 phr_period=100 pc_max=26
###PHR override Test mode NR activation for UE 1###
ue_testmode_set_nr id=1 testmode=phr_override profile_id=4 action=activate
sleep_script 1
###PHR override Test mode NR activation for UE 21###
ue_testmode_set_nr id=21 testmode=phr_override profile_id=4 action=activate
sleep_script 1


ue_stats_nr id=1,21 type=pdsch
ue_stats_nr id=1,21 type=pusch
