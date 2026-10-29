ue_register id=1
sleep_script 2

set_pdu_param ue=1 pdu=1 trf_type=internal
sleep_script 1

ue_pdu_session_setup pdu=1 ue=1 gw=1 nwslice=1
sleep_script 3

bler_testmode_nr profile_id=3 dl_bler=400,400 dl_bler_type=DTX,DTX
sleep_script 1
ue_testmode_set_nr id=1 testmode=bler action=activate profile_id=3
sleep_script 3

trf_data_start ue=1 pdu=1 qfi=1 dir=dl trf_id=1 period_ms=60 size=1000 burst=1
sleep_script 3

ue_stats_nr type=pdsch scell=0 id=1-2
sleep_script 3
ue_stats_nr type=pusch scell=0 id=1-2
sleep_script 3

sim_log_set flush
