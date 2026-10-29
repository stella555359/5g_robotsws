*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    14400
    Set Test Variable    ${runs}    5
    FOR    ${run}    IN RANGE   1    ${runs} + 1
        Run Keywords
        ...    No Operation
        ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
        ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
        ...    AND    Set Test Variable    ${BTS3_testline_object}
        ...    AND    Set Test Variable    ${BTS4_testline_object}
        ...    AND    Set Test Variable    ${BTS1_source_sw}
        ...    AND    Set Test Variable    ${BTS2_source_sw}
        ...    AND    Set Test Variable    ${BTS3_source_sw}
        ...    AND    Set Test Variable    ${BTS4_source_sw}
        ...    AND    Set Test Variable    ${BTS1_target_sw}
        ...    AND    Set Test Variable    ${BTS2_target_sw}
        ...    AND    Set Test Variable    ${BTS3_target_sw}
        ...    AND    Set Test Variable    ${BTS4_target_sw}
        ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
        ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
        ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
        ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
        ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}
		...    4773,1815,7300,7513,7511,7509,4655,4654,4651,1898,4452,4655,4654,61649,4651,1898,4220,16,6328,4564
        ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
		...    4773,1815,7300,7513,7511,7509,4655,4654,4651,1898,4452,4655,4654,61649,4651,1898,4220,16,6328,4564
        ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
        ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
        ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
        ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
        ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
        ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
        ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
        ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
        ...    AND    Set Test Variable    ${ROLLBACK_REVERSE_ORDER}    False
        ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
        ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
        ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    TMO US
        ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
        ...    AND    Set Test Variable    ${KPI_NAMES}    kpi2a
        ...    AND    Set Test Variable    ${KPI_THRESHOLDS}    600
        ...    AND    Set Test Variable    ${ADDITIONAL_KPI}    kpi2j
        ...    AND    Set Test Variable    ${SWCONFIG_MODIFICATION}    True
        ...    AND    Set Test Variable    ${HW_FILE_MIGRATION_CHECK}    True
        ...    AND    Set Test Variable    ${USE_DCAP}    False
        ...    AND    Set Test Variable    ${L3_CALL_METHOD}    ${None}
        ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
        ...    AND    Set Test Variable    ${REPORT}    True
        ...    AND    Set Test Variable    ${QC_PROJECT}    ${None}
        ...    AND    Set Test Variable    ${QC_DOMAIN}    ${None}
        ...    AND    Set Test Variable    ${QC_ID}    ${None}
        ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
        ...    AND    Set Test Variable    ${TOPOLOGY}    ${None}
        ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
        ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
        ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T06
        ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}
		...    AND    Set Test Variable    ${ENABLE_SNAPSHOT_FOR_PASSED_TC}    True

        ...    AND    Set Test Variable    ${runs}    5
        ...    AND    Set Test Variable  ${stop_run}    False
        ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
        ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    UUF_SW_UPGRADE_ROLLBACK.TC Setup
        Set Test Variable  ${TEST STATUS}
        Run Keyword If    '${TEST STATUS}' == 'FAIL'
        ...    Run Keyword And Continue On Failure    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    TC__UUF_SW_UPGRADE_ROLLBACK
        Set Test Variable  ${TEST STATUS}
        Run Keyword And Continue On Failure    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    END
    Restore Resource Search Order



[1]SBTS_SBTS__STATE__BTS_Power_Off_On
    [Timeout]    14400
    Set Test Variable    ${runs}    5
    FOR    ${run}    IN RANGE   1    ${runs} + 1
        Run Keywords
        ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts_power_off_on_alarms_definitions.py
        ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
        ...    AND    Set Test Variable    ${BTS_LIST}    BTS1
        ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
        ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
        ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
        ...    AND    Set Test Variable    ${BTS_POWER_ON_WRN_THR_LIST}    600
        ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
        ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
        ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
        ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
        ...    AND    Set Test Variable    ${ENABLE_SNAPSHOT_FOR_PASSED_TC}    True

        ...    AND    Set Test Variable    ${runs}    5
        ...    AND    Set Test Variable  ${stop_run}    False
        ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
        ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Setup
        Set Test Variable  ${TEST STATUS}
        Run Keyword If    '${TEST STATUS}' == 'FAIL'
        ...    Run Keyword And Continue On Failure    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Teardown
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    TC__SBTS_SBTS__STATE__BTS_Power_Off_On
        Set Test Variable  ${TEST STATUS}
        Run Keyword And Continue On Failure    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Teardown
    END
    Restore Resource Search Order



