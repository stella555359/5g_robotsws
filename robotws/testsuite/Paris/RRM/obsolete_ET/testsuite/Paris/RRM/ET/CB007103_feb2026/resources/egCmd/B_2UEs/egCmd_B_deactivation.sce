#Goal of this Test case:
#Deactivate CB007103-B Test case conditions
#Data traffic Stop and UE deregistration


#Set gNB Database DEFAULT configuration
#Target SINR for PUCCH
#MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0/targetSinr=4
#Timer of SINR update for PUCCH
#MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0/tIntervalSinrUpd=100

###Cell Noise Test Mode Deactivation on gnb=2/cell_id=1 ###
cell_testmode_set_nr cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=2 action=deactivate
sleep_script 5

###UL SINR for PUCCH and PUSCH Test Mode Deactivation for UE###
ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=deactivate
sleep_script 5

###Data traffic Deactivation for UE###
trf_data_stop ue=1 pdu=1 qfi=1 trf_id=1 dir=dl
trf_data_stop ue=1 pdu=1 qfi=1 trf_id=1 dir=ul

###UE Deregistration###
ue_deregister id=1 by=ue ue_deregister_type=switch_off
sleep_script 2


