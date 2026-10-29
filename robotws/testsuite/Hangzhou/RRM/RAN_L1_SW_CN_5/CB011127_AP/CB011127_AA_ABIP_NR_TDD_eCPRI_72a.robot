*** Settings ***
Documentation
...    Author:  You Xingkai
...    Contact: xingkai.you@nokia-sbell.com
...    Feature: CB011127
...    Release: 25R3
...    In this feature CB011127  RIM-RS detection resources per L1 pool will be dynamically shared on different cells.

Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs

Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF
Resource    ../resources/Airphone/Airphone_resource.robot

*** Variables ***
${tl_type}    AP_LOOO/tdd_sansa_cmwv/FS/6cell_ecpri_CB011127/
&{enable_vendor_dict}    maxResPerSubcellForFc48Prbs=60

${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

*** Test Cases ***
CB011127_AA_TC09_NR_FR1_TDD_eCPRI_half_ABIP_Airphone_72a_6x100MHz_4DL4UL_cell_without_beamforming_5GC001208_96PRB
    [Documentation]
    ...    This case is to verify ...
    [Tags]    ABIP    CB011127    Trunk    airphone
    Check rimrs L1 capacity in syslog
    Ue Attach to 6 cells and data traffic
    Activate RI for 6 cells
    Activate RIMRS    6    25
    Wait For Fault To Be Up    7525    6    800
    Wait For Fault To Be Up    7527    6    800
    [Teardown]    Run Keywords    Append To List    ${ALLOWED_FAULT}    7525    7527    7535
    ...    AND    Common Test Teardown And Stop Capture Logs
    ...    AND    Remove Values From List    ${ALLOWED_FAULT}    7525    7527    7535


*** Keywords ***
Check rimrs L1 capacity in syslog
    ${output}    Run    cd ${SUITE_LOG_DIRECTORY}; unzip ${SUITE_LOG_DIRECTORY}/startup_1_logs.zip startup_1_logs/btslog.LOG
    Log To Console    ${output}
    # filte regexp from btslog.LOG:
    ${regexp}    Set Variable    actNrRimRsResourcePooling:1 maxResources: L1Pool: {48:336, 96:240} Subcell: {48:60, 96:80}
    ${rimrs_l1_capacity_filter}=    Run    cat ${SUITE_LOG_DIRECTORY}/startup_1_logs/btslog.LOG | grep "${regexp}"
    Should Not Be Empty    ${rimrs_l1_capacity_filter}    [ ERROR ] actNrRimRsResourcePooling is NOT found in startup_1_logs/btslog.LOG.

Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/tdd_sansa_cmwv/FS/6cell_ecpri_CB011127/    cfg=wts.cfg    withCommission=True    isVendor=True

Ue Attach to ${num} cells and data traffic
    FOR    ${id}    IN RANGE    ${num}
        ue_register    ue_id=${id+1}    cell_id=${id+1}
        Traffic Start And Throughput Verify    ue_id=${id+1}    dl_mbps=40    ul_mbps=40      thresh=0.8    level=ue_stats_nr
    END

UE stop data transfer and detach for ${num} cells
    FOR    ${id}    IN RANGE    ${num}
        traffic_data_stop   ue_id=${id+1}
    END

Activate RI for ${num} cells
    Perform Egate Command
    ...    command=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_RI}
    FOR    ${id}    IN RANGE    ${num}
        Perform Egate Command    command=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=${id+1} profile_id=7 action=activate
    END

Activate RIMRS
    [Arguments]    ${num_of_cells}    ${rsPattern1Period}    ${startRbForRs}=20,70,120,170
    FOR    ${id}    IN RANGE    ${num_of_cells}
        ${rim_rs_profile}=    Catenate    SEPARATOR=
        ...     rimrs_testmode_nr profile_id=${id+1} config_mode=standalone aggressor_cell=${id+1} victim_cell=7 rsSetId=12346
        ...     \ propagation_delay=6 rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=${rsPattern1Period} rsPattern2Period=25
        ...     \ factorRsSequence=1 offsetRsSequence=1 startRbForRs=${startRbForRs} rimRsTxPower=-300 repetitionRsType1=4 numRsType1SetId=65536
        Perform Egate Command    command=${rim_rs_profile}
        #Sleep    5s
        Perform Egate Command    command=cell_testmode_set_nr cell_id=${id+1} gnb=2 testmode=rim_rs profile_id=${id+1} action=activate
    END

Wait For Fault To Be Up
    [Arguments]    ${active_fault_id}    ${num_of_fault}=1    ${timeout}=800
    sbts_admin.Setup Admin    timeout=120    name=alarm
    Wait Until Keyword Succeeds    ${timeout}    60s    Run Keywords    Log To Console    \n[INFO] Getting Active Fault : ${active_fault_id} ...
    ...    AND    Get Specific Active Fault    ${active_fault_id}    ${num_of_fault}
    [Teardown]    sbts_admin.teardown admin    connection=alarm

Get Specific Active Fault
    [Arguments]    ${active_fault_id}    ${num_of_fault}
    ${faults_list}=     Create List
    ${alarms_state}=    sbts_admin.Get Active Alarms    connection=alarm    # both $ and @ are OK
    FOR    ${alarm}    IN    @{alarms_state}
        ${faultId}    Get From Dictionary    ${alarm}    faultId
        Run Keyword If    ${faultId}==${active_fault_id}    Append To List    ${faults_list}    ${alarm}
    END
    ${fault_count}    Get Length    ${faults_list}
    Should Be True    ${fault_count}>=${num_of_fault}    \n[ERROR] Fault:${active_fault_id} is NOT actived.
    FOR    ${fault}    IN    @{faults_list}
        ${faultId}      Get From Dictionary    ${fault}    faultId
        ${faultName}    Get From Dictionary    ${fault}    faultName
        ${severity}     Get From Dictionary    ${fault}    severity
        ${alarmObj}     Get From Dictionary    ${fault}    impactedCellsList
        Log To Console    | ${severity} | faultId : ${faultId} | faultName : ${faultName} | alarming Object : ${alarmObj}[0]
        ${supplAlarmInfo}    Run Keyword If    ${active_fault_id}==7527    Get From Dictionary    ${fault}    supplAlarmInfo
        Run Keyword If    ${active_fault_id}==7527    Log To Console    [INFO] RIM-RS SetId : ${supplAlarmInfo}
    END
