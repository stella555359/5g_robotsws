*** Settings ***

Documentation     author: Bhanu Vamsi Krishna
...               contact: vamsi.gundlur@nokia.com
...               Description: CB009514: 7-2 enhanced eCPRI FH feature parity (NR FR1 TDD)

Resource        ../../../Resources/robot/ue_operations.robot
Resource        ../../../Resources/robot/suite_common_keywords.robot
Resource        ../../Cell_Lock_Unlock/LockUnlock_Keywords.robot
Resource        ../../Carrier_Aggregation/CA_Common_Keywords.robot

Suite Setup       Common Suite Setup    feature_folder=CB009514

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${dl_tput}                       50
${ul_tput}                       4
${dl_tput_2}                     100
${ul_tput_2}                     20
${dl_tput_3}                     150
${ul_tput_3}                     10
@{SA_UE_List}                    1    6    2    7    3    8    4    9    5    10
@{TC2_SA_UE_list}                41    42    43    44    45    46    47    48    49    50
@{CA_SA_UE}                      1
${CA_SA_HO_UE}                   1
@{dl_tput_list}                  150
@{CA_ul_tput}                    8
@{DL_scell_index}                0    1
@{UL_scell_index}                0
${NUMBER_OF_CELLS}               2
@{CellIndex}                     0
${TC1_configs}                   ${CURDIR}/Config_Files/TC1
${TC2_configs}                   ${CURDIR}/Config_Files/TC2
${EDAEMON_PORT}                  50000
${WAIT_TIME}                     5 min
${RETRY_INTERVAL}                15sec
${UE_THRESHOLD}                  5
${rlc_check}                     UE CONTEXT RELEASE COMPLETE
${UE_idle}                       IS IDLE
${MultiUEScenario_configs}       ${CURDIR}/Config_Files/9514_MultiUEScenario
@{SA_UE_CELL1}                   1   2   3   4   5   6   7   8   9   10   11   12   13   14   15
@{NSA_UE_CELL1}                  21  22  23  24  25  26  27  28  29  30   31   32   33   34   35
@{SA_UE_CELL2}                   51  52  53  54  55  56  57  58  59  60   61   62   63   64   65
@{NSA_UE_CELL2}                  71  72  73  74  75  76  77  78  79  80   81   82   83   84   85
${ONLY_DL_TPUT}                  15
${ONLY_UL_TPUT}                  5
${COMBO_DL_TPUT}                 10
${COMBO_UL_TPUT}                 4
${UES_PER_GROUP}                 5
${bearer_id}                     2
${pdu_id_multiue}                3
@{NSA_scell_index}               8



*** Test Cases ***
CB009514_H_MUE_SA_CA_Blind_1S_2CC_TDD_4DL2UL_100MHz
    [Documentation]    CB009514: 7-2 enhanced eCPRI FH feature parity (NR FR1 TDD) L3 SA call with multi-UE on
    ...    1S_2CC_with_Blind scell addition and Blind scell activation.
    [Tags]    AP_REG    CB009514_TC2    H_9514
    [Setup]    Generic Test Setup    feature=CB009514    custom_config=True    custom_config_folder=${TC2_configs}
    ...    cell_deployment=SA    syslog_err_count=516
    Perform SA UE Register for Blind ScellAddition and Blind ScellActivation    ${SA_UE_List}
    ...    scell_index_list=${CA_SA_UE}
    Start parallel UL and DL traffic with multiple trf_id for all SA UEs    ${SA_UE_List}
    ...    dl_tput=${dl_tput_list}    ul_tput=${CA_ul_tput}
    Run keyword And Continue On Failure    Validate throughput from UE stats for all CA UEs    ${CA_SA_UE}
    ...    ${dl_tput_list}    ${CA_ul_tput}    ${DL_scell_index}    ${UL_scell_index}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${CA_SA_UE}
    Perform Cell Lock and Unlock    ${NUMBER_OF_CELLS}
    Wait Until Keyword Succeeds    ${WAIT_TIME}    ${RETRY_INTERVAL}    Ensure UE SIB Decoding Is Successful
    Perform SA UE Register for Blind ScellAddition and Blind ScellActivation    ${TC2_SA_UE_list}
    ...    scell_index_list=${CA_SA_UE}
    Start parallel UL and DL traffic with multiple trf_id for all SA UEs    ${TC2_SA_UE_list}
    ...    dl_tput=${dl_tput_list}    ul_tput=${CA_ul_tput}
    Run keyword And Continue On Failure    Validate throughput from UE stats for all CA UEs    ${TC2_SA_UE_list}
    ...    ${dl_tput_list}    ${CA_ul_tput}    ${DL_scell_index}    ${UL_scell_index}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${TC2_SA_UE_list}
    [Teardown]    Test Teardown    sa_ue_list=${TC2_SA_UE_list}

