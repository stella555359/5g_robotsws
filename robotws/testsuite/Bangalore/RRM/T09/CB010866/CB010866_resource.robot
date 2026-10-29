*** Settings ***
Library    ute_wtssim
Library    python/check_alarm.py

Documentation    :copyright: Nokia
...              :authors: Ganesha
...              :contact: ganesha.u@nokia.com

*** Keywords ***
Verify Fault Description
    [Arguments]    ${faultid}    ${faultname}    ${description}=None  ${cell}=NRCELL-1
    ${cellid}   Catenate    SEPARATOR=    MRBTS-1/NRBTS-1/${cell}
    ${result}    check_alarm.check_alarm_description     ${faultid}    ${faultname}    ${description}   ${cellid}
    run keyword and continue on failure   Run Keyword if   ${result}!=${True}   Fail   Alarm is not matching

Set Internal Traffic Type To UE
    ute_wtssim.Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    ute_wtssim.Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal

Start Data Traffic In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}

Activate RI
    [Arguments]    ${cell_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_RI}
    Sleep   5s
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=${cell_id} profile_id=7 action=activate

Deactivate RI
    [Arguments]    ${cell_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=${cell_id} profile_id=7 action=deactivate

Generate RI For 1116 FS
    ute_wtssim.Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_FOR_RI}
    Sleep   5s
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Setup X2 Link
    ute_wtssim.Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s    Wait For X2 Establishment

Activate RIMRS
    [Arguments]    ${cell_id}=1
    ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=3 config_mode=standalone aggressor_cell=1 victim_cell=3 rsSetId=12346
    ...     \ propagation_delay=16 rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=25 factorRsSequence=0 offsetRsSequence=0
    ...     \ startRbForRs=1,50,100,150 rimRsTxPower=-330 repetitionRsType1=1 rsPattern2Period=25
    ute_wtssim.Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep    5s
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=rim_rs profile_id=3 action=activate

Generate RIMRS
    [Arguments]    ${cell_id}=1
    ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=3 config_mode=standalone aggressor_cell=1 rsSetId=12346 numRsSetId=1
    ...     \ enable_auto_propagation_delay=on rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=50 factorRsSequence=0 offsetRsSequence=0
    ...     \ startRbForRs=1,50,100,150 rimRsTxPower=-330 repetitionRsType1=1 rsPattern2Period=25 numRsType1SetId=524288
    ute_wtssim.Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep    5s
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=rim_rs profile_id=3 action=activate

Stop All Data Transfers And Detach UE
    [Arguments]   ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=1
    Sleep    5s
    ute_wtssim.Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off

Change RIMRS profile
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=3 action=deactivate
    Sleep     100s
    ${rim_rs_profile7}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=7 config_mode=standalone aggressor_cell=1 victim_cell=3 rsSetId=12346
    ...     \ propagation_delay=16 rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=25 factorRsSequence=0 offsetRsSequence=0
    ...     \ startRbForRs=1,50,100,150 rimRsTxPower=-330 repetitionRsType1=2 rsPattern2Period=25
    ute_wtssim.Execute Egate Command     cmd=${rim_rs_profile7}
    Sleep    5s
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=7 action=activate

Generate RS1
    [Arguments]    ${profile}   ${cell_id}=1
    ${RS1}=    Catenate    SEPARATOR=
    ...  rimrs_testmode_nr profile_id=${profile} config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=44444
    ...  \ numRsSetId=1 rimRsType=rsType1 propagation_delay=16 rsType2NScId=1,2,3,4,5,6,7,8 rsPattern1Period=25
    ...  \ rsPattern2Period=25 factorRsSequence=1 factorRsSequenceRS2=1 offsetRsSequence=1 offsetRsSequenceRS2=1
    ...  \ repetitionRsType2=4 rim_framework=framework_1 numRsType2SetId=131072 numRsType1SetId=131072 repetitionRsType1=4
    ...  \ globalF0ForRs=636672 startFreqOffsetForRs=10
    ute_wtssim.Execute Egate Command     cmd=${RS1}
    sleep  5s
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=rim_rs profile_id=${profile} action=activate

Generate RS2
    [Arguments]    ${profile}   ${cell_id}=1
    ${RS2}=    Catenate    SEPARATOR=
    ...  rimrs_testmode_nr profile_id=${profile} config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=44444
    ...  \ numRsSetId=1 rimRsType=rsType2 propagation_delay=16 rsType2NScId=1,2,3,4,5,6,7,8 rsPattern1Period=25
    ...  \ rsPattern2Period=25 factorRsSequence=1 factorRsSequenceRS2=1 offsetRsSequence=1 offsetRsSequenceRS2=1
    ...  \ repetitionRsType2=4 rim_framework=framework_1 numRsType2SetId=131072 numRsType1SetId=131072 repetitionRsType1=4
    ...  \ globalF0ForRs=636672 startFreqOffsetForRs=10
    ute_wtssim.Execute Egate Command     cmd=${RS2}
    sleep  5s
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=rim_rs profile_id=${profile} action=activate

Deactivate RS1
    [Arguments]    ${profile}   ${cell_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=rim_rs profile_id=${profile} action=deactivate
    sleep  3s

Deactivate RS2
    [Arguments]    ${profile}   ${cell_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=rim_rs profile_id=${profile} action=deactivate
    sleep  3s

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt
