#Goal of this Test case:
#Activate CB007103-A Test case conditions
#UE registration
#TP ON FOR PUSCH
#Generate BLER or DTX on the Pusch
#Generate TPC commands for the Pusch by setting AP in Powerboost conditions for Pusch


ue_register id=1
sleep_script 2
set_pdu_param ue=1 pdu=1 trf_type=internal 
ue_pdu_session_setup pdu=1 ue=1 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=140 dir=ul
sleep_script 2

###UL SINR Test Mode###
ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-250
###UL SINR Test Mode activation for UE###
ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate
sleep_script 5

###Cell Noise Test Mode###
ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-650
###Cell Noise Test Mode activation on gnb=2/cell_id=1 ###
cell_testmode_set_nr cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
sleep_script 5

###Pathloss Test Mode###
ul_sinr_testmode_nr profile_id=3 pathloss=110
###Pathloss Test Mode activation for UE###
ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=3
sleep_script 5

###TheUE is now in DFT-S-OFDM state (TP ON STATE)###

###PHR override Test mode NR to trigger TPC for Pusch and set the UE in PowerBoost conditions###
phr_override_testmode_nr profile_id=4 phr_mode=Oneway phr_start=3 phr_min=0 phr_step_size=-1 phr_period=100 pc_max=26
###PHR override Test mode NR activation for UE###
ue_testmode_set_nr id=1 testmode=phr_override profile_id=4 action=activate
sleep_script 5