ue_register id=6
script_sleep 1
ue_register id=32
script_sleep 1
set_pdu_param ue=6 pdu=1 trf_type=internal
script_sleep 1
set_pdu_param ue=32 pdu=1 trf_type=internal
script_sleep 1
ue_pdu_session_setup ue=6 pdu=1 gw=1 nwslice=1
script_sleep 1
ue_pdu_session_setup ue=32 pdu=1 gw=1 nwslice=1
script_sleep 1
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_stop ue=6 pdu=1 qfi=1 trf_id=1
script_sleep 1
trf_data_stop ue=32 pdu=1 qfi=1 trf_id=1
script_sleep 1
ue_pdu_session_release ue=6 pdu=1
script_sleep 1
ue_pdu_session_release ue=32 pdu=1
script_sleep 1
ue_deregister id=6 ue_deregister_type=switch_off
script_sleep 5
ue_deregister id=32 ue_deregister_type=switch_off
script_sleep 200
ue_register id=6
script_sleep 1
ue_register id=32
script_sleep 1
set_pdu_param ue=6 pdu=1 trf_type=internal
script_sleep 1
set_pdu_param ue=32 pdu=1 trf_type=internal
script_sleep 1
ue_pdu_session_setup ue=6 pdu=1 gw=1 nwslice=1
script_sleep 1
ue_pdu_session_setup ue=32 pdu=1 gw=1 nwslice=1
script_sleep 1
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=6 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_start ue=32 pdu=1 qfi=1 trf_id=1 kbps=1000 dir=dl protocol=udp
script_sleep 5
trf_data_stop ue=6 pdu=1 qfi=1 trf_id=1
script_sleep 1
trf_data_stop ue=32 pdu=1 qfi=1 trf_id=1
script_sleep 1
ue_pdu_session_release ue=6 pdu=1
script_sleep 1
ue_pdu_session_release ue=32 pdu=1
script_sleep 1
ue_deregister id=6 ue_deregister_type=switch_off
script_sleep 5
ue_deregister id=32 ue_deregister_type=switch_off