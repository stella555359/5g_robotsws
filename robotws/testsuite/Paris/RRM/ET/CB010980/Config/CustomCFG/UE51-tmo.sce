ue_register id=51
sleep_script 2
set_pdu_param ue=51 pdu=1 trf_type=internal
ue_pdu_session_setup pdu=1 ue=51 gw=51 nwslice=1
sleep_script 1

trf_data_start ue=51 pdu=1 qfi=1 trf_id=1 mbps=20 dir=ul
sleep_script 1
ue_pdu_session_modify ue=51 pdu=1 qosflows_to_add=2 by=amf
sleep_script 2
ue_pdu_session_modify ue=51 pdu=1 qosflows_to_add=3 by=amf
sleep_script 1

bler_testmode_nr profile_id=3 ul_bler=500,500,500,500,200,200,100,100
ue_testmode_set_nr id=51  testmode=bler profile_id=3  action=activate
sleep_script 1

sim_log_set flush