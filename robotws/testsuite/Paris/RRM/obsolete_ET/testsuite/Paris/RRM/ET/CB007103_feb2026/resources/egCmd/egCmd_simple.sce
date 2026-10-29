
ue_register id=1
sleep 2
set_pdu_param ue=1 pdu=1 trf_type=internal 
ue_pdu_session_setup pdu=1 ue=1 gw=1 nwslice=1
sleep 2
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
sleep 2
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=140 dir=ul
sleep 2


ue_register id=2
sleep 2
set_pdu_param ue=2 pdu=2 trf_type=internal 
ue_pdu_session_setup pdu=2 ue=2 gw=1 nwslice=1
sleep 2
trf_data_start ue=2 pdu=2 qfi=1 trf_id=1 mbps=2 dir=dl
trf_data_start ue=2 pdu=2 qfi=1 trf_id=1 mbps=140 dir=ul

sleep 2
ue_stats_nr id=1-2 type=pdsch
sleep 2
ue_stats_nr id=1-2 type=pusch

sim_log_set flush
exit