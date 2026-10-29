#Goal of this Test case:
#Deactivate CB007103-F10_F11 Test case conditions
#High Speed Flag TM deactivation
#Data traffic Stop and UE deregistration



###UE HIGH SPEED FLAG Test Mode deactivation for UE-1###
ue_testmode_set_nr id=1 testmode=ta action=deactivate profile_id=6

###UE HIGH SPEED FLAG Test Mode deactivation for UE-2###
ue_testmode_set_nr id=2 testmode=ta action=deactivate profile_id=6


