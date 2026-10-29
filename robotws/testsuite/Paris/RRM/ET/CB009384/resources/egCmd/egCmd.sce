###UL SINR Test Mode###
ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-250
###UL SINR Test Mode activation for UE###
ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate
sleep_script 1

###Cell Noise Test Mode### Comment added to prevent RLF du to this TM
#ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-650
###Cell Noise Test Mode activation on gnb=2/cell_id=2 ###
#cell_testmode_set_nr cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=2 action=activate
#sleep_script 1

###UL & DL Trf### replace not working KW "Traffic SA" in Foreign_TC_8072_FDD
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=dl
sleep_script 1
trf_data_start ue=1 pdu=1 qfi=1 trf_id=1 mbps=2 dir=ul
sleep_script 1