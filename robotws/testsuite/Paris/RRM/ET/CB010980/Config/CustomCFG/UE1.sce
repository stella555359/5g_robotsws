ue_register id=1
sleep_script 2

set_pdu_param ue=1 pdu=1 trf_type=internal
sleep_script 1

ue_pdu_session_setup pdu=1 ue=1 gw=1 nwslice=1
sleep_script 3

ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=5 by=amf
sleep_script 3

trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 protocol=tcp mbps=5
sleep_script 3
trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=1 protocol=tcp mbps=5
sleep_script 3

trf_data_start ue=1 pdu=1 qfi=2 dir=dl trf_id=1 protocol=tcp mbps=10
sleep_script 3
trf_data_start ue=1 pdu=1 qfi=2 dir=ul trf_id=1 protocol=tcp mbps=10
sleep_script 3


ue_stats_nr type=pdsch scell=0 id=1-2
sleep_script 3
ue_stats_nr type=pusch scell=0 id=1-2
sleep_script 3

sim_log_set flush