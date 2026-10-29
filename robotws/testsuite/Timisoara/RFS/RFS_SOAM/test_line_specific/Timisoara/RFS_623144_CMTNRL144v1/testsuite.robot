*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.robot
Resource    ../../../test_resources/CBTS_SBTS__CM__CBTS_Commissioning_RF_Sharing_from_Standalone_from_WebUI.robot
Resource    ../../../test_resources/CBTS_SBTS__CM__CBTS_Configuration_of_ALD_from_WebUI.robot
Resource    ../../../test_resources/CBTS_SBTS__CM__CBTS_TDD_SuperCell_Creation_Removal_from_WebUI.robot
Resource    ../../../test_resources/CBTS_SBTS__CM__SBTS_Configuration_of_EAC_from_WebUI.robot
Resource    ../../../test_resources/CBTS_SBTS__LOGS__Stability.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Cell_BlockUnblock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__FHGW_Reset.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.robot
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
&{ADD_IGNORED_ALARM_eCPRI}    alarm_id=7115    fault_id=4046
${CNI_127210_ENABLED}    ${True}
${USER_RTWP_CHECK}  ${FALSE}
${SCF_PATH_SUITE}    ${CURDIR}/../../../test_line_specific/Timisoara/RFS_623144_CMTNRL144v1/standaloneSCF.xml