CB009514_Verify_SA_TDD_cmWave_inter_frequency_intra_gNB_HO_with_A3_RSRP
    [Documentation]    CB009514: 7-2 enhanced eCPRI FH feature parity (NR FR1 TDD) Inter frequency Intra gNB Handover
    ...    with A3 RERP.
    [Tags]    AP_REG    CB009514_TC3    H_9514
    [Setup]    Generic Test Setup    feature=CB009514    custom_config=True    custom_config_folder=${TC2_configs}
    ...    cell_deployment=SA    syslog_err_count=142
    Register For SA UEs    ${CA_SA_UE}
    Start Traffic for multiple SA UEs    ${CA_SA_UE}    uplink_tput=${ul_tput_3}   downlink_tput=${dl_tput_3}
    Validate UE stats for multiple UEs    ${CA_SA_UE}    ${dl_tput_3}    ${ul_tput_3}    ${CellIndex}
    Trigger Intra gNB Interfreq SA Forward HO    ${CA_SA_HO_UE}
    Validate UE stats for multiple UEs    ${CA_SA_UE}    ${dl_tput_3}    ${ul_tput_3}    ${CellIndex}
    Trigger Intra gNB Interfreq SA Reverse HO    ${CA_SA_HO_UE}
    Validate UE stats for multiple UEs    ${CA_SA_UE}    ${dl_tput_3}    ${ul_tput_3}    ${CellIndex}
    Perform Stop Traffic and Detach SA UEs for Blind ScellAddition    ${CA_SA_UE}
    [Teardown]    Test Teardown    sa_ue_list=${CA_SA_UE}

CB009514_Verify RRC release due to RLC Packet drop_with_inter_frequency_intra_gNB_HO scenario
    [Documentation]    CB009514: 7-2 enhanced eCPRI FH feature parity (NR FR1 TDD) Inter frequency Intra gNB Handover
    ...    with A3 RERP and validate DL tput dip due to RLC packet drop.
    [Tags]    AP_REG    CB009514_TC4    P2_REG
    [Setup]    Generic Test Setup    feature=CB009514    custom_config=True    custom_config_folder=${TC2_configs}
    ...    cell_deployment=SA    syslog_err_count=80
    Activate rlf in scf
    dlrlcdrop nr testmode profile creation    profile_id=2    lcid=4    num_of_times_to_drop=32    sn=0xFFFFFFFF
    Register For SA UEs    ${CA_SA_UE}
    Start Traffic for multiple SA UEs    ${CA_SA_UE}    uplink_tput=${ul_tput_3}   downlink_tput=${dl_tput_3}
    Validate UE stats for multiple UEs    ${CA_SA_UE}    ${dl_tput_3}    ${ul_tput_3}    ${CellIndex}
    Associate UE to testmode    id=${CA_SA_HO_UE}    testmode=dlrlcdrop    profile_id=2    action=activate
    Sleep    10s
    Check Egate Log With Message and count    msg_regexp=${rlc_check}
    Check Egate Log With Message and count    msg_regexp=${UE_idle}
    Ensure UE Deregister Is Successful    ue_id=${CA_SA_HO_UE}    ue_deregister_type=switch_off    by=ue
    Register For SA UEs    ${CA_SA_UE}
    Start Traffic for multiple SA UEs    ${CA_SA_UE}    uplink_tput=${ul_tput_3}   downlink_tput=${dl_tput_3}
    Validate UE stats for multiple UEs    ${CA_SA_UE}    ${dl_tput_3}    ${ul_tput_3}    ${CellIndex}
    Trigger Intra gNB Interfreq SA Forward HO    ${CA_SA_HO_UE}
    Validate UE stats for multiple UEs    ${CA_SA_UE}    ${dl_tput_3}    ${ul_tput_3}    ${CellIndex}
    Associate UE to testmode    id=${CA_SA_HO_UE}    testmode=dlrlcdrop    profile_id=2    action=activate
    Sleep    10s
    Check Egate Log With Message and count    msg_regexp=${rlc_check}
    Check Egate Log With Message and count    msg_regexp=${UE_idle}    count=2
    Ensure UE Deregister Is Successful    ue_id=${CA_SA_HO_UE}    ue_deregister_type=switch_off    by=ue
    [Teardown]    Run Keywords    Revert gNB configuration    AND    Test Teardown    sa_ue_list=${CA_SA_UE}

