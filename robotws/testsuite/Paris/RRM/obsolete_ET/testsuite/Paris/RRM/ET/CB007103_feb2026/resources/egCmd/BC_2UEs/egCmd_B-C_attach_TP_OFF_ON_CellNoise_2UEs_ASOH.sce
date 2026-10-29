#Goal of this Test case:
#Activate CB007103-B-C Test case conditions
#UE registration
#UL/DL Data Traffic
#TP ON FOR PUSCH
#Pucch Format 3 is still reported
#Generate BLER or DTX on the Pucch


#gNB Database specific configuration
#Target SINR for PUCCH  			(default value is 4 ….19 is the Maximum value)
#MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0/targetSinr=19
#Timer of SINR update for PUCCH     (default value is 100ms)
#MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0/tIntervalSinrUpd=10


ue_register id=1
sleep_script 2
set_pdu_param ue=1 pdu=1 trf_type=internal 
ue_pdu_session_setup pdu=1 ue=1 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=ul
sleep_script 1

ue_register id=2
sleep_script 2
set_pdu_param ue=2 pdu=1 trf_type=internal 
ue_pdu_session_setup pdu=1 ue=2 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
trf_data_start ue=2 pdu=1 qfi=1 trf_id=1 mbps=2 dir=ul
sleep_script 1

###Pathloss Test Mode ###
ul_sinr_testmode_nr profile_id=1 pathloss=120
###Pathloss Test Mode activation for UE-1######
ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1
sleep_script 1

###Pathloss Test Mode activation for UE-2######
ue_testmode_set_nr id=2 testmode=ul_sinr action=activate profile_id=1
sleep_script 1



#UEs should be in TPON mode here.

##+++Cell Noise on PUCCH and PUSCH channels++++++
ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-650 noise_pucch=-550
cell_testmode_set_nr cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
sleep_script 1

cell_testmode_set_nr cell_id=2 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
sleep_script 1
