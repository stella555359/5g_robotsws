#Goal of this Test case:

#Data traffic Stop and UE deregistration


###Data traffic Deactivation for UE###
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=1 dir=dl
trf_data_stop ue=2 pdu=1 qfi=1 trf_id=1 dir=ul
sleep_script 1

###UE Deregistration###
ue_deregister id=2 by=ue ue_deregister_type=switch_off
sleep_script 1