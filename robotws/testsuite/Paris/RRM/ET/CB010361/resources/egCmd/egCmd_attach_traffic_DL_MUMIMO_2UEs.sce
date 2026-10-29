#Goal of this Test case:
#Register in SA mode two UEs
#UE registration on same cell_id=3
#Appli UL SINR on PUCCH
#UL/DL Data Traffic
#Degrade Pusch_SINR and add cell noise for Pusch



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

ue_stats_nr id=1,2 type=pusch scell=0-31

ul_sinr_testmode_nr profile_id=2 sinr_target_pucch=-300
ue_testmode_set_nr id=1-2 testmode=ul_sinr profile_id=2 action=activate
sleep_script 1


ue_srs_beam_pos_nr profile_id=3 srsMode=fixed init_pos=0
sleep_script 1
ue_srs_beam_pos_nr profile_id=4 srsMode=fixed init_pos=1
sleep_script 1
ue_testmode_set_nr id=1 testmode=ue_srs_beam_pos profile_id=3 action=activate
sleep_script 1
ue_testmode_set_nr id=2 testmode=ue_srs_beam_pos profile_id=4 action=activate
sleep_script 1

trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 period_ms=300 size=1250 burst=60 dir=dl
trf_data_start ue=1 pdu=1 qfi=1 trf_id=2 period_ms=300 size=1250 burst=60 dir=dl
trf_data_start ue=1 pdu=1 qfi=1 trf_id=3 period_ms=300 size=1250 burst=60 dir=dl
trf_data_start ue=1 pdu=1 qfi=1 trf_id=4 period_ms=300 size=1250 burst=60 dir=dl
trf_data_start ue=1 pdu=1 qfi=1 trf_id=5 period_ms=300 size=1250 burst=60 dir=dl
trf_data_start ue=1 pdu=1 qfi=1 trf_id=6 period_ms=300 size=1250 burst=60 dir=dl


ue_stats_nr id=1 type=pusch,pdsch scell=0-31

sleep_script 1

ue_stats_nr id=1 type=pusch,pdsch scell=0-31

trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=1 size=1350 mbps=140
trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=2 size=1350 mbps=140
trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=3 size=1350 mbps=140
trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=4 size=1350 mbps=140
trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=5 size=1350 mbps=140
trf_data_start ue=2 pdu=1 qfi=1 dir=dl trf_id=6 size=1350 mbps=140
sleep_script 1

ue_stats_nr id=1,2 type=pusch,pdsch scell=0-31
sleep_script 60
