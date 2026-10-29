#Goal of this Test case:
#Activate CB007103-A Test case conditions
#UE registration
#UL/DL Data Traffic


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