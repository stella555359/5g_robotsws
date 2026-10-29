ue_register id=1
sleep_script 5
set_pdu_param ue=1 pdu=1 trf_type=internal
sleep_script 2
ue_pdu_session_setup pdu=1 ue=1 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
sleep_script 2
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=140 dir=ul
sleep_script 4

ue_register id=2
sleep_script 5
set_pdu_param ue=2 pdu=1 trf_type=internal
sleep_script 2
ue_pdu_session_setup pdu=1 ue=2 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=2 pdu=1 qfi=1 trf_id=2 mbps=2 dir=dl
sleep_script 2
trf_data_start ue=2 pdu=1 qfi=1 trf_id=2 mbps=140 dir=ul
sleep_script 4

ue_register id=3
sleep_script 5
set_pdu_param ue=3 pdu=1 trf_type=internal
sleep_script 2
ue_pdu_session_setup pdu=1 ue=3 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=3 pdu=1 qfi=1 trf_id=3 mbps=2 dir=dl
sleep_script 2
trf_data_start ue=3 pdu=1 qfi=1 trf_id=3 mbps=140 dir=ul
sleep_script 4

ue_register id=4
sleep_script 5
set_pdu_param ue=4 pdu=1 trf_type=internal
sleep_script 2
ue_pdu_session_setup pdu=1 ue=4 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=4 pdu=1 qfi=1 trf_id=4 mbps=2 dir=dl
sleep_script 2
trf_data_start ue=4 pdu=1 qfi=1 trf_id=4 mbps=140 dir=ul
sleep_script 4

ue_stats_nr id=1-4
sleep_script 2

sim_log_set flush
exit