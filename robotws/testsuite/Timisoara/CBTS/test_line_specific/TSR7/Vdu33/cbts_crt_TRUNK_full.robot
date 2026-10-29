*** Settings ***
Documentation
...  Tests for VDU33 with names from qc

#Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SRAN  CLOUD_5GC_dRNIC_vDU131_O_AEHC  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../../LOGS/test_resources/LOGS__vDU__CB011146_A_CR_WebEM_Remote_Tool_Cloud_BTS_CLI.robot
Resource    ../../../LOGS/test_resources/LOGS__CB009077_CLOUD_RU_check.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downl_and_act_sw.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.robot
Resource    ../../../LOGS/test_resources/LOGS__vDU__CB010411-CR-I1_3_05_CB006796-SR-A_check_rannic_crash_event_log.robot


Suite Teardown    Copy file logs

*** Variables ***
${FHGW_IP33}    10.5.50.151
${FHGW_id33}    33
${dist_name33}    PLMN-PLMN/FHGW-33

*** Test Cases ***
LOGS__vDU__CB010411-CR-I1_3_05_CB006796-SR-A_check_rannic_crash_event_log.robot
    [Setup]    Run Keywords    LOGS__vDU__CB010411-CR-I1_3_05_CB006796-SR-A_check_rannic_crash_event_log.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB010411-CR-I1_3_05_CB006796-SR-A_check_rannic_crash_event_log
    TC__LOGS__vDU__CB010411-CR-I1_3_05_CB006796-SR-A_check_rannic_crash_event_log
    [Teardown]    LOGS__vDU__CB010411-CR-I1_3_05_CB006796-SR-A_check_rannic_crash_event_log.TC Teardown

LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.robot
    [Setup]    Run Keywords    LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller
    TC__LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller
    [Teardown]    LOGS__vDU__CB012250_F_TC01_Verify_tunable_Log_Levels_for_RAN_NIC_SW_Controller.TC Teardown

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

CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downloading_and_activating_a_new_software
    [Setup]    Run Keywords    LOGS__vDU__CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downl_and_act_sw.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downl_and_act_sw
    ...    AND    set test variable    ${FHGW_IP}    ${FHGW_IP33}
    ...    AND    set test variable    ${FHGW_id}    ${FHGW_id33}
    ...    AND    set test variable    ${dist_name}     ${dist_name33}
    TC__LOGS__vDU__CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downl_and_act_sw
    [Teardown]    LOGS__vDU__CB010415-D_08_DC_from_NMS_GUI_for_FHGW_CP8_Free_space_for_downl_and_act_sw.TC Teardown

TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_status_from_vDU
    [Setup]    Run Keywords    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU
    TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_status_from_vDU
    [Teardown]    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.TC Teardown

TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_synchronization_status_from_vDU
    [Setup]    Run Keywords    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU
    TC__CB012250_D_M2M_interface_to_fetch_SmartNIC_synchronization_status_from_vDU
    [Teardown]    LOGS__vDU__CB012250_D_CR_M2M_interface_to_fetch_SmartNIC_status_from_vDU.TC Teardown
