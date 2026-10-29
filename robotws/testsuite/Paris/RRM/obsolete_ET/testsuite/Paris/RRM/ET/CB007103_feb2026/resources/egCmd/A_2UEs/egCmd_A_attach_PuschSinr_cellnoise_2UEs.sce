#Goal of this Test case:
#Activate CB007103-A Test case conditions
#UE registration
#UL/DL Data Traffic
#Degrade Pusch_SINR and add cell noise for Pusch


ue_register id=1
sleep_script 2
set_pdu_param ue=1 pdu=1 trf_type=internal 
ue_pdu_session_setup pdu=1 ue=1 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=140 dir=ul
trf_data_start ue=1 pdu=1 qfi=1 trf_id=2 mbps=60 dir=ul
sleep_script 1

ue_register id=2
sleep_script 2
set_pdu_param ue=2 pdu=1 trf_type=internal 
ue_pdu_session_setup pdu=1 ue=2 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 mbps=140 dir=ul
trf_data_start ue=2 pdu=1 qfi=1 trf_id=2 mbps=60 dir=ul
sleep_script 1

ue_stats_nr id=1-2 type=pdsch
ue_stats_nr id=1-2 type=pusch

###UL SINR Test Mode###
#ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-250
###UL SINR Test Mode activation for UE 1###
#ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate
#sleep_script 1
###UL SINR Test Mode activation for UE 2###
#ue_testmode_set_nr id=2 testmode=ul_sinr profile_id=1 action=activate
#sleep_script 1

###Cell Noise Test Mode###
ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-650 noise_pucch=-650
###Cell Noise Test Mode activation on gnb=2/cell_id=1 ###
cell_testmode_set_nr cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
sleep_script 1
###Cell Noise Test Mode activation on gnb=2/cell_id=2 ###
cell_testmode_set_nr cell_id=2 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
sleep_script 1

ue_stats_nr id=1-2 type=pdsch
ue_stats_nr id=1-2 type=pusch
