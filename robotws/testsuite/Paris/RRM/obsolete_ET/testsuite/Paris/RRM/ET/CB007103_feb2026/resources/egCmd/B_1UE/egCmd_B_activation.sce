#Goal of this Test case:
#Activate CB007103-B Test case conditions
#TP OFF FOR PUSCH (CB007103-B with AlwaysON for PUCCH in pi2bpsk is tested)
#Pucch Format 3 is still reported
#Generate BLER or DTX on the Pucch
#Generate TPC commands for the Pucch


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
sleep_script 2

###UL SINR for PUCCH and PUSCH Test Mode###
ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-250 sinr_target_pucch=-250
###UL SINR for PUCCH and PUSCH Test Mode activation for UE###
ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate
sleep_script 5

###Cell Noise Test Mode###
ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-650
###Cell Noise Test Mode activation on gnb=2/cell_id=1 ###
cell_testmode_set_nr cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
sleep_script 5


# The UE is still in state TP OFF for Pusch
#Pucch SINR is around 0 	DTX on Pucch	CRC KO on Pucch

