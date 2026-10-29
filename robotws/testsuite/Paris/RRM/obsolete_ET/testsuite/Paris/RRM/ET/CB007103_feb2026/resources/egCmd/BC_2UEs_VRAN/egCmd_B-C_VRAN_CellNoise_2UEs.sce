#add cell noise for Pusch and pucch

##+++Cell Noise on PUCCH and PUSCH channels++++++
#Test1 ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-650 noise_pucch=-550
ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-750 noise_pucch=-550
#ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-850 noise_pucch=-550
cell_testmode_set_nr cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
sleep_script 1
###Cell Noise Test Mode activation on gnb=2/cell_id=2 ###
cell_testmode_set_nr cell_id=2 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
sleep_script 1

ue_stats_nr id=1,21 type=pdsch
ue_stats_nr id=1,21 type=pusch
