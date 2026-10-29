ue_register id=2
sleep_script 2

set_pdu_param ue=2 pdu=2 trf_type=internal
sleep_script 1

ue_pdu_session_setup pdu=2 ue=2 gw=1 nwslice=2
sleep_script 3

ue_pdu_session_modify ue=2 pdu=2 qosflows_to_add=4 by=amf
sleep_script 3

ue_pdu_session_modify ue=2 pdu=2 qosflows_to_add=2 by=amf
sleep_script 3

trf_data_start ue=2 pdu=2 qfi=1 dir=dl trf_id=1 protocol=tcp mbps=5
sleep_script 3
trf_data_start ue=2 pdu=2 qfi=1 dir=ul trf_id=1 protocol=tcp mbps=5
sleep_script 3

trf_data_start ue=2 pdu=2 qfi=2 dir=dl trf_id=1 protocol=tcp mbps=10
sleep_script 3
trf_data_start ue=2 pdu=2 qfi=2 dir=ul trf_id=1 protocol=tcp mbps=10
sleep_script 3

trf_data_start ue=2 pdu=2 qfi=3 dir=dl trf_id=1 protocol=tcp mbps=15
sleep_script 3
trf_data_start ue=2 pdu=2 qfi=3 dir=ul trf_id=1 protocol=tcp mbps=15
sleep_script 3

ue_stats_nr type=pdsch scell=0 id=1-2
sleep_script 3
ue_stats_nr type=pusch scell=0 id=1-2
sleep_script 3

sim_log_set flush