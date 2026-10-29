#Goal of this Test case:
#Activate CB007103-F6 Test case conditions
#UE registration
#UL/DL Data Traffic
#Degrade Pusch_SINR

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

ue_register id=3
sleep_script 2
set_pdu_param ue=3 pdu=1 trf_type=internal 
ue_pdu_session_setup pdu=1 ue=3 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=3 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
trf_data_start ue=3 pdu=1 qfi=1 trf_id=1 mbps=140 dir=ul
trf_data_start ue=3 pdu=1 qfi=1 trf_id=2 mbps=60 dir=ul
sleep_script 1

ue_register id=4
sleep_script 2
set_pdu_param ue=4 pdu=1 trf_type=internal 
ue_pdu_session_setup pdu=1 ue=4 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=4 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
trf_data_start ue=4 pdu=1 qfi=1 trf_id=1 mbps=140 dir=ul
trf_data_start ue=4 pdu=1 qfi=1 trf_id=2 mbps=60 dir=ul
sleep_script 1

ue_register id=5
sleep_script 2
set_pdu_param ue=5 pdu=1 trf_type=internal 
ue_pdu_session_setup pdu=1 ue=5 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=5 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
trf_data_start ue=5 pdu=1 qfi=1 trf_id=1 mbps=140 dir=ul
trf_data_start ue=5 pdu=1 qfi=1 trf_id=2 mbps=60 dir=ul
sleep_script 1

ue_register id=6
sleep_script 2
set_pdu_param ue=6 pdu=1 trf_type=internal 
ue_pdu_session_setup pdu=1 ue=6 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 mbps=140 dir=ul
trf_data_start ue=6 pdu=1 qfi=1 trf_id=2 mbps=60 dir=ul
sleep_script 1

###UL SINR Test Mode###
ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-250
###UL SINR Test Mode activation for UE 1###
ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1
###UL SINR Test Mode activation for UE 2###
ue_testmode_set_nr id=2 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1
###UL SINR Test Mode activation for UE 3###
ue_testmode_set_nr id=3 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1
###UL SINR Test Mode activation for UE 4###
ue_testmode_set_nr id=4 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1
###UL SINR Test Mode activation for UE 5###
ue_testmode_set_nr id=5 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1
###UL SINR Test Mode activation for UE 6###
ue_testmode_set_nr id=6 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1
