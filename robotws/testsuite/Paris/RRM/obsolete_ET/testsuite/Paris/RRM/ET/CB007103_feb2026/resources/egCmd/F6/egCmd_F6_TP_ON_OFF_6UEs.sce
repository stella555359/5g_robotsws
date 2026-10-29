#Goal of this Test case:
#Deactivate CB007103-F6 Test case conditions
#TP OFF FOR PUSCH
#Data traffic Stop and UE deregistration


###Bler Test Mode NR Deactivation###
ue_testmode_set_nr id=1 testmode=bler profile_id=3 action=deactivate
ue_testmode_set_nr id=2 testmode=bler profile_id=3 action=deactivate
ue_testmode_set_nr id=3 testmode=bler profile_id=3 action=deactivate
ue_testmode_set_nr id=4 testmode=bler profile_id=3 action=deactivate
ue_testmode_set_nr id=5 testmode=bler profile_id=3 action=deactivate
ue_testmode_set_nr id=6 testmode=bler profile_id=3 action=deactivate
sleep_script 1

###PathLoss Test Mode Deactivation###
ue_testmode_set_nr id=1 testmode=ul_sinr action=deactivate profile_id=2
ue_testmode_set_nr id=2 testmode=ul_sinr action=deactivate profile_id=2
ue_testmode_set_nr id=3 testmode=ul_sinr action=deactivate profile_id=2
ue_testmode_set_nr id=4 testmode=ul_sinr action=deactivate profile_id=2
ue_testmode_set_nr id=5 testmode=ul_sinr action=deactivate profile_id=2
ue_testmode_set_nr id=6 testmode=ul_sinr action=deactivate profile_id=2

#The UEs are now in TP OFF state

###UL SINR Test Mode Deactivation###
ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=deactivate
ue_testmode_set_nr id=2 testmode=ul_sinr profile_id=1 action=deactivate
ue_testmode_set_nr id=3 testmode=ul_sinr profile_id=1 action=deactivate
ue_testmode_set_nr id=4 testmode=ul_sinr profile_id=1 action=deactivate
ue_testmode_set_nr id=5 testmode=ul_sinr profile_id=1 action=deactivate
ue_testmode_set_nr id=6 testmode=ul_sinr profile_id=1 action=deactivate
sleep_script 1

###Data traffic Deactivation for UE###
trf_data_stop ue=1 pdu=1 qfi=1 trf_id=1 dir=dl
trf_data_stop ue=1 pdu=1 qfi=1 trf_id=1 dir=ul
trf_data_stop ue=1 pdu=1 qfi=1 trf_id=2 dir=ul
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=1 dir=dl
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=1 dir=ul
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=2 dir=ul
trf_data_stop ue=3 pdu=1 qfi=1 trf_id=1 dir=dl
trf_data_stop ue=3 pdu=1 qfi=1 trf_id=1 dir=ul
trf_data_stop ue=3 pdu=1 qfi=1 trf_id=2 dir=ul
trf_data_stop ue=4 pdu=1 qfi=1 trf_id=1 dir=dl
trf_data_stop ue=4 pdu=1 qfi=1 trf_id=1 dir=ul
trf_data_stop ue=4 pdu=1 qfi=1 trf_id=2 dir=ul
trf_data_stop ue=5 pdu=1 qfi=1 trf_id=1 dir=dl
trf_data_stop ue=5 pdu=1 qfi=1 trf_id=1 dir=ul
trf_data_stop ue=5 pdu=1 qfi=1 trf_id=2 dir=ul
trf_data_stop ue=6 pdu=1 qfi=1 trf_id=1 dir=dl
trf_data_stop ue=6 pdu=1 qfi=1 trf_id=1 dir=ul
trf_data_stop ue=6 pdu=1 qfi=1 trf_id=2 dir=ul

###UE Deregistration###
ue_deregister id=1 by=ue ue_deregister_type=switch_off
sleep_script 1
ue_deregister id=2 by=ue ue_deregister_type=switch_off
sleep_script 1
ue_deregister id=3 by=ue ue_deregister_type=switch_off
sleep_script 1
ue_deregister id=4 by=ue ue_deregister_type=switch_off
sleep_script 1
ue_deregister id=5 by=ue ue_deregister_type=switch_off
sleep_script 1
ue_deregister id=6 by=ue ue_deregister_type=switch_off
sleep_script 1