# As a workaround for teardown issue, Let this testcase be located as last TC in this robot file
CB009514_G_MUE_L3_SA_call_on_1S_2CC_with_cell-1_20Mhz_and_cell-2_80mhz
    [Documentation]    CB009514: 7-2 enhanced eCPRI FH feature parity (NR FR1 TDD) L3 SA call with multi-UE on
    ...    1S_2CC_with_cell-1_20Mhz_and_cell-2_80mhz
    [Tags]    AP_REG    CB009514_TC1    G_9514
    [Setup]    Generic Test Setup    feature=CB009514    custom_config=True    custom_config_folder=${TC1_configs}
    ...    cell_deployment=SA    syslog_err_count=181
    Register and Start Traffic For SA UEs different pdu
    Validate Throughput For SA UEs Different PDU with Different throughput
    Stop Traffic and Detach multiple SA UEs different pdu
    Perform Cell Lock and Unlock    ${NUMBER_OF_CELLS}
    Wait Until Keyword Succeeds    ${WAIT_TIME}    ${RETRY_INTERVAL}    Ensure UE SIB Decoding Is Successful
    Register For SA UEs different pdu
    Start Traffic for multiple SA UEs different pdu
    Validate Throughput For SA UEs Different PDU with Different throughput
    Stop Traffic and Detach multiple SA UEs different pdu
    [Teardown]    Teardown_TC1    ${SA_UE_List}

CB009514_H_L3Call_On_SA_and_NSA_Multi_UE_scenario
    [Tags]    AP_REG    multiUE
    [Setup]    Generic Test Setup    feature=MultiUE    custom_config=True    custom_config_folder=${MultiUEScenario_configs}
    ...    cell_deployment=SANSA    syslog_err_count=516
    Register For SA UEs    ${SA_UE_CELL1}
    sleep    10s
    Register For SA UEs    ${SA_UE_CELL2}
    sleep    10s
    Attach For NSA UEs    ${NSA_UE_CELL1}    target_cells=1
    sleep    10s
    Attach For NSA UEs    ${NSA_UE_CELL2}    target_cells=2
    sleep    10s
    Start Three Group Traffic For UE List    ${SA_UE_CELL1}    ue_type=SA
    sleep   30s
    Start Three Group Traffic For UE List    ${SA_UE_CELL2}    ue_type=SA
    sleep   30s
    Start Three Group Traffic For UE List    ${NSA_UE_CELL1}    ue_type=NSA
    sleep   30s
    Start Three Group Traffic For UE List    ${NSA_UE_CELL2}    ue_type=NSA
    sleep   2min
    Run keyword And Continue On Failure    Validate Three Group Traffic For UE List    ${SA_UE_CELL1}    ue_type=SA
    Run keyword And Continue On Failure    Validate Three Group Traffic For UE List    ${SA_UE_CELL2}    ue_type=SA
    Run keyword And Continue On Failure    Validate Three Group Traffic For UE List    ${NSA_UE_CELL1}    ue_type=NSA
    Run keyword And Continue On Failure    Validate Three Group Traffic For UE List    ${NSA_UE_CELL2}    ue_type=NSA
    Stop Traffic and Detach SA UEs     ${SA_UE_CELL1}
    Stop Traffic and Detach SA UEs     ${SA_UE_CELL2}
    Stop Traffic and Detach NSA UEs    ${NSA_UE_CELL1}
    Stop Traffic and Detach NSA UEs    ${NSA_UE_CELL2}
    [Teardown]    Test Teardown    sa_ue_list=${SA_UE_CELL1}