*** Test Cases ***
[1]CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__cbts_vdu_reset_sbts_site_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    900
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    900
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${FHGW_CONNECT}    True
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_SBTS}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_CBTS}    True

    ...    AND    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    TC__CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state_check_ru_sw_package_and_nvm_integrity_on_ru_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3

    ...    AND    CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU
    TC__CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU
    [Teardown]    Run Keywords    CBTS_SBTS__STATE_Check_RU_SW_package_and_NVM_integrity_on_RU.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE__RM_Power_Off_On
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_POWER_ON_WRN_THR}    300
    ...    AND    Set Test Variable    ${RMOD_POWER_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${CB005763_CHECK}    False
    ...    AND    Set Test Variable    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

    ...    AND    CBTS_SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RM_Power_Off_On
    TC__CBTS_SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE__FHGW_Reset
    [Timeout]    28800
    Set Test Variable    ${runs}    8
    FOR    ${run}    IN RANGE   1    ${runs} + 1
        Run Keywords
        ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__fhgw_reset_alarms_definitions.py
        ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
        ...    AND    Set Test Variable    ${FHGW_ID_CUSTOM_LIST}    ALL
        ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900

        ...    AND    Set Test Variable    ${runs}    8
        ...    AND    Set Test Variable  ${stop_run}    False
        ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__FHGW_Reset
        ...    AND    Set Library Search Order    CBTS_SBTS__STATE__FHGW_Reset
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    CBTS_SBTS__STATE__FHGW_Reset.TC Setup
        Set Test Variable  ${TEST STATUS}
        Run Keyword If    '${TEST STATUS}' == 'FAIL'
        ...    Run Keyword And Continue On Failure    CBTS_SBTS__STATE__FHGW_Reset.TC Teardown
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    TC__CBTS_SBTS__STATE__FHGW_Reset
        Set Test Variable  ${TEST STATUS}
        Run Keyword And Continue On Failure    CBTS_SBTS__STATE__FHGW_Reset.TC Teardown
    END
    Restore Resource Search Order



[1]CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
    [Timeout]    28800
    Set Test Variable    ${runs}    2
    FOR    ${run}    IN RANGE   1    ${runs} + 1
        Run Keywords
        ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__fhgw_rinline_link_break_alarms_definitions.py
        ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
        ...    AND    Set Test Variable    ${FHGW_ID_CUSTOM_list}    ALL
        ...    AND    Set Test Variable    ${SWITCH_USER_LINK_DOWN_list}    cmntrl144-down-C4
        ...    AND    Set Test Variable    ${SWITCH_PASSWORD_LINK_DOWN_list}    Aikon_144-down
        ...    AND    Set Test Variable    ${SWITCH_USER_LINK_UP_list}    cmntrl144-up-C4
        ...    AND    Set Test Variable    ${SWITCH_PASSWORD_LINK_UP_list}    Aikon_144-up
        ...    AND    Set Test Variable    ${SWITCH_IP_ADDRESS_list}    10.255.11.5
        ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    240

        ...    AND    Set Test Variable    ${runs}    2
        ...    AND    Set Test Variable  ${stop_run}    False
        ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
        ...    AND    Set Library Search Order    CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break.TC Setup
        Set Test Variable  ${TEST STATUS}
        Run Keyword If    '${TEST STATUS}' == 'FAIL'
        ...    Run Keyword And Continue On Failure    CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break.TC Teardown
        ${TEST STATUS}  ${output}=    Run Keyword And Ignore Error    TC__CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
        Set Test Variable  ${TEST STATUS}
        Run Keyword And Continue On Failure    CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break.TC Teardown
    END
    Restore Resource Search Order



[1]CBTS_SBTS__STATE__Cell_BlockUnblock
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__cell_blockunblock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${SBTS_RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    35
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    35
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    15
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    15
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    17
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    200

    ...    AND    CBTS_SBTS__STATE__Cell_BlockUnblock.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__Cell_BlockUnblock
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__Cell_BlockUnblock
    TC__CBTS_SBTS__STATE__Cell_BlockUnblock
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__Cell_BlockUnblock.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__CM__CBTS_TDD_SuperCell_Creation_Removal_from_WebUI
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_tdd_supercell_creation_removal_from_webui_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${NR_CELL_ID}    53445
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900

    ...    AND    CBTS_SBTS__CM__CBTS_TDD_SuperCell_Creation_Removal_from_WebUI.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_TDD_SuperCell_Creation_Removal_from_WebUI
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_TDD_SuperCell_Creation_Removal_from_WebUI
    TC__CBTS_SBTS__CM__CBTS_TDD_SuperCell_Creation_Removal_from_WebUI
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_TDD_SuperCell_Creation_Removal_from_WebUI.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    BL2330H60AJ
    ...    AND    Set Test Variable    ${pMax_value}    46

    ...    AND    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Teardown
    ...    AND    Restore Resource Search Order



[2]CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    BL2214N400R
    ...    AND    Set Test Variable    ${pMax_value}    46

    ...    AND    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Teardown
    ...    AND    Restore Resource Search Order



[3]CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    BL2221N405R
    ...    AND    Set Test Variable    ${pMax_value}    46

    ...    AND    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Teardown
    ...    AND    Restore Resource Search Order



[4]CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    YK214600105
    ...    AND    Set Test Variable    ${pMax_value}    46

    ...    AND    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__CM__SBTS_Configuration_of_EAC_from_WebUI
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__sbts_configuration_of_eac_from_webui_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    BL2330H60AJ

    ...    AND    CBTS_SBTS__CM__SBTS_Configuration_of_EAC_from_WebUI.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__SBTS_Configuration_of_EAC_from_WebUI
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__SBTS_Configuration_of_EAC_from_WebUI
    TC__CBTS_SBTS__CM__SBTS_Configuration_of_EAC_from_WebUI
    [Teardown]    Run Keywords    CBTS_SBTS__CM__SBTS_Configuration_of_EAC_from_WebUI.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__CM__CBTS_Commissioning_RF_Sharing_from_Standalone_from_WebUI
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_commissioning_rf_sharing_from_standalone_from_webui_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${VDU_SCF_PATH}    ${SCF_PATH_SUITE}
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900

    ...    AND    CBTS_SBTS__CM__CBTS_Commissioning_RF_Sharing_from_Standalone_from_WebUI.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Commissioning_RF_Sharing_from_Standalone_from_WebUI
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Commissioning_RF_Sharing_from_Standalone_from_WebUI
    TC__CBTS_SBTS__CM__CBTS_Commissioning_RF_Sharing_from_Standalone_from_WebUI
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Commissioning_RF_Sharing_from_Standalone_from_WebUI.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__CM__CBTS_Configuration_of_ALD_from_WebUI
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_configuration_of_ald_from_webui_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}     BL2330H60AJ
    ...    AND    Set Test Variable    ${MHA_SERIAL_NUMBER}    AJ212630782_1
    ...    AND    Set Test Variable    ${RET_SERIAL_NUMBER}    CSF4192526
    ...    AND    Set Test Variable    ${RET_PRODUCT_CODE}    86010148
    ...    AND    Set Test Variable    ${MHA_PRODUCT_CODE}    473051A.103
    ...    AND    Set Test Variable    ${MHA_TYPE}    Nokia
    ...    AND    Set Test Variable    ${RMOD_ANT_PORT_MHA_AMPLIFIED_ANT_LINE_LNA1}    ANT1
    ...    AND    Set Test Variable    ${RMOD_ANT_PORT_MHA_AMPLIFIED_ANT_LINE_LNA2}    ANT2
    ...    AND    Set Test Variable    ${RMOD_ANT_PORT_MHA_HDLC}    ANT1
    ...    AND    Set Test Variable    ${RMOD_ANT_PORT_MHA_DC_POWER}    ANT1
    ...    AND    Set Test Variable    ${RMOD_ANT_PORT_DC_VOLTAGE_LEVEL}    ANT1
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900

    ...    AND    CBTS_SBTS__CM__CBTS_Configuration_of_ALD_from_WebUI.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Configuration_of_ALD_from_WebUI
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Configuration_of_ALD_from_WebUI
    TC__CBTS_SBTS__CM__CBTS_Configuration_of_ALD_from_WebUI
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Configuration_of_ALD_from_WebUI.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rmod_fan_temp_control_profiles_cb010874_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_CLIMATE_CONTROL_PROFILING_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}
    ...    AND    Set Test Variable    ${CB010874_SNAPSHOT_REMOVE}    True
    ...    AND    Set Test Variable    ${file_name_regex}    .*SOAP.*[.]xml[.]gz
    ...    AND    Set Test Variable    ${delay_to_snapshot_save}    30

    ...    AND    CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    TC__CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.TC Teardown
    ...    AND    Restore Resource Search Order



