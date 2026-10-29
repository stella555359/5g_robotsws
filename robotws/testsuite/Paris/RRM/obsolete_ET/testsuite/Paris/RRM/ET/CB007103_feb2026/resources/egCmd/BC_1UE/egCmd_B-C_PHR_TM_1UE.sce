#Goal of this Script:

#Apply the PHR OVERRIDE TEST MODE TO trigger TPCFOR PUSCH


#gNB Database specific configuration
#Target SINR for PUCCH  			(default value is 4 ….19 is the Maximum value)
#MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0/targetSinr=19
#Timer of SINR update for PUCCH     (default value is 100ms)
#MRBTS-1/NRBTS-1/NRULCLPC_PROFILE-0/tIntervalSinrUpd=10

#+++PHR_override_Testmode_set_NR++++++
phr_override_testmode_nr profile_id=3 phr_mode=Fixed phr_start=3 pc_max=23
ue_testmode_set_nr id=2 testmode=phr_override profile_id=3 action=activate
sleep_script 1