*** Keywords ***
Activate rlf in scf
    Set global variable    ${NRBTS}    MRBTS-1/NRBTS-1
    Download original SCF file and get the original feature flag value
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS}    actGnbInitRlf=true
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Download original SCF file and get the original feature flag value
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}

Revert gNB configuration
    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_used_during_TC.xml
    return from keyword if    '${Gnb_Revert}' == 'False'
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS}    actGnbInitRlf=false
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait for gNB To Be Ready

Register and Start Traffic For SA UEs different pdu
    [Documentation]    Registers and starts traffic for Standalone User Equipment (SA UEs) with different Packet
    ...                Data Unit (PDU) configurations.
    ...                - Assigns PDU ID 1 for UEs with IDs <= ${UE_THRESHOLD}, using ${ul_tput} and ${dl_tput} as
    ...                  uplink and downlink throughput values.
    ...                - Assigns PDU ID 2 for UEs with IDs > ${UE_THRESHOLD}, using ${ul_tput_2} and ${dl_tput_2} as
    ...                  uplink and downlink throughput values.
    ...                - This keyword is useful for scenarios requiring different traffic configurations for
    ...                  different UE groups.
    [Arguments]    ${UE_List}=${SA_UE_List}
    FOR    ${ue_id}    IN    @{UE_List}
        Run Keyword If    ${ue_id} <= ${UE_THRESHOLD}
        ...    Register and Start Traffic For SA UEs    ${ue_id}    ${ul_tput}    ${dl_tput}    pdu=1
        ...    ELSE    Register and Start Traffic For SA UEs    ${ue_id}    ${ul_tput_2}    ${dl_tput_2}    pdu=2
    END

Register For SA UEs different pdu
    [Documentation]    Registers Standalone User Equipment (SA UEs) with different Packet Data Unit (PDU) IDs.
    ...                - Assigns PDU ID 1 for UEs with IDs <= ${UE_THRESHOLD}.
    ...                - Assigns PDU ID 2 for UEs with IDs > ${UE_THRESHOLD}.
    ...                Useful for scenarios requiring different configurations for different UE groups.
    [Arguments]    ${UE_List}=${SA_UE_List}
    FOR    ${ue_id}    IN    @{UE_List}
        Run Keyword If    ${ue_id} <= ${UE_THRESHOLD}
        ...    Register For SA UEs    ${ue_id}    pdu_id=1
        ...    ELSE    Register For SA UEs    ${ue_id}    pdu_id=2
    END

Start Traffic for multiple SA UEs different pdu
    [Documentation]    Starts traffic for SA UEs with different PDU configurations based on UE ID thresholds.
    ...                - UEs with IDs <= ${UE_THRESHOLD} use ${ul_tput} and ${dl_tput} with PDU ID 1.
    ...                - UEs with IDs > ${UE_THRESHOLD} use ${ul_tput_2} and ${dl_tput_2} with PDU ID 2.
    [Arguments]    ${UE_List}=${SA_UE_List}
    FOR    ${ue_id}    IN    @{UE_List}
        Run Keyword If    ${ue_id} <= ${UE_THRESHOLD}
        ...    Start Traffic for multiple SA UEs    ${ue_id}    ${ul_tput}    ${dl_tput}    pdu_id=1
        ...    ELSE    Start Traffic for multiple SA UEs    ${ue_id}    ${ul_tput_2}    ${dl_tput_2}    pdu_id=2
    END

Validate Throughput For SA UEs Different PDU with Different throughput
    [Documentation]    Validates throughput (tput) from UE stats for multiple UEs based on UE ID thresholds.
    ...                - UEs with IDs <= ${UE_THRESHOLD} validate against ${dl_tput} and ${ul_tput}.
    ...                - UEs with IDs > ${UE_THRESHOLD} validate against ${dl_tput_2} and ${ul_tput_2}.
    [Arguments]    ${UE_List}=${SA_UE_List}
    FOR    ${ue_id}    IN    @{UE_List}
        Run Keyword If    ${ue_id} <= ${UE_THRESHOLD}
        ...    validate ue stats for multiple ues   ${ue_id}    ${dl_tput}    ${ul_tput}    ${CellIndex}
        ...    ELSE    validate ue stats for multiple ues   ${ue_id}    ${dl_tput_2}    ${ul_tput_2}    ${CellIndex}
    END

Stop Traffic and Detach multiple SA UEs different pdu
    [Documentation]    Stops traffic and detaches SA UEs with different PDU configurations based on UE ID thresholds.
    ...                - UEs with IDs <= ${UE_THRESHOLD} use PDU ID 1.
    ...                - UEs with IDs > ${UE_THRESHOLD} use PDU ID 2.
    [Arguments]    ${UE_List}=${SA_UE_List}
    FOR    ${ue_id}    IN    @{UE_List}
        Run Keyword If    ${ue_id} <= ${UE_THRESHOLD}
        ...    Stop Traffic and Detach SA UEs   ${ue_id}    pdu=1
        ...    ELSE    Stop Traffic and Detach SA UEs   ${ue_id}    pdu=2
    END

Teardown_TC1
    [Documentation]    Performs teardown for CB009514 Testcase 1.
    ...                - Stops L1L2 BIP logs if '${BIP_CAPTURE_NEEDED}' is 'True'.
    ...                - Cleans up on failure if '${TEST_STATUS}' is 'FAIL'.
    ...                - Executes common test teardown and increments the test case index.
    [Arguments]    ${UE_List}=${EMPTY}
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True'    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword If    '${TEST_STATUS}' == 'FAIL'    Cleanup On Failure    ${UE_List}
    Common Test Teardown
    Increment TC Index

Cleanup On Failure
    [Documentation]    Cleans up resources on failure for the specified UEs.
    ...                - Logs the cleanup process to the console.
    ...                - Stops traffic and detaches UEs if the UE list is not empty.
    [Arguments]    ${UE_List}=${EMPTY}
    Log To Console    On Failure: cleanup ongoing for UEs: ${UE_List}
    Run Keyword If    "${UE_List}" != "${EMPTY}"    Run Keyword and Ignore Error
    ...    Stop Traffic and Detach multiple SA UEs different pdu    ${UE_List}
    Log To Console    Cleanup completed for UEs: ${UE_List}

