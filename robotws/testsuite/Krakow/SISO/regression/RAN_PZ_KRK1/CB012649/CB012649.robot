*** Settings ***
Documentation
...   Test suite for regression testing of feature CB012649
...   author: Malgorzata Pietka
...   contact: malgorzata.pietka@nokia.com

Resource     taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_gNB_Site_Reset_From_WebUI.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_BTS_Site_Reset.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Library      taf/rfrl/csv4all/CSV4AllTestCases.py
Library      OperatingSystem
Resource     ./resources/resources.robot
Resource     ./procedures/Manual_SiSo_CM_Recommissioning.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags    CA_VRF_KRK

Suite Setup        Common Suite Setup With OnAir Test Line Preparation
...                increase_timeout_for_update_sw=${1800}
...                 prefix_tag=CB012649
Suite Teardown      Common Suite Teardown

Test Setup          Common Preconditions With Watching Alarms and NR cells set to barred     @{Cells_To_Set_Barred}
Test Teardown       Common Postconditions With Watching Alarms and NR cells set to not barred    @{Cells_To_Set_Unbarred}


*** Variables ***
${RP_CA}                                    VRF_SiSo
${RP_LOCATION}                              VRF_KRK
${RP_ORGANIZATION}                          VRF_KRK_T01

${COLLECT_LOGS_DURING_DATA_TRANSFER}        ${False}
${ENABLE_RACH_OBSERVER}                     ${False}
${logs_path}                                ${LOG_PATH}

#L3 call
${capabilities}                             REAL_UE_2
@{cell_ids}                                 NRCELL-0    NRCELL-1
@{Cells_To_Set_Barred}                      1
@{Cells_To_Set_Unbarred}                    0    1
${deviation}                                20%
${duration}                                 60s
${protocol}                                 tcp
${tputUl_cell10Mhz}                         12.5 Mbits/sec
${tputDl_cell10Mhz}                         74 Mbits/sec
${tputUl_Cell80Mhz}                         160 Mbits/sec
${tputDl_cell80Mhz}                         770 Mbits/sec
${reboot_ue}                            True
${timeout_reboot_ue}                    100

#KPI Site reset
@{CUSTOMERS_LIST}=          Generic
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF
${SHOULD_BE_REPORTED}=      ${True}
${ACTIVATION_RESET_LOOPS}   100
${USE_DCAP}                 False
${REPORT_COMMENT}           UUF_CB012649
${CALCULATE_KPI}           True
${QC_ID}                   192355
${STOP_TEST_AFTER_FAIL}    False
${TOPOLOGY}                CLOUD_5G_CLASSICAL_QUECTEL_ASOE_AWPNB

${HARDWARE_CHECK_TIMEOUT}=      1800
${DISABLE_SYSLOG_CHECK}=        ${False}
@{SYSLOG_IGNORED_PRINTS}=       INF

&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...                         verify_syslog=${DISABLE_SYSLOG_CHECK}
...                         syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}

@{NODES}                   ${NODE1}


*** Test Cases ***
[1]CB012649_A_C4_General_SiSo_Cell_block_and_unblock
   Prepare Ue for L3 Call              capabilities=${capabilities}
   ...                                 reboot_ue=${True}
   General SiSo Cell block and unblock
   Run Keyword And Continue On Failure  Verify L3 call
    ...                                 deviation=${deviation}
    ...                                 duration=${duration}
    ...                                 protocol=${protocol}
    ...                                 tputUl=${tputUl_cell10Mhz}
    ...                                 tputDl=${tputDl_cell10Mhz}
    ue.Detach Ue           UE           timeout=100
    Set Cells To Barred and not Barred  cells_to_be_barred=0
    ...                                 cells_to_be_not_barred=1
   ue.Reboot UE     UE                 timeout=100
   Run Keyword And Continue On Failure  Verify L3 call
    ...                                 deviation=${deviation}
    ...                                 duration=${duration}
    ...                                 protocol=${protocol}
    ...                                 tputUl=${tputUl_Cell80Mhz}
    ...                                 tputDl=${tputDl_cell80Mhz}

