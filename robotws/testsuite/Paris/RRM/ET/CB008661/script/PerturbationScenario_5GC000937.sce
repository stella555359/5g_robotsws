ue_register id=1
script_sleep 1
ue_register id=10
script_sleep 1
set_pdu_param ue=1 pdu=1 trf_type=internal
script_sleep 1
set_pdu_param ue=10 pdu=1 trf_type=internal
script_sleep 1
ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1
script_sleep 1
ue_pdu_session_setup ue=10 pdu=1 gw=1 nwslice=1
script_sleep 1
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=10 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=10 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=10 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=10 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_stop ue=1 pdu=1 qfi=1 trf_id=1
script_sleep 1
trf_data_stop ue=10 pdu=1 qfi=1 trf_id=1
script_sleep 1
ue_pdu_session_release ue=1 pdu=1
script_sleep 2
ue_pdu_session_release ue=10 pdu=1
script_sleep 2
ue_deregister id=1 ue_deregister_type=switch_off
script_sleep 5
ue_deregister id=10 ue_deregister_type=switch_off
script_sleep 5
