*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Prerana N S
...              :contact: prerana.n_s@nokia.com

Library    python/check_alarm.py

*** Keywords ***
Verify Fault Description
    [Arguments]    ${faultid}    ${faultname}    ${description}=None  ${cell}=NRCELL-1
    ${cellid}   Catenate    SEPARATOR=    MRBTS-1/NRBTS-1/${cell}
    ${result}    check_alarm.check_alarm_description     ${faultid}    ${faultname}    ${description}   ${cellid}
    run keyword and continue on failure   Run Keyword if   ${result}!=${True}   Fail   Alarm is not matching

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal

Start Data Traffic In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}

Activate RI
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Deactivate RI
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=deactivate

Setup X2 Link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s    Wait For X2 Establishment


Stop All Data Transfers And Detach UE
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Generate RS1
    [Arguments]    ${profile}	${delay}
    ${RS1}=    Catenate    SEPARATOR=
    ...  rimrs_testmode_nr profile_id=${profile} config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=11144
    ...  \ numRsSetId=1 rimRsType=rsType1 rsNearFarConfig=0 propagation_delay=${delay} rsType1NScId=1,2,3,4,5,6,7,8
    ...  \ numRbForRs=48 rsPattern1Period=50 rsPattern2Period=25 rim_framework=framework_0 repetitionRsType1=2
    ...  \ factorRsSequence=1 offsetRsSequence=1 startRbForRs=1,50,100,150 numRsType1SetId=65536
    Execute Egate Command     cmd=${RS1}
    sleep  5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=${profile} action=activate

Generate RS1andRS2
    [Arguments]    ${profile}	${delay}	${nearfar}  ${globalfoforrs}=636672     ${startfreq1}=5     ${startfreq2}=53
    ${RS2}=    Catenate    SEPARATOR=
    ...  rimrs_testmode_nr profile_id=${profile} config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=11144
    ...  \ numRsSetId=1 rimRsType=rsType1AndType2 propagation_delay=${delay} rsNearFarConfig=${nearfar}
    ...  \ rsType1NScId=1,2,3,4,5,6,7,8 rsType2NScId=101,102,103,104,105,106,107,108
    ...  \ rsPattern1Period=50 rsPattern2Period=25 factorRsSequence=1 factorRsSequenceRS2=1 offsetRsSequence=1 offsetRsSequenceRS2=1
    ...  \ repetitionRsType1=2 repetitionRsType2=2 rim_framework=framework_1 numRsType2SetId=65536 numRsType1SetId=65536
    ...  \ globalF0ForRs=${globalfoforrs} startFreqOffsetForRs=${startfreq1},${startfreq2}
    Execute Egate Command     cmd=${RS2}
    sleep  5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=${profile} action=activate

Deactivate RS1
    [Arguments]    ${profile}
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=${profile} action=deactivate
    sleep  3s

Deactivate RS1andRS2
    [Arguments]    ${profile}
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=${profile} action=deactivate
    sleep  3s

Verify The Counter for No Muting
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${Special_slot} == 0
    Should be True    ${Preceding_DL_slot} == 0
    Should be True    ${Preceding_2_DL_slot} == 0

Register and Send High Data
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ue_id=1
    FOR    ${trf}    IN RANGE   ${1}   ${6}
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     dl_rate=100     pdu_id=1   trf_id=${trf}
    END
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     ul_rate=100     pdu_id=1   trf_id=1
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=1      Traffic_rate=mbps     ul_rate=100     pdu_id=1   trf_id=2
    sleep    10s

Check Tput
    [Arguments]    ${ue_id}=1   ${scell_idx}=0
    ${DATA_DL}    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
    Should be True    ${DATA_DL} > 400
    ${DATA_UL}    wts_sim_keywords.Get AVG UL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
    Should be True    ${DATA_UL} > 150


Modify NIDD parameters
    [Documentation]     This Keyword modify NIDD parameter as per the requirement of the feature CB005788
    [Arguments]        ${paramDst}='None'                  ${operation}=update
     ...                ${paramName}='None'                 ${paramValue}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramDst=${paramDst}        operation=${operation}
    ...          paramName=${paramName}         paramValue=${paramValue}
    sleep               60s
    [Teardown]          admin.Teardown admin

Online NIDD parameter change
     [Documentation]    This Keyword used to update NIDD parameter(one at a time)
     ...                and returns the result
     ...        [Arguments]    parameter        :  Parameter names to parsed
     ...                       paramDst         :  Dist name should be parsed
     ...                       paramValue       :  Value for the parameter to be assigned should be parsed
     ...                       operation        :  Deffault Value given as update, and can be parsed other operation if required
     ...                       should_activate  :  Deffault Value is True if you want to set this False then parse the parameter as False
     ...                       skip_parameter_relation_errors : Default Value is Trueif you want to set thisFalse then parse the parameter as False
     [Arguments]        ${paramName}='None'                 ${paramValue}='None'              ${timeout}=300
     ...                ${paramDst}='None'                  ${operation}=update
     ...                ${should_activate}=${True}          ${skip_parameter_relation_errors}=${True}
    admin.perform_parameter_recommissioning          parameter=${paramName}
     ...        value=${paramValue}             operation=${operation}                         dist_name=${paramDst}
     ...        skip_parameter_relation_errors=${skip_parameter_relation_errors}
     ...        should_activate=${should_activate}
    log to console      ${timeout}
