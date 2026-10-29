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
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=1 dir=ul
sleep_script 1

ue_register id=21
sleep_script 2
set_pdu_param ue=21 pdu=1 trf_type=internal
ue_pdu_session_setup pdu=1 ue=21 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=21 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
trf_data_start ue=21 pdu=1 qfi=1 trf_id=1 mbps=1 dir=ul

###Pathloss Test Mode ###
ul_sinr_testmode_nr profile_id=1 pathloss=110
###Pathloss Test Mode activation for UE-1######
ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1
sleep_script 1
###Pathloss Test Mode activation for UE-2######
ue_testmode_set_nr id=21 testmode=ul_sinr action=activate profile_id=1
sleep_script 1

ue_stats_nr id=1,21 type=pdsch
ue_stats_nr id=1,21 type=pusch

#UEs should be in TPON mode here.

##+++Cell Noise on PUCCH and PUSCH channels++++++
ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-750 noise_pucch=-550
cell_testmode_set_nr cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
sleep_script 1
###Cell Noise Test Mode activation on gnb=2/cell_id=2 ###
cell_testmode_set_nr cell_id=2 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
sleep_script 1

ue_stats_nr id=1,21 type=pdsch
ue_stats_nr id=1,21 type=pusch
