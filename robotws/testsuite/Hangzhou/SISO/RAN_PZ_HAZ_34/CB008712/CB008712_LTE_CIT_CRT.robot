*** Settings ***
Suite Setup           Run Keywords    robot_common_operations.Common Suite Setup  AND  SISO 8712_LTE Suite Setup
Suite Teardown        Run Keywords    robot_common_operations.Common Suite Teardown   AND    SISO 8712_LTE Suite Teardown
Test Timeout         600 min

Documentation
...    Author:Frank Luo
...    contact:frank.s.luo@nokia-sbell.com
...    squad group:SG_01
...    Feature CB008445 in 5G22R4 program

Force Tags            5G_RAN    5G_RAN_TDD    STATE_SW_UPLOADED  SBTS00

Resource  Resource/CB008712_Resource.robot


*** Test Cases ***
[1]General_SiSo_Commissioning_BTS_Template_Commissioning_1CC_20MHz
    [Documentation]   No L3Call, replace by 2CC commission
    [Tags]
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase053.General_SiSo_Commissioning_BTS_Template_Commissioning

[1]General_SiSo_Commissioning_BTS_Template_Commissioning_2CC_10MHz+20MHz
    [Documentation]   No L3Call
    [Tags]     Trunk_CIT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase053.General_SiSo_Commissioning_BTS_Template_Commissioning

[1][1.0] 5GC000584_RU_Module_Certificate_Integrity
    [Documentation]    No L3Call
    [Tags]    Trunk_CIT    23R2_CRT
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase013.5GC000584_RU_Module_Certificate_Integrity

[1][1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Documentation]   No L3Call
    [Tags]    Trunk_CIT    23R2_CRT
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase014.General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

[1][1.0] 5GC000561_eCPRI_sync_counters
    [Documentation]   No L3Call
    [Tags]    Trunk_CIT    23R2_CRT
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase015.5GC000561_eCPRI_sync_counters

[1][2.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Documentation]   No L3Call
    [Tags]
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase060.General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

#[1]Initiate_RF_Statistics_diagnostic_test_withoutL3call
#    [Documentation]   No L3Call
#    [Tags]    Trunk_CIT    23R2_CRT
#    [Timeout]
#    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
#    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
#    CommonCase025.Initiate_RF_Statistics_diagnostic_test_withoutL3call

[1][2.0] General_SiSo_BTS_startup_with_delayed_RF_link_setup
    [Documentation]   QC step3 and step4 require L3Call, but TA code not do L3Call
    [Tags]    Trunk_CIT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup
    ...         allowed_faults_ids=6830,6828,6833,6823,6829,6831,6827,6825
    ...                        AND    SetUp LTE_Case
    [Teardown]    Teardown LTE_Case
    CommonCase019.General_SiSo_BTS_startup_with_delayed_RF_link_setup

[1]Manual_SiSo_CALL_LTE_data_call_1CC_20MHz
    [Documentation]    Do L3Call
    [Tags]
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase.Manual_SiSo_CALL_LTE_data_call

[1]Manual_SiSo_CALL_LTE_data_call_2CC_10MHz+20MHz
    [Documentation]    Do L3Call in Cell1
    [Tags]    Trunk_CRT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase.Manual_SiSo_CALL_LTE_data_call_2CC
#[1][2.1] General_SiSo_Link_Diagnostic_and_Monitoring
#    [Documentation]   No L3Call, not adapt ASOE, ASIB+ABIO is pass
#    [Tags]
#    [Timeout]  60min
#    CommonCase020.General_SiSo_Link_Diagnostic_and_Monitoring

[1][0.1] Manual_SiSo_SM_LTE Cell_block_unblock_1CC
    [Documentation]    Do L3Call, replace by 2CC
    [Tags]
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase008.Manual_SiSo_SM_LTE_Cell_block_unblock

[1][0.1] Manual_SiSo_SM_LTE Cell_block_unblock_2CC
    [Documentation]    Do L3Call in Cell2
    [Tags]    Trunk_CRT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase008.Manual_SiSo_SM_LTE_Cell_block_unblock

[1][1.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Documentation]    Do L3Call in Cell2
    [Tags]    Trunk_CRT    23R2_CRT
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase007.Manual_SiSo_SM_RF_Module_lock_unlock