[1]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS1_NR66 BTS1_NR3 BTS2_LTE
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS1 BTS1 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR NR NR LTE
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;DEFAULT
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}     uplink_downlink uplink_downlink uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${THPUT_CHECK_BTS_LOGS}    False
    ...    AND    Set Test Variable    ${UL_UE_GROUP_UEs}    0 0 0 0

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE__RM_LockUnlock
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_LOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${RMOD_UNLOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    CBTS_SBTS__STATE__RM_LockUnlock.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RM_LockUnlock
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RM_LockUnlock
    TC__CBTS_SBTS__STATE__RM_LockUnlock
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RM_LockUnlock.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Timeout]    28800
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__secondary_controller_sharedrm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_SBTS}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_CBTS}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    TC__CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__LOGS__Stability
    [Timeout]    54000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    900
    ...    AND    Set Test Variable    ${CHECK_INTERVAL}    30
    ...    AND    Set Test Variable    ${CHECK_SW_VERSION_CBTS}    True
    ...    AND    Set Test Variable    ${CHECK_SW_VERSION_SBTS}    True
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4}    Current

    ...    AND    CBTS_SBTS__LOGS__Stability.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__LOGS__Stability
    ...    AND    Set Library Search Order    CBTS_SBTS__LOGS__Stability
    TC__CBTS_SBTS__LOGS__Stability
    [Teardown]    Run Keywords    CBTS_SBTS__LOGS__Stability.TC Teardown
    ...    AND    Restore Resource Search Order
