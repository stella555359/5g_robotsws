#Goal of this Test case:
#Deactivate CB007103-A Test case conditions
#TP OFF FOR PUSCH
#Data traffic Stop and UE deregistration

###PHR override Test mode NR Deactivation for UE###
ue_testmode_set_nr id=2 testmode=phr_override profile_id=4 action=deactivate
sleep_script 1

###Pathloss Test Mode Deactivation###
ue_testmode_set_nr id=2 testmode=ul_sinr action=deactivate profile_id=3
sleep_script 1

#The UE is now in TP OFF state

###Cell Noise Test Mode Deactivation###
cell_testmode_set_nr cell_id=2 gnb=2 testmode=ul_cell_noise profile_id=2 action=deactivate
sleep_script 1

###UL SINR Test Mode Deactivation###
#ue_testmode_set_nr id=2 testmode=ul_sinr profile_id=1 action=deactivate
#sleep_script 1

###Data traffic Deactivation for UE###
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=1 dir=dl
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=1 dir=ul

###UE Deregistration###
ue_deregister id=2 by=ue ue_deregister_type=switch_off
sleep_script 1