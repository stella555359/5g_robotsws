ue_register id=1
sleep_script 2
set_pdu_param ue=1 pdu=1 trf_type=internal
ue_pdu_session_setup pdu=1 gw=1 ue=1 nwslice=1
sleep_script 2

ue_register id=2
sleep_script 2
set_pdu_param ue=2 pdu=2 trf_type=internal
ue_pdu_session_setup pdu=2 gw=2 ue=2 nwslice=1
sleep_script 2

ue_register id=3
sleep_script 2
set_pdu_param ue=3 pdu=3 trf_type=internal
ue_pdu_session_setup pdu=3 gw=3 ue=3 nwslice=1
sleep_script 2

ue_register id=4
sleep_script 2
set_pdu_param ue=4 pdu=4 trf_type=internal
ue_pdu_session_setup pdu=4 gw=4 ue=4 nwslice=1
sleep_script 2

