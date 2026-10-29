#Goal of this Test case:
#Activate CB007103-F6 Test case conditions
#TP ON FOR PUSCH by increasing pathloss
#Pucch Format 3 is still reported
#Generate BLER or DTX on the Pusch


###Pathloss Test Mode###
ul_sinr_testmode_nr profile_id=2 pathloss=110
###Pathloss Test Mode activation for UE 1###
ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=2
sleep_script 1
###Pathloss Test Mode activation for UE 2###
ue_testmode_set_nr id=2 testmode=ul_sinr action=activate profile_id=2
sleep_script 1
###Pathloss Test Mode activation for UE 3###
ue_testmode_set_nr id=3 testmode=ul_sinr action=activate profile_id=2
sleep_script 1
###Pathloss Test Mode activation for UE 4###
ue_testmode_set_nr id=4 testmode=ul_sinr action=activate profile_id=2
sleep_script 1
###Pathloss Test Mode activation for UE 5###
ue_testmode_set_nr id=5 testmode=ul_sinr action=activate profile_id=2
sleep_script 1
###Pathloss Test Mode activation for UE 6###
ue_testmode_set_nr id=6 testmode=ul_sinr action=activate profile_id=2
sleep_script 1


###The UEs are now in DFT-S-OFDM state (TP ON STATE)###

###BLER testmode NR###-->No Impact for pucch
bler_testmode_nr profile_id=3 ul_bler=100,600,700,800,200,300,400,500
###Bler Test Mode activation for UE 1###
ue_testmode_set_nr id=1 testmode=bler profile_id=3 action=activate
sleep_script 1
###Bler Test Mode activation for UE 2###
ue_testmode_set_nr id=2 testmode=bler profile_id=3 action=activate
sleep_script 1
###Bler Test Mode activation for UE 3###
ue_testmode_set_nr id=3 testmode=bler profile_id=3 action=activate
sleep_script 1
###Bler Test Mode activation for UE 4###
ue_testmode_set_nr id=4 testmode=bler profile_id=3 action=activate
sleep_script 1
###Bler Test Mode activation for UE 5###
ue_testmode_set_nr id=5 testmode=bler profile_id=3 action=activate
sleep_script 1
###Bler Test Mode activation for UE 6###
ue_testmode_set_nr id=6 testmode=bler profile_id=3 action=activate
sleep_script 1
