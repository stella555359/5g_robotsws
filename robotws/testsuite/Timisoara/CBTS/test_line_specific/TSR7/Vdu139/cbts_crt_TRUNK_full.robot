*** Settings ***
Documentation
...  Tests for VDU139 with names from qc

#Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_5GC_dRNIC_vDU131_O_AEHC  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../../LOGS/test_resources/LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI.robot
Resource    ../../../LOGS/test_resources/LOGS__CB009077_CLOUD_RU_check.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check.robot
Resource    ../../../LOGS/test_resources/LOGS__CB013203_vCU_snapshot_with_SDL.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct.robot
Resource    ../../../LOGS/test_resources/LOGS__CB012144-CR-A-RU_POST_data_verify_in_snapshot.robot
Resource    ../../../LOGS/test_resources/LOGS__CB012144-CR-A-RU_POST_data_verify_with_controlled_radio_reset.robot
Resource    ../../../LOGS/test_resources/LOGS__CR_CB014065_TC11_NMS_AlarmKeyword_Match_vDU_vCU.robot
Resource    ../../../LOGS/test_resources/LOGS__CR_CB014065_TC2_NMS_SignatureKeyword_Match_vCU.robot

Suite Teardown    Copy file logs

*** Variables ***

${k8s _IP139}    10.5.14.254

${VDU_OAM_IP}    10.5.15.114
${VCU_OAM_IP}    10.5.15.126
#${NETACT_LAB}    &{srnclab1047}
${netact}    ${NETACT1047}
*** Test Cases ***

TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_synchronization_status_from_vDU
    [Setup]    Run Keywords    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU
    TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_synchronization_status_from_vDU
    [Teardown]    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.TC Teardown

LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.robot
    [Setup]    Run Keywords    LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller
    TC__LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller
    [Teardown]    LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.TC Teardown

CB013203_A_Download_SDL_data_snapshot_for_both_namespaces_and_key-prefixes_via_WebEM_vCU_MNO_OCP_cluster
    [Setup]    Run Keywords    LOGS__CB013203_vCU_snapshot_with_SDL.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB013203_vCU_snapshot_with_SDL
    TC__LOGS__CB013203_vCU_snapshot_with_SDL
    [Teardown]    LOGS__CB013203_vCU_snapshot_with_SDL.TC Teardown

CB011146_D_CR_ROBUSTNESS_BTS_Read_Only_User_Operations_Check
    [Setup]    Run Keywords    LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check
    TC__LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check
    [Teardown]    LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check.TC Teardown

CB011146_D_CR_Rest_API_get_CellStatus
    [Setup]    Run Keywords    LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus
    TC__LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus
    [Teardown]    LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus.TC Teardown

CB010415-B_03_CP18_radio_module_temperature_supervision
    [Setup]    Run Keywords    LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision
    TC__LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision
    [Teardown]    LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision.TC Teardown

CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor
    [Setup]    Run Keywords    LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor
    TC__LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor
    [Teardown]    LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor.TC Teardown

CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI
    [Setup]    Run Keywords    LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI
    TC__LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI
    [Teardown]    LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI.TC Teardown

Automated__LOGS__CB009077_CLOUD_RU_check
    [Setup]    Run Keywords    LOGS__CB009077_CLOUD_RU_check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB009077_CLOUD_RU_check
    TC__LOGS__CB009077_CLOUD_RU_check
    [Teardown]    LOGS__CB009077_CLOUD_RU_check.TC Teardown

TC__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct
    [Setup]    Run Keywords    LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct
    TC__LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct
    [Teardown]    LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct.TC Teardown

TC__CB012144-CR-A-RU_POST_data_verify_in_snapshot
    [Setup]    Run Keywords    LOGS__CB012144-CR-A-RU_POST_data_verify_in_snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012144-CR-A-RU_POST_data_verify_in_snapshot
    TC__LOGS__CB012144-CR-A-RU_POST_data_verify_in_snapshot
    [Teardown]    LOGS__CB012144-CR-A-RU_POST_data_verify_in_snapshot.TC Teardown

TC__CB012144-CR-A-RU_POST_data_verify_with_controlled_radio_reset
    [Setup]    Run Keywords    LOGS__CB012144-CR-A-RU_POST_data_verify_with_controlled_radio_reset.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012144-CR-A-RU_POST_data_verify_with_controlled_radio_reset
    TC__LOGS__CB012144-CR-A-RU_POST_data_verify_with_controlled_radio_reset
    [Teardown]    LOGS__CB012144-CR-A-RU_POST_data_verify_with_controlled_radio_reset.TC Teardown

LOGS__CR_CB014065_TC11_NMS_AlarmKeyword_Match_vDU_vCU
    [Setup]    Run Keywords    LOGS__CR_CB014065_TC11_NMS_AlarmKeyword_Match_vDU_vCU.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CR_CB014065_TC11_NMS_AlarmKeyword_Match_vDU_vCU
    TC__LOGS__CR_CB014065_TC11_NMS_AlarmKeyword_Match_vDU_vCU
    [Teardown]    LOGS__CR_CB014065_TC11_NMS_AlarmKeyword_Match_vDU_vCU.TC Teardown

LOGS__CR_CB014065_TC2_NMS_SignatureKeyword_Match_vCU
    [Setup]    Run Keywords    LOGS__CR_CB014065_TC2_NMS_SignatureKeyword_Match_vCU.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CR_CB014065_TC2_NMS_SignatureKeyword_Match_vCU
    ...    AND    Set Library Search Order   LOGS__CR_CB014065_TC2_NMS_SignatureKeyword_Match_vCU
    TC__LOGS__CR_CB014065_TC2_NMS_SignatureKeyword_Match_vCU
    [Teardown]    LOGS__CR_CB014065_TC2_NMS_SignatureKeyword_Match_vCU.TC Teardown
