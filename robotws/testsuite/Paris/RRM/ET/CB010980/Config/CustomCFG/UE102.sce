ue_attach id=102 profile=1
sleep_script 2

bearer_add ue=102 id=3 filter=2 precedence=2 local_port=7072 proto=17 filter=3 precedence=3 remote_port=7073 proto=17
sleep_script 1

ue_dc_enb_start ue=102 target_gnb=2 target_cells=1 bearer=2,3 type=split_scg
sleep_script 3

trf_data_start ue=102 dir=ul id=2 mbps=10 trf_id=1
sleep_script 3
trf_data_start ue=102 dir=dl id=2 mbps=10 trf_id=1
sleep_script 3

trf_data_start ue=102 dir=ul id=3 mbps=15 trf_id=1
sleep_script 3
trf_data_start ue=102 dir=dl id=3 mbps=15 trf_id=1
sleep_script 3


ue_stats_nr type=pdsch scell=8 id=101-102
sleep_script 3
ue_stats_nr type=pusch scell=8 id=101-102
sleep_script 3

sim_log_set flush