[1]CB012649_A_C4_SiSo_SM_BTS_Site_Reset
    Prepare Ue for L3 Call              capabilities=${capabilities}
    ...                                 reboot_ue=${True}
    General_SiSo_Auto_BTS_Site_Reset
    Run Keyword And Continue On Failure  Verify L3 call
    ...                                 deviation=${deviation}
    ...                                 duration=${duration}
    ...                                 protocol=${protocol}
    ...                                 tputUl=${tputUl_cell10Mhz}
    ...                                 tputDl=${tputDl_cell10Mhz}
    ue.Detach Ue           UE           timeout=100
    Set Cells To Barred and not Barred  cells_to_be_barred=0
    ...                                 cells_to_be_not_barred=1
    ue.Reboot UE     UE                 timeout=100
    Run Keyword And Continue On Failure  Verify L3 call
    ...                                 deviation=${deviation}
    ...                                 duration=${duration}
    ...                                 protocol=${protocol}
    ...                                 tputUl=${tputUl_Cell80Mhz}
    ...                                 tputDl=${tputDl_cell80Mhz}

[1]CB012649_A_C4_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    Prepare Ue for L3 Call              capabilities=${capabilities}
    ...                                 reboot_ue=${True}
    Run Keyword And Continue On Failure  Verify L3 call
    ...                                 deviation=${deviation}
    ...                                 duration=${duration}
    ...                                 protocol=${protocol}
    ...                                 tputUl=${tputUl_cell10Mhz}
    ...                                 tputDl=${tputDl_cell10Mhz}
    ue.Detach Ue           UE           timeout=100
    Set Cells To Barred and not Barred  cells_to_be_barred=0
    ...                                 cells_to_be_not_barred=1
    ue.Reboot UE     UE                 timeout=100
    Run Keyword And Continue On Failure  Verify L3 call
    ...                                 deviation=${deviation}
    ...                                 duration=${duration}
    ...                                 protocol=${protocol}
    ...                                 tputUl=${tputUl_Cell80Mhz}
    ...                                 tputDl=${tputDl_cell80Mhz}

[1]CB012649_A_C4_General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    Lock and Unlock Cells with Verifying Cell Status
    Prepare Ue for L3 Call              capabilities=${capabilities}
    ...                                 reboot_ue=${True}
    Run Keyword And Continue On Failure  Verify L3 call
    ...                                 deviation=${deviation}
    ...                                 duration=${duration}
    ...                                 protocol=${protocol}
    ...                                 tputUl=${tputUl_cell10Mhz}
    ...                                 tputDl=${tputDl_cell10Mhz}
    ue.Detach Ue           UE           timeout=100
    Set Cells To Barred and not Barred  cells_to_be_barred=0
    ...                                 cells_to_be_not_barred=1
    ue.Reboot UE     UE                 timeout=100
    Run Keyword And Continue On Failure  Verify L3 call
    ...                                 deviation=${deviation}
    ...                                 duration=${duration}
    ...                                 protocol=${protocol}
    ...                                 tputUl=${tputUl_Cell80Mhz}
    ...                                 tputDl=${tputDl_cell80Mhz}

[1]CB012649_A_C4_Manual_SiSo_CM_Recommissioning
    [Timeout]    20h
    [Setup]     Common Preconditions With Watching Alarms
    Manual_SiSo_CM_Recommissioning
    [Teardown]  Common Postconditions With Watching Alarms

[1][1.0]E2E_TL_Activation_Reset_with_OAM_KPI
    # This testcase will activate sw in loops
    # Starting SW will be candidate software and will be activated alternately to candidate T1 software
    [Timeout]   24h
    [Tags]      reset
    E2E TL ACTIVATION RESET TEST
    ...    ${NODES}
    ...	   ${NODE1}
    ...    ${ACTIVATION_RESET_LOOPS}
    ...    report=${SHOULD_BE_REPORTED}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    use_dcap=${USE_DCAP}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${REPORT_COMMENT}
    ...    topology=${TOPOLOGY}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