Start Three Group Traffic For UE List
    [Documentation]    Starts traffic for a UE list divided into three groups:
    ...                - First ${UES_PER_GROUP} UEs: Only DL traffic
    ...                - Next ${UES_PER_GROUP} UEs: Only UL traffic (${ONLY_UL_TPUT} Mbps)
    ...                - Last ${UES_PER_GROUP} UEs: Both UL (${COMBO_UL_TPUT} Mbps) and DL (${COMBO_DL_TPUT} Mbps)
    [Arguments]    ${ue_list}    ${ue_type}=SA
    ${list_length}=    Get Length    ${ue_list}
    ${group1_end}=    Evaluate    min(${UES_PER_GROUP}, ${list_length})
    ${group2_end}=    Evaluate    min(${UES_PER_GROUP} * 2, ${list_length})

    # First group: Only DL traffic
    FOR    ${i}    IN RANGE    0    ${group1_end}
        ${ue_id}=    Get From List    ${ue_list}    ${i}
        Run Keyword If    '${ue_type}' == 'SA'
        ...    Start Traffic    ue_id=${ue_id}    dir=dl    pdu=${pdu_id_multiue}    mbps=${ONLY_DL_TPUT}
        ...    ELSE
        ...    Start Traffic    ue_id=${ue_id}    id=${bearer_id}    dir=dl    mbps=${ONLY_DL_TPUT}
    END

    # Second group: Only UL traffic
    FOR    ${i}    IN RANGE    ${group1_end}    ${group2_end}
        ${ue_id}=    Get From List    ${ue_list}    ${i}
        Run Keyword If    '${ue_type}' == 'SA'
        ...    Start Traffic    ue_id=${ue_id}    dir=ul    pdu=${pdu_id_multiue}    mbps=${ONLY_UL_TPUT}
        ...    ELSE
        ...    Start Traffic    ue_id=${ue_id}    id=${bearer_id}    dir=ul    mbps=${ONLY_UL_TPUT}
    END

    # Third group: Both UL and DL traffic
    FOR    ${i}    IN RANGE    ${group2_end}    ${list_length}
        ${ue_id}=    Get From List    ${ue_list}    ${i}
        Run Keyword If    '${ue_type}' == 'SA'
        ...    Start Traffic for multiple SA UEs    ${ue_id}    uplink_tput=${COMBO_UL_TPUT}    downlink_tput=${COMBO_DL_TPUT}
        ...    ELSE
        ...    Start Traffic for multiple NSA UEs    ${ue_id}    uplink_tput=${COMBO_UL_TPUT}     downlink_tput=${COMBO_DL_TPUT}
    END

Validate Three Group Traffic For UE List
    [Documentation]    Validates traffic for a UE list divided into three groups with different patterns.
    ...                Validates against expected throughput for DL-only, UL-only, and combo traffic.
    [Arguments]    ${ue_list}    ${ue_type}=SA
    ${list_length}=    Get Length    ${ue_list}
    ${group1_end}=    Evaluate    min(${UES_PER_GROUP}, ${list_length})
    ${group2_end}=    Evaluate    min(${UES_PER_GROUP} * 2, ${list_length})

    # First group: Validate DL only
    FOR    ${i}    IN RANGE    0    ${group1_end}
        ${ue_id}=    Get From List    ${ue_list}    ${i}
        Run Keyword If    '${ue_type}' == 'SA'
        ...    Validate UE stats for multiple UEs    ${ue_id}    ${ONLY_DL_TPUT}    0    ${CellIndex}
        ...    ELSE
        ...    Validate UE stats for multiple UEs    ${ue_id}    ${ONLY_DL_TPUT}    0    ${NSA_scell_index}
    END

    # Second group: Validate UL only
    FOR    ${i}    IN RANGE    ${group1_end}    ${group2_end}
        ${ue_id}=    Get From List    ${ue_list}    ${i}
        Run Keyword If    '${ue_type}' == 'SA'
        ...    Validate UE stats for multiple UEs    ${ue_id}    0    ${ONLY_UL_TPUT}    ${CellIndex}
        ...    ELSE
        ...    Validate UE stats for multiple UEs    ${ue_id}    0    ${ONLY_UL_TPUT}    ${NSA_scell_index}
    END

    # Third group: Validate both UL and DL
    FOR    ${i}    IN RANGE    ${group2_end}    ${list_length}
        ${ue_id}=    Get From List    ${ue_list}    ${i}
        Run Keyword If    '${ue_type}' == 'SA'
        ...    Validate UE stats for multiple UEs    ${ue_id}    ${COMBO_DL_TPUT}    ${COMBO_UL_TPUT}    ${CellIndex}
        ...    ELSE
        ...    Validate UE stats for multiple UEs    ${ue_id}    ${COMBO_DL_TPUT}    ${COMBO_UL_TPUT}    ${NSA_scell_index}
    END

