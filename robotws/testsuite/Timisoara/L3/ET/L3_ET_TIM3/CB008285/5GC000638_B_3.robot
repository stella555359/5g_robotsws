*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO  VARIANT_SA_FS_ECPRI_MMWV_TDD    PY36    CONFIGURED    RAN_5G_TDD    CRT    RAN_5G    SBTS00
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Kamila Bialczyk, Paweł Cebula, Michal Fluder, Anna Roskosz
...              :contact: kamila.bialczyk@nokia.com, pawel.1.cebula@nokia.com, michal.fluder@nokia.com, anna.roskosz@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../5GC000638/5GC000638_R/5GC000638_R_Keywords.robot
Library      ta5g_cell_operations

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND             Reset Testline
...            AND             Check Radios Availability
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Reach Onair    lua_cfg=${CURDIR}/../resources/egate_2c_tdd_sansa_FR2_n257.lua
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
5GC000638_B_NG_Full_Reset_gNB_Initiated_counters_test_case_3
    [Documentation]    This test case describes NG Full Reset initiated by gNB
    ...                5G_RAN_USR_RRM_1229
    ...                Test case checks:
    ...                - if counters NG_CU_RESET_ACK_RCV and NG_CU_RESET_REQ_SENT are incremented properly
    ...                author:    Kamila Bialczyk
    ...                contact:   kamila.bialczyk@nokia.com

    Attach Ue    ue_id=4
    Establish Pdu Session    ue_id=4    pdu_id=4    gw_id=4
    Perform Action And Wait For Given Tshark Message Number
        ...    packet_filter=${NGAP_RESET}
        ...    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
        ...    action=Invoke NG Full Reset By Breaking Sctp On F1 Interface
        ...    waiting_timeout=300
    Verify Ngap Messages       packet_filter=${NGAP_RESET_ACKNOWLEDGE}
    Verify Ngap Messages       packet_filter=${NG_FULL_RESET}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55119C00011    +1    NG_CU_RESET_REQ_SENT
        ...    M55119C00014    +1    NG_CU_RESET_ACK_RCV
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
        ...    file_path=${pm_counter_file}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=4
    ...           AND             Restore Sctp On F1 Interface
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Keywords ***
Change Amf Name
    ${new_amf_name} =    Generate Random String    50    [NUMBERS][LETTERS]()+,-.?:/=
    Set Suite Variable    ${new_amf_name}
    Execute Egate Command    cmd=amf_config_update id=1 name=${new_amf_name}
