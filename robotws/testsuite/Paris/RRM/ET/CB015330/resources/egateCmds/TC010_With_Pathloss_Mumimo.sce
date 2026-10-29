#TC010 egate commands

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

ue_register id=5
sleep_script 2
set_pdu_param ue=5 pdu=5 trf_type=internal
ue_pdu_session_setup pdu=5 gw=5 ue=5 nwslice=1
sleep_script 2

ue_register id=6
sleep_script 2
set_pdu_param ue=6 pdu=6 trf_type=internal
ue_pdu_session_setup pdu=6 gw=6 ue=6 nwslice=1
sleep_script 2

ue_register id=7
sleep_script 2
set_pdu_param ue=7 pdu=7 trf_type=internal
ue_pdu_session_setup pdu=7 gw=7 ue=7 nwslice=1
sleep_script 2

ue_register id=8
sleep_script 2
set_pdu_param ue=8 pdu=8 trf_type=internal
ue_pdu_session_setup pdu=8 gw=8 ue=8 nwslice=1
sleep_script 2

ue_register id=9
sleep_script 2
set_pdu_param ue=9 pdu=9 trf_type=internal
ue_pdu_session_setup pdu=9 gw=9 ue=9 nwslice=1
sleep_script 2

trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 mbps=175
trf_data_start ue=2 pdu=2 qfi=1 dir=dl trf_id=1 mbps=175
trf_data_start ue=3 pdu=3 qfi=1 dir=dl trf_id=1 mbps=175
trf_data_start ue=4 pdu=4 qfi=1 dir=dl trf_id=1 mbps=175
trf_data_start ue=5 pdu=5 qfi=1 dir=dl trf_id=1 mbps=175
trf_data_start ue=6 pdu=6 qfi=1 dir=dl trf_id=1 mbps=175
trf_data_start ue=7 pdu=7 qfi=1 dir=dl trf_id=1 mbps=175
trf_data_start ue=8 pdu=8 qfi=1 dir=dl trf_id=1 mbps=175
trf_data_start ue=9 pdu=9 qfi=1 dir=dl trf_id=1 mbps=175

sleep_script 3
ue_stats_nr id=1-9
sleep_script 2

trf_data_start ue=1 pdu=1 qfi=1 dir=ul trf_id=1 mbps=175
trf_data_start ue=2 pdu=2 qfi=1 dir=ul trf_id=1 mbps=175
trf_data_start ue=3 pdu=3 qfi=1 dir=ul trf_id=1 mbps=175
trf_data_start ue=4 pdu=4 qfi=1 dir=ul trf_id=1 mbps=175
trf_data_start ue=5 pdu=5 qfi=1 dir=ul trf_id=1 mbps=175
trf_data_start ue=6 pdu=6 qfi=1 dir=ul trf_id=1 mbps=175
trf_data_start ue=7 pdu=7 qfi=1 dir=ul trf_id=1 mbps=175
trf_data_start ue=8 pdu=8 qfi=1 dir=ul trf_id=1 mbps=175
trf_data_start ue=9 pdu=9 qfi=1 dir=ul trf_id=1 mbps=175


sleep_script 3
ue_stats_nr id=1-9 type=pusch
sleep_script 2

ul_sinr_testmode_nr profile_id=1 pathloss=100
sleep_script 1
ue_testmode_set_nr id=1-9 scell=0 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1


sleep_script 3
ue_stats_nr id=1-9 type=pusch
sleep_script 2
