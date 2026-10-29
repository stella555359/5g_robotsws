ue_register id=1
sleep_script 5
set_pdu_param ue=1 pdu=1 trf_type=internal
sleep_script 2
ue_pdu_session_setup pdu=1 ue=1 gw=1 nwslice=1
sleep_script 2
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
sleep_script 2
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=100 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=200 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=300 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=400 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=500 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=600 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=700 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=800 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=900 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=1 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=1500 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 kbps=2500 dir=ul
sleep_script 4
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=3 dir=ul
sleep_script 4

ue_stats_nr id=1 type=pdsch
sleep_script 2
ue_stats_nr id=1 type=pusch
sleep_script 2

sim_log_set flush
exit