*** Settings ***
Documentation
...  Tests for VDU138 with names from qc

#Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_5GC_dRNIC_vDU131_O_AEHC  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../../LOGS/test_resources/LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI.robot
Resource    ../../../LOGS/test_resources/LOGS__CB009077_CLOUD_RU_check.robot
#Resource    ../../../LOGS/test_resources/LOGS__vDU__CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downl_and_act_sw.robot
#Resource    ../../../LOGS/test_resources/LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision.robot
#Resource    ../../../LOGS/test_resources/LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.robot
Resource    ../../../LOGS/test_resources/LOGS__CB013203_vCU_snapshot_with_SDL.robot
Resource    ../../../LOGS/test_resources/LOGS__CB006483_5G_C_Add_modify_remove_the_triggers_Remote_Tool.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct.robot

#Suite Setup       Suite Precondition     True  ## "True" will perform Software update on vDU with last regresion promoted sw
Suite Teardown    Copy file logs

*** Variables ***
${FHGW_IP138}    10.15.198.44    #FHGW-138
${FHGW_id138}    138
${dist_name138}    PLMN-PLMN/FHGW-138
#${netact}    ${NETACT2003}
*** Test Cases ***
CB011146_D_CR_ROBUSTNESS_BTS_Read_Only_User_Operations_Check
    [Setup]    Run Keywords    LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check
    ...    AND    Set Library Search Order    LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check
    TC__LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check
    [Teardown]        LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check.TC Teardown

CB011146_D_CR_Rest_API_get_CellStatus
    [Setup]    Run Keywords    LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus
    ...    AND    Set Library Search Order    LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus
    TC__LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus
    [Teardown]    LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus.TC Teardown

CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI
    [Setup]    Run Keywords    LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI
    ...    AND    Set Library Search Order    LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI
    TC__LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI
    [Teardown]    LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI.TC Teardown


#CB010415-B_03_CP18_radio_module_temperature_supervision
#    [Setup]    Run Keywords    LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision.TC Setup
#    ...    AND    Modify Resource Search Order    LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision
#    ...    AND    Set Library Search Order    LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision
#    TC__LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision
#    [Teardown]    LOGS__vDU__CB010415-B_03_CP18_radio_module_temperature_supervision.TC Teardown
#
#CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor
#    [Setup]    Run Keywords    LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor.TC Setup
#    ...    AND    Modify Resource Search Order    LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor
#    ...    AND    Set Library Search Order    LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor
#    TC__LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor
#    [Teardown]    LOGS__vDU__CB010415-C_03_Full_DC_triggered_from_NMS_GUI_for_CP42_RU_Temperature_sensor.TC Teardown
#
Automated__LOGS__CB009077_CLOUD_RU_check
    [Setup]    Run Keywords    LOGS__CB009077_CLOUD_RU_check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB009077_CLOUD_RU_check
    ...    AND    Set Library Search Order    LOGS__CB009077_CLOUD_RU_check
    TC__LOGS__CB009077_CLOUD_RU_check
    [Teardown]     LOGS__CB009077_CLOUD_RU_check.TC Teardown

LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.robot
    [Setup]    Run Keywords    LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller
    ...    AND    Set Library Search Order    LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller
    TC__LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller
    [Teardown]    LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.TC Teardown

TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_status_from_vDU
    [Setup]    Run Keywords    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU
    ...    AND    Set Library Search Order    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU
    TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_status_from_vDU
    [Teardown]    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.TC Teardown

TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_synchronization_status_from_vDU
    [Setup]    Run Keywords    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU
    ...    AND    Set Library Search Order      LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU
    TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_synchronization_status_from_vDU
    [Teardown]     LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.TC Teardown

CB013203_A_Download_SDL_data_snapshot_for_both_namespaces_and_key-prefixes_via_WebEM_vCU_MNO_OCP_cluster
    [Setup]    Run Keywords    LOGS__CB013203_vCU_snapshot_with_SDL.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB013203_vCU_snapshot_with_SDL
    ...    AND    Set Library Search Order      LOGS__CB013203_vCU_snapshot_with_SDL
    TC__LOGS__CB013203_vCU_snapshot_with_SDL
    [Teardown]    LOGS__CB013203_vCU_snapshot_with_SDL.TC Teardown

CB006483_5G_C_Add_modify_remove_the_triggers_Remote_Tool
    [Setup]    Run Keywords    LOGS__CB006483_5G_C_Add_modify_remove_the_triggers_Remote_Tool.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB006483_5G_C_Add_modify_remove_the_triggers_Remote_Tool
    ...    AND    Set Library Search Order    LOGS__CB006483_5G_C_Add_modify_remove_the_triggers_Remote_Tool
    TC_CB006483_5G_C_Add_modify_remove_the_triggers_Remote_Tool
    [Teardown]        LOGS__CB006483_5G_C_Add_modify_remove_the_triggers_Remote_Tool.TC Teardown

CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct
    [Setup]    Run Keywords    LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct
    TC__LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct
    [Teardown]    LOGS__vDU__CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct.TC Teardown

#CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downloading_and_activating_a_new_software
#    [Setup]    Run Keywords    LOGS__vDU__CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downl_and_act_sw.TC Setup
#    ...    AND    Modify Resource Search Order    LOGS__vDU__CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downl_and_act_sw
#    ...    AND    set test variable    ${FHGW_IP}    ${FHGW_IP138}
#    ...    AND    set test variable    ${FHGW_id}    ${FHGW_id138}
#    ...    AND    set test variable    ${dist_name}     ${dist_name138}
#    ...    AND    set test variable    ${netact}    ${netact}
#    TC__LOGS__vDU__CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downl_and_act_sw
#    [Teardown]    LOGS__vDU__CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downl_and_act_sw.TC Teardown