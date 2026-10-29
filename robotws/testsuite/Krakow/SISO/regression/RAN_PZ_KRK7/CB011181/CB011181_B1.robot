*** Settings ***
Documentation
...   author: Wioleta Święs (wioleta.swies@nokia.com)
...   maintainers: Bartłomiej Bieńko, Wioleta Święs, Lubomir Krzeminski
...   contact: Lubomir Krzemiński (lubomir.krzeminski@nokia.com)
...   contact: Adrianna Priotrkowska (adrianna.priotrkowska@nokia.com)
...   feature: CB012194 - FDD configurations with CPRI and OBSAI radio for ABIP/ABIQ #2
...
...   Introduction: CB011181 provides sets of FDD configuration blocks for CPRI and OBSAI RUs connected to ABIO/ABIN and ASOE.
...   Configuration blocks based on customer request and new RUs which has impact on customer's rollout.
...   The configuration block consists of BB cell set and RF cell set with a defined, proper fiber connections and cell allocation within SBTS.


Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
#Resource    taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_HWPTA_BB_Module_Reset.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Cell_Lock_Unlock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Cell_Block_Unblock.robot
Resource    taf/rfrl/procedures/resources/robot/Alarms.robot
Resource    ./resources/keywords.robot
Resource    testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Library      ute_ue
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    sg7keywords
Library      testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/CB011181/resources/CB011181_keywords.py    WITH NAME    CB011181_keywords
Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup       Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms

*** Variables ***
${UE_CAPABILITIES}                   QUECTEL_UE
${UE_TYPE}                           QUECTEL
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_PACKET_SIZE}               1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_DEVIATION}                 25%
${expected_tput_5G_DL}               400Mbits/sec
${expected_tput_5G_UL}               110Mbits/sec

${expected_tput_LTE_DL}              390Mbits/sec
${expected_tput_LTE_UL}              97bits/sec


${expected_tput_SA_DL}               200Mbits/sec
${expected_tput_SA_UL}               110Mbits/sec
${DATA_TRANSFER_DEFAULT_DURATION}    120s
${PARALLEL_STREAM_DL}                4
${PARALLEL_STREAM_UL}                2
${LTE_DEFAULT_BAND}                  7
${NR5G_DEFAULT_BAND}                 3
${APN_SA_NAME}                       5gsakrk
${APN_NSA_NAME}                      5gkrk


${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}
${CUSTOMERS_LIST}                   ${None}    # Customer list separated by comma
@{CUSTOM_ALARMS}                    @{EMPTY}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}            3
${BBMOD_RESET_TEST_ITERATION}=      20

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${QC_ID_UPGRADE}                    105403

${RP_CA}                            VRF_SiSo
${RP_ORGANIZATION}                  VRF_KRK_T07
${RP_LOCATION}                      VRF_KRK


*** Test Cases ***
CB011181_06_E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Setup]    Custom Test Setup
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    ${QC_ID_UPGRADE}=             CB011181_keywords.Get Qc Ids   ${TARGET_SW}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_UPGRADE}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}

    Check data transfer via Quectel    throughput_DL=${expected_tput_SA_DL}
    ...                                throughput_UL=${expected_tput_SA_UL}
    [Teardown]    Custom Test Teardown

CB011181_02_General_SiSo_Cell_block_and_unblock
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...                        Common Preconditions With Watching Alarms
    Start alarms watchdog
    General_SiSo_Auto_Cell_Block_Unblock

    Check data transfer via Quectel    throughput_DL=${expected_tput_SA_DL}
    ...                                throughput_UL=${expected_tput_SA_UL}

CB011181_18_Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change_from_GUI
    Cell_Lock_Unlock

    Check data transfer via Quectel    throughput_DL=${expected_tput_SA_DL}
    ...                                throughput_UL=${expected_tput_SA_UL}

CB011181_11_Manual_SiSo_SM_NR_RAT_reset
    sg7keywords.Reset RAT    NR
    Sleep    60s
    Wait Until Keyword Succeeds    20min    20s    Verify gNB is onAir
    Check data transfer via Quectel    throughput_DL=${expected_tput_SA_DL}
    ...                                throughput_UL=${expected_tput_SA_UL}

CB011181_23_General_SiSo_BB_sub-unit_reset_with_L3_call
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${BBMOD_RESET_TEST_ITERATION}
    ...                                     report=${False}
    Check data transfer via Quectel    throughput_DL=${expected_tput_SA_DL}
    ...                                throughput_UL=${expected_tput_SA_UL}

*** Keywords ***
Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Custom Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...               increase_timeout_for_update_sw=${900}
    ...               list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}

    #    Uncomment for RF50
    #    ${SOURCE_SW} =    IF    '${SOURCE_SW}'=='${None}'  Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    #    ${TARGET_SW} =    IF    '${TARGET_SW}'=='${None}'  Get Target Build   ELSE    Set Variable  ${TARGET_SW}
    #    @{CUSTOMERS_LIST} =    IF    '${CUSTOMERS_LIST}'!='${None}'  Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic

    ${SOURCE_SW}=    run keyword if  '${SOURCE_SW}'=='${None}'  Get CM Source Build
    ...   ELSE  Set Variable  ${SOURCE_SW}
    ${TARGET_SW}=    run keyword if  '${TARGET_SW}'=='${None}'  Get Target Build
    ...   ELSE  Set Variable  ${TARGET_SW}

    @{CUSTOMERS_LIST}=    Run Keyword If  '${CUSTOMERS_LIST}'!='${None}'
    ...                     Split String    ${CUSTOMERS_LIST}    ,
    ...                   ELSE
    ...                     Create List    Generic

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
