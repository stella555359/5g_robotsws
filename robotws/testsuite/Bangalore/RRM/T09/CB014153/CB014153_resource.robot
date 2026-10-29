*** Settings ***
Documentation    :copyright: Nokia
...              :authors: noble.iyeswariyam_edison@nokia.com
...              :contact: noble.iyeswariyam_edison@nokia.com

Library        python/check_alarm.py
Library        python/parse.py
Library        ta5g_enb
Library        taf.sw.scout    WITH NAME     scout
Library        taf.transport.ssh         WITH NAME    taf_ssh
Variables      ta5g_global_var
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       ../../../resources/robot/common_log_collection.robot
Resource       ../../../resources/robot/Gnb.robot
Resource       ../../../resources/robot/Setup_Env.robot
Resource       ../../../resources/robot/Airphone.robot
Resource       ../../../resources/robot/PM_Counters.robot
Resource       ../../../resources/robot/Common_Keywords.robot
Resource       ../5GC000937/resources/5GC000937_Keywords.robot
Resource       ../CB008370/resources/CB008370_resources.robot
Resource       ../../../resources/robot/common_log_collection.robot
Resource       ../../../resources/robot/wts_sim_keywords.robot
Resource       ../../../resources/robot/PM_Counters.robot


*** Keywords ***
Verify Fault Description
    [Arguments]    ${faultid}    ${faultname}    ${description}=None  ${cell}=NRCELL-1
    ${cellid}   Catenate    SEPARATOR=    MRBTS-1/NRBTS-1/${cell}
    ${result}    check_alarm.check_alarm_description     ${faultid}    ${faultname}    ${description}   ${cellid}
    run keyword and continue on failure   Run Keyword if   ${result}!=${True}   Fail   Alarm is not matching

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

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

Activate RIC
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
    [Arguments]    ${profile}    ${delay}
    ${RS1}=    Catenate    SEPARATOR=
    ...  rimrs_testmode_nr profile_id=${profile} config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=22223
    ...  \ numRsSetId=1 rimRsType=rsType1AndType2 rsNearFarConfig=2 propagation_delay=${delay}
    ...  \ rsType1NScId=1,2,3,4,5,6,7,8 numRbForRs=48 rsPattern1Period=50 rsPattern2Period=25
    ...  \ rim_framework=framework_1 repetitionRsType1=4 repetitionRsType2=4 factorRsSequence=1 factorRsSequenceRS2=1
    ...  \ offsetRsSequence=1 offsetRsSequenceRS2=1 numRsType1SetId=65536 numRsType2SetId=65536
    ...  \ startFreqOffsetForRs=0,48 globalF0ForRs=528432
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

Generate RS1MultipleSetID
    [Arguments]
    ${set}=    Catenate    SEPARATOR=
    ...  rimrs_testmode_nr profile_id=200 config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=100
    ...  \ numRsSetId=3 propagation_delay=43 rimRsType=rsType1AndType2 rsNearFarConfig=2 rimRsTxPower=-600
    ...  \ rimRsTxPowerRS2=-600 rsSetId=110 numRsSetId=3 propagation_delay=16 rimRsType=rsType1AndType2
    ...  \ rsNearFarConfig=0 rimRsTxPower=-330 rimRsTxPowerRS2=-330 rsType1NScId=1,2,3,4,5,6,7,8
    ...  \ rsType2NScId=1,2,3,4,5,6,7,8 numRbForRs=48 rsPattern1Period=50 rsPattern2Period=25
    ...  \ rim_framework=framework_1 repetitionRsType1=4 repetitionRsType2=4 factorRsSequence=1
    ...  \ factorRsSequenceRS2=1 offsetRsSequence=1 offsetRsSequenceRS2=1 numRsType1SetId=65536
    ...  \ numRsType2SetId=65536 startFreqOffsetForRs=48 globalF0ForRs=528432
    Execute Egate Command     cmd=${set}
    sleep  5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=200 action=activate

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
    [Arguments]    ${ue_id}=1   ${scell_idx}=0    ${dl_data}=400    ${ul_data}=150
    ${DATA_DL}    wts_sim_keywords.Get AVG DL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
    Should be True    ${DATA_DL} > ${dl_data}
    ${DATA_UL}    wts_sim_keywords.Get AVG UL DATA TRAFFIC For Given CC     ${ue_id}    ${scell_idx}
    Should be True    ${DATA_UL} > ${ul_data}


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


RIM RS1 RS2 Detection and Mitigation and Check Alarm
    Start Log    btslog
    Activate RI
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=1200
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Generate RS1    profile=200		delay=43
    Wait For Fault To Be Up     fault_id=7527   timeout=2200
    Log to Console    RS1 is generated
    Verify Fault Description    faultid=${7527}    faultname=RIM-RS detected
    ...     description=RIM RS1 is detected, detected RIM RS1 setIDs list is 22223
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH special slot plus three preceding slots
    Log to Console    Counter Validation
    Verify The Counter for Special and 3 DL Slots with RIM RS1
    Deactivate RS1    profile=200
    Wait For Fault To Be Down   fault_id=7527   timeout=400
    Wait For Fault To Be Down   fault_id=7535   timeout=100
	Log to Console    Counter Validation for No Muting
	Verify The Counter for No Muting
    Deactivate RI
    Log to console     RI deactivated and waiting for 7525 down after RI disappear
    Wait For Fault To Be down     fault_id=7525   timeout=400
    sleep   200s    reason=Wait time for Framework1
    ${syslog_path}    Stop Log    btslog    test_scenario=syslog
    sleep    5s

Verify The Counter for Special and 3 DL Slots with RIM RS1
    Wait until the next Measurement Period starts
#    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${UL_SYMB_IMP_RI}   Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00001    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_3_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00288    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${NUM_RIM_RS1_Detected}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00005   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_21}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00189   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_22}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00190   moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${Special_slot} >= 298.0
    Should be True    ${Preceding_DL_slot} >= 298.0
    Should be True    ${Preceding_2_DL_slot} >= 298.0
    Should be True    ${Preceding_3_DL_slot} >= 298.0
    Should be True    ${NUM_RIM_RS1_Detected} != 0
    Log to console    Number of UL Symbol IMpacted by RI is ${UL_SYMB_IMP_RI}
    Log to console    Number of Detected SET ID is ${NUM_RIM_RS1_Detected}


Validate PM counter for NUM_DL_SYMB_MUT_RIM_MITG
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${NUM_DL_SYMB_MUT_RIM_MITG}   Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55395C00001    moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${NUM_DL_SYMB_MUT_RIM_MITG} >= 298.0


Expect Fault Should Present
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=COAM    ${severity}=${None}    ${alarmId}=${None}
    log to console    \nExpect Fault ${faultId} Should Present
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR    ${alarm}    IN    @{alarms}
        Exit For Loop If    ${alarm_num}==${0}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...                  Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
        ...                  Run Keyword If    '${source}'!='${None}'
        ...                  Should Contain    ${alarm['notifier']}    ${source}    case_insensitive=True    AND
        ...                  Run Keyword If    '${severity}'!='${None}'
        ...                  Should Contain    ${alarm['severity']}    ${severity}    case_insensitive=True    AND
        ...                  Run Keyword If    '${alarmId}'!='${None}'
        ...                  Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.


Expect Fault Should Absent
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to check the ${faultId} alarm should NOT exist.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${faultId} | No | The indicated alarm fault id, default is 23 |
    ...    | ${source} | No | The customized information should exist in "notifier" in alarm, default is None |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Expect Fault Should Absent | faultid=${23} |
    ...    | Expect Fault Should Absent | faultid=${23} | connection=coam_conn |
    ...
    ${status}    Run Keyword And Return Status    Expect Fault Should Present    faultId=${faultId}
    ...                                                                          source=${source}
    ...                                                                          connection=${connection}
    Run Keyword If    ${status}==${True}    Fail    faultId ${faultId} reported by source ${source} is still present on gnb.

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI

Activate RI and RIM-RS
    sleep  10s  reason=Wait for Onlinemodification
    Activate RI
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=1200
    Generate RS1    profile=200		delay=43
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Wait For Fault To Be Up     fault_id=7527   timeout=2200
    Log to Console    RS1 is generated
    Verify Fault Description    faultid=${7527}    faultname=RIM-RS detected
    ...     description=Both RIM RS1 and RS2 are detected
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH three preceding slots

