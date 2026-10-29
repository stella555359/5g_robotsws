#Goal of this Test case:
#Deactivate CB007103-B_C Test case conditions
#TP OFF FOR PUSCH


##PHR override Test mode NR Deactivation for UE###
ue_testmode_set_nr id=2 testmode=phr_override profile_id=3 action=deactivate
sleep_script 1

##+++Cell Noise on PUCCH and PUSCH channels Deactivation++++++
cell_testmode_set_nr cell_id=1 gnb=2 testmode=ul_cell_noise profile_id=2 action=deactivate
sleep_script 1


###Pathloss Test Mode Deactivation###
ue_testmode_set_nr id=2 testmode=ul_sinr action=deactivate profile_id=1
sleep_script 1

#The UE is now in TP OFF state