[2]SBTS_SBTS__STATE__BTS_Power_Off_On
    [Timeout]    14400
    Set Test Variable    ${runs}    5
    FOR    ${run}    IN RANGE   1    ${runs} + 1
        Run Keywords
        ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts_power_off_on_alarms_definitions.py
        ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
        ...    AND    Set Test Variable    ${BTS_LIST}    BTS2
        ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
        ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
        ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
        ...    AND    Set Test Variable    ${BTS_POWER_ON_WRN_THR_LIST}    600
        ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
        ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
        ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
        ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
	    ...    AND    Set Test Variable    ${ENABLE_SNAPSHOT_FOR_PASSED_TC}    True

        ...    AND    Set Test Variable    ${runs}    5
        ...    AND    Set Test Variable  ${stop_run}    False
        ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
        ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Setup
        Set Test Variable  ${TEST STATUS}
        Run Keyword If    '${TEST STATUS}' == 'FAIL'
        ...    Run Keyword And Continue On Failure    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Teardown
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    TC__SBTS_SBTS__STATE__BTS_Power_Off_On
        Set Test Variable  ${TEST STATUS}
        Run Keyword And Continue On Failure    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Teardown
    END
    Restore Resource Search Order



[1]SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
    [Timeout]    14400
    Set Test Variable    ${runs}    5
    FOR    ${run}    IN RANGE   1    ${runs} + 1
        Run Keywords
        ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__common_startup_alarms_definitions.py
        ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
        ...    AND    Set Test Variable    ${SBTS_POWER_ON_WRN_THR}    600
        ...    AND    Set Test Variable    ${SBTS_MAX_WAIT_TIME}    900
	    ...    AND    Set Test Variable    ${ENABLE_SNAPSHOT_FOR_PASSED_TC}    True

        ...    AND    Set Test Variable    ${runs}    5
        ...    AND    Set Test Variable  ${stop_run}    False
        ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
        ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.TC Setup
        Set Test Variable  ${TEST STATUS}
        Run Keyword If    '${TEST STATUS}' == 'FAIL'
        ...    Run Keyword And Continue On Failure    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.TC Teardown
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    TC__SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup
        Set Test Variable  ${TEST STATUS}
        Run Keyword And Continue On Failure    SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.TC Teardown
    END
    Restore Resource Search Order



[1]SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
    [Timeout]    14400
    Set Test Variable    ${runs}    5
    FOR    ${run}    IN RANGE   1    ${runs} + 1
        Run Keywords
        ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__site_reset_from_webem_cb007447_alarms_definitions.py
        ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
        ...    AND    Set Test Variable    ${BTS_RESET}    BOTH
        ...    AND    Set Test Variable    ${KPI_LIST}    kpi1a
        ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR_LIST}    600
        ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR_LIST}    600
        ...    AND    Set Test Variable    ${cpriSyncBreakTime}
        ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}
        ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
        ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
        ...    AND    Set Test Variable    ${PM_Counters_Check}    True
        ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
        ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    False
        ...    AND    Set Test Variable    ${ASOx_counters_flag}    False
	    ...    AND    Set Test Variable    ${ENABLE_SNAPSHOT_FOR_PASSED_TC}    True

        ...    AND    Set Test Variable    ${runs}    5
        ...    AND    Set Test Variable  ${stop_run}    False
        ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
        ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447.TC Setup
        Set Test Variable  ${TEST STATUS}
        Run Keyword If    '${TEST STATUS}' == 'FAIL'
        ...    Run Keyword And Continue On Failure    SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447.TC Teardown
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    TC__SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
        Set Test Variable  ${TEST STATUS}
        Run Keyword And Continue On Failure    SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447.TC Teardown
    END
    Restore Resource Search Order