Validate Alarm and PM counter and traffic
    Validate PM counter for NUM_DL_SYMB_MUT_RIM_MITG
    Expect Fault Should Absent    faultId=7525
    Expect Fault Should Absent    faultId=7527
    Expect Fault Should Absent    faultId=7532
    Expect Fault Should Absent    faultId=7535
    Check Tput    ue_id=1   scell_idx=0    dl_data=70    ul_data=20
    parse.parse_csv     ${LOG_PATH}/partialslot/output_dl.csv    ${field1}
    ...     ${field2}  ${field3}  ${tddframe}  ${LOG_PATH}/partialslot/${output_file}
    ${result}    parse.validate_slot_muting    ${slotnum}    ${tddframe}    ${LOG_PATH}/partialslot/${output_file}    ${field1}     ${field2}
    Run Keyword And Continue On Failure    Run Keyword if   ${result} !=1   Fail   SLIV and partialslotmuting check failed

RIM RS1 RS2 Detection and Mitigation with Higher Rimrsthreshold and Check Alarm
    Activate RIC
    Log to console    RI Triggered
    Wait For Fault To Be Up     fault_id=7525   timeout=1200
    Verify Fault Description    faultid=${7525}    faultname=Remote interference detected
    Generate RS1MultipleSetID
    Wait For Fault To Be Up     fault_id=7527   timeout=2200
    Log to Console    RS1 is generated
    Verify Fault Description    faultid=${7527}    faultname=RIM-RS detected
    ...     description=Both RIM RS1 and RS2 are detected
    Wait For Fault To Be Up     fault_id=7535   timeout=100
    Verify Fault Description    faultid=${7535}    faultname=RIM downlink muting for mitigation
    ...    description=DL mitigation on PDSCH and PDCCH special slot plus the PDSCH preceding slot
    Log to Console    Counter Validation

Deactivate RI and RS1
    Deactivate RS1    profile=200
    Wait For Fault To Be Down   fault_id=7527   timeout=600
    Wait For Fault To Be Down   fault_id=7535   timeout=100
    Log to Console    Counter Validation for No Muting
    Verify The Counter for No Muting
    Deactivate RI
    Log to console     RI deactivated and waiting for 7525 down after RI disappear
    Wait For Fault To Be down     fault_id=7525   timeout=400
    sleep   200s    reason=Wait time for Framework1

Verify The Counter for Special and 1 DL Slots with Higher Rimrsthreshold
#    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${UL_SYMB_IMP_RI}   Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00001    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_3_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00288    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${NUM_RIM_RS1_Detected}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00005   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${TOT_SUCC_RIM_RS_REC}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55308C00174   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_21}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00189   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_22}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00190   moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${Special_slot} > 0.0
    Should be True    ${Preceding_DL_slot} > 0.0
    Should be True    ${Preceding_2_DL_slot} == 0.0
    Should be True    ${Preceding_3_DL_slot} == 0.0
    Should be True    ${NUM_RIM_RS1_Detected} == 3.0
    Should be True    ${TOT_SUCC_RIM_RS_REC} > 0
    Log to console    Number of UL Symbol IMpacted by RI is ${UL_SYMB_IMP_RI}
    Log to console    Number of Detected SET ID is ${NUM_RIM_RS1_Detected}

Verify The Counter for Special and 3 DL Slots with with Lower Rimrsthreshold
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${UL_SYMB_IMP_RI}   Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00001    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Special_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00003    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00281    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_2_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00282    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${Preceding_3_DL_slot}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55194C00288    moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${NUM_RIM_RS1_Detected}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00005   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${TOT_SUCC_RIM_RS_REC}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55308C00174   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_21}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00189   moc=MRBTS-1/NRBTS-1/NRCELL-1
    ${RS1_22}     Get_PM_counter_value    pm_files_location=${PM_dir1}    pi_id=M55194C00190   moc=MRBTS-1/NRBTS-1/NRCELL-1
    Should be True    ${Special_slot} > 0.0
    Should be True    ${Preceding_DL_slot} > 0.0
    Should be True    ${Preceding_2_DL_slot} > 0.0
    Should be True    ${Preceding_3_DL_slot} > 0.0
    Should be True    ${NUM_RIM_RS1_Detected} >= 3.0
    Should be True    ${TOT_SUCC_RIM_RS_REC} > 0
    Log to console    Number of UL Symbol IMpacted by RI is ${UL_SYMB_IMP_RI}
    Log to console    Number of Detected SET ID is ${NUM_RIM_RS1_Detected}