[1][1.0] Manual_SiSo_SM_LTE_RAT_reset
    [Documentation]    Do L3Call in Cell2
    [Tags]    Trunk_CRT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase004.Manual_SiSo_SM_NR_RAT_reset

[1]BS-RF__LTE_cell_graceful_shutdown_from_WebEm
    [Documentation]    Do L3Call in Cell2
    [Tags]    Trunk_CRT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase010.BS-RF__LTE_cell_graceful_shutdown_from_WebEm

[1][3.0] General_SiSo_Online_Cell_Addition_Deletion
    [Documentation]   Do L3Call
    [Tags]    Trunk_CRT    New_add
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp LTE_Case
    [Teardown]    Run Keywords    Teardown LTE_Case  AND  robot_common_operations.Common Case Teardown
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_LTE_2CC_20MHz_20MHz}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=lte
    COAM_Admin.BackupSCF    file_name=BackUPLTE_${TL_BASE_SCF_LTE_2CC_20MHz_20MHz}
    KW.General_SiSo_Online_Cell_addition_deletion_CBRS_LTE

*** Keywords ***
SISO 8712_LTE Suite Setup
    UTECloud.ForceAdaptCommissionFiles
    TestSuite.Start    TLConfigurationFile=TLConfiguration_LTE.py
    set suite variable      ${SAVE LOG DIRECTORY}    ${LOG_PATH}
    set suite variable      ${UPDATE_FILE_PATH}      ${LOG_PATH}
    set suite variable      ${SUITE_LOG_PATH}        ${LOG_PATH}
    set suite variable      ${CASE_LOG_PATH}         ${LOG_PATH}

#    ${StreamTarget}      ${version_Target}      Basic.GetStreamAndVersion
#    set suite variable    ${TARGETSW}    ${version_Target}
#    set suite variable    ${TargetStream}     ${StreamTarget}
#    set suite variable    ${OldCommissionSCF}    ${CFGFILE_PATH}/${TL_BASE_SCF}
    COAM_WebEM.Login
#    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    ${Active_SW_version}    string.split string    string=${version}[Active]
#    set suite variable    ${Active_SW_version}
    ${SW1}    string.split string    string=${Active_SW_version}    separator=_
    ${Active_SwVersion_8712}     convert to string    ${SW1}[-5]
    set suite variable    ${Active_SwVersion8712}
    COAM_WebEM.Logout
    ${is_lte}    set variable if  "${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}"=="lte"    true    false
#    ${TL_BASE_SCF}    set variable if    "${is_lte}"=="true"    ${TL_BASE_SCF_LTE}    ${TL_BASE_SCF_NR}
#    Run Keyword And Ignore error    KW.RestartSAS_UTE
#    FOR   ${ue_index}   IN   @{TLCommonConfig['MultiUECFG']['ue_index_for_call']}
#        ${res}  run keyword and ignore error   power_ue.Prepare UE
#        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
#        ...    detach_request=${TLCommonConfig['MultiUECFG']['${ue_index}']['detach_request']}
#        ...    power_reset=${TLCommonConfig['MultiUECFG']['${ue_index}']['power_reset']}
#    END
    AlarmWatchdog.add_allow_alarms    fault_id=4752
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${Active_SwVersion_8712}_SCF_SBTS00_LTE.xml
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=lte
    AlarmWatchdog.remove_allow_alarms    fault_id=4752
#    COAM_Admin.BackupSCF    file_name=BackUPLTE_${TL_BASE_SCF}
#    ${TL_BASE_SCF}    set suite variable    ${TL_BASE_SCF}
    gNB.FormatBTSID    lte=${is_lte}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl

SISO 8712_LTE Suite Teardown
    Run Keyword And Ignore error    KW.SISO 8712_LTE Suite Teardown

KW.SISO 8712_LTE Suite Teardown
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/SCF_SBTS00_NRFinal.xml
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr

SetUp LTE_Case
#    Run Keyword And Ignore error    KW.RestartSAS_UTE
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
#    Run Keyword And Ignore error    MultiUE.PrepareUE    UECFG=${TLCommonConfig['MultiUECFG']}
#    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF}
#    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=lte

Teardown LTE_Case
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore error    KW.GetSASLog_UTE
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Run Keyword And Ignore error    gNB.CollectSnapshot
    ...    ELSE    Run Keyword And Ignore error    gNB.CollectIMS2
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown