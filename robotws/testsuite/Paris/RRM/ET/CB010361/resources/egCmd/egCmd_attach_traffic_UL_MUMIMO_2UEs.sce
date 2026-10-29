#Goal of this Test case:
#Register in SA mode two UEs
#UE registration on same cell_id=3
#Appli UL MIMO SRS Beam Position on each UE
#UL Data Traffic

ue_register id=1
sleep_script 2
set_pdu_param ue=1 pdu=1 trf_type=internal
ue_pdu_session_setup pdu=1 gw=1 ue=1 nwslice=1
sleep_script 2

ue_register id=2
sleep_script 2
set_pdu_param ue=2 pdu=1 trf_type=internal
ue_pdu_session_setup pdu=1 gw=2 ue=2 nwslice=1
sleep_script 2

ue_stats_nr id=1,2 type=pusch,pdsch scell=0-31

ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 step=5 trigger_puxch_update=0
ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=3
ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 step=2 trigger_puxch_update=0
ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=4
sleep_script 1


trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 period_ms=300 size=1250 burst=20 dir=ul

ue_stats_nr id=1,2 type=pusch,pdsch scell=0-31
sleep_script 1

trf_data_start ue=2 pdu=1 qfi=1 dir=ul trf_id=2 size=1350 mbps=140
trf_data_start ue=2 pdu=1 qfi=1 dir=ul trf_id=3 size=1350 mbps=140
sleep_script 1

ue_stats_nr id=1,2 type=pusch,pdsch scell=0-31
sleep_script 20
ue_stats_nr id=1,2 type=pusch,pdsch scell=0-31
sleep_script 20
ue_stats_nr id=1,2 type=pusch,pdsch scell=0-31
sleep_script 20
ue_stats_nr id=1,2 type=pusch,pdsch scell=0-31
sleep_script 20
ue_stats_nr id=1,2 type=pusch,pdsch scell=0-31
sleep_script 20
ue_stats_nr id=1,2 type=pusch,pdsch scell=0-31
sleep_script 20
