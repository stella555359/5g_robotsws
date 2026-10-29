*** Settings ***
#Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    PY36    CONFIGURED    RAN_5G_TDD    CRT    RAN_5G    SBTS00    SBTS22R4
#...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: TIM3
...              :contact: TIM3

Resource     ../resources/5G_SW_WRO_Keywords.robot
#Resource     ../5GC000638_R/5GC000638_R_Keywords.robot
Library      ta5g_cell_operations

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Reach Onair    lua_cfg=${CURDIR}/../resources/egate_2c_tdd_sansa.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/

Test Setup        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${NG_FULL_RESET}=    ${NGAP_RESET} && ngap.nG_Interface == 0
${NG_AMF_INIT_FULL_RESET}=    7314
${BASE_STATION_INFORMATION}=    7115
${ICS_UE_ID_0}=    ${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ngap.RAN_UE_NGAP_ID == 0
${NG_PARTIAL_RESET_UE_ID_0}=    ${NGAP_RESET} && ngap.ResetType == 1  && ngap.RAN_UE_NGAP_ID == 0
${NG_PARTIAL_RESET_ACK_UE_ID_0}=    ${NGAP_RESET_ACKNOWLEDGE} && ngap.RAN_UE_NGAP_ID == 0
${F1_PARTIAL_RESET_UE_ID_0}=    ${F1AP_RESET} && f1ap.partOfF1_Interface == 1 && f1ap.gNB_CU_UE_F1AP_ID == 0
${F1_RESET_ACK_UE_ID_0}=    ${F1AP_RESET_ACKNOWLEDGE} && f1ap.gNB_CU_UE_F1AP_ID == 0
${E1_PARTIAL_RESET_UE_ID_0}=    ${E1AP_RESET} && e1ap.partOfE1_Interface == 1 && e1ap.gNB_CU_CP_UE_E1AP_ID == 0
${E1_RESET_ACK_UE_ID_0}=    ${E1AP_RESET_ACKNOWLEDGE} && e1ap.gNB_CU_CP_UE_E1AP_ID == 0

*** Test Cases ***
TL_SETUP
    Log to console   Enabling L3 in TIM3
