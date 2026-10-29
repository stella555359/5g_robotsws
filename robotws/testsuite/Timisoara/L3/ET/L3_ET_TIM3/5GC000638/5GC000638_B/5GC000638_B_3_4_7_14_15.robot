*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    PY36    CONFIGURED    RAN_5G_TDD    CRT    RAN_5G    SBTS00    SBTS23R1
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Kamila Bialczyk, Paweł Cebula, Michal Fluder, Anna Roskosz
...              :contact: kamila.bialczyk@nokia.com, pawel.1.cebula@nokia.com, michal.fluder@nokia.com, anna.roskosz@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     ../5GC000638_R/5GC000638_R_Keywords.robot
Library      ta5g_cell_operations

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/suite_setup_logs/
...            AND             Set Counter Collecting Interval To Five Minutes
...            AND             Reach Onair    lua_cfg=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
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
5GC000638_B_4_NG_Partial_Reset_gNB_Initiated
    [Documentation]    This test case describes NG Partial Reset initiated by gNB
    ...                5G_RAN_USR_RRM_1230
    ...                Test case checks:
    ...                - if counters NG_CU_RESET_REQ_SENT and NG_CU_RESET_ACK_RCV are incremented properly
    ...                author:    Anna Roskosz, Michal Fluder
    ...                contact:   anna.roskosz@nokia.com, michal.fluder@nokia.com

    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Change Ue Location   ue_id=2    dst_enb=2    dst_cell=2
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=2
    Lock Single Cell    cell_id=1   timeout=60
    Verify Ngap Messages    packet_filter=${ICS_UE_ID_0}
    Verify Ngap Messages    packet_filter=${NG_PARTIAL_RESET_UE_ID_0}
    Verify Ngap Messages    packet_filter=${NG_PARTIAL_RESET_ACK_UE_ID_0}
    Verify Tcpdump Log       packet_filter=${F1_PARTIAL_RESET_UE_ID_0}
    Verify Tcpdump Log       packet_filter=${F1_RESET_ACK_UE_ID_0}
    Verify Tcpdump Log       packet_filter=${E1_PARTIAL_RESET_UE_ID_0}
    Verify Tcpdump Log       packet_filter=${E1_RESET_ACK_UE_ID_0}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C00011     +1    NG_CU_RESET_REQ_SENT
    ...    M55119C00014     +1    NG_CU_RESET_ACK_RCV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

    [Teardown]    Run Keywords     Deregister Ue Without Confirmation    ue_id=1-2
    ...           AND              Unlock Single Cell    cell_id=1    timeout=60
    ...           AND              Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000638_B_NG_Full_Reset_AMF_Initiated_test_case_7
    [Documentation]    This test case describes NG Full Reset initiated by AMF
    ...                5G_RAN_USR_RRM_1231
    ...                Test case checks:
    ...                - if counters NG_CU_RESET_REQ_RCV and NG_CU_RESET_ACK_SENT are incremented properly
    ...                author:    Anna Roskosz, Paweł Cebula
    ...                contact:   anna.roskosz@nokia.com, pawel.1.cebula@nokia.com

    Attach Ue    ue_id=3
    Attach Ue    ue_id=4
    Establish Pdu Session    ue_id=3    pdu_id=3    gw_id=3
    Establish Pdu Session    ue_id=4    pdu_id=4    gw_id=4
    Invoke Ng Full Reset By Amf    by=amf:1
    Verify Ngap Messages    packet_filter=${NG_FULL_RESET}
    Verify Ngap Messages    packet_filter=${NGAP_RESET_ACKNOWLEDGE}
    Verify Tcpdump Log       packet_filter=${E1AP_RESET}    number_of_messages=2
    Verify Tcpdump Log       packet_filter=${E1AP_RESET_ACKNOWLEDGE}    number_of_messages=2
    Verify Tcpdump Log       packet_filter=${F1AP_RESET}    number_of_messages=2
    Verify Tcpdump Log       packet_filter=${F1AP_RESET_ACKNOWLEDGE}    number_of_messages=2
    Wait For Fault To Be Up    fault_id=${NG_AMF_INIT_FULL_RESET}
    Wait For Alarm To Be Up    alarm_id=${BASE_STATION_INFORMATION}
    Check Admin Object Parameter Value    moc=SERVEDAMF_R    parameter_name=ngLinkStatus    value=Active
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C00012     +1    NG_CU_RESET_REQ_RCV
    ...    M55119C00013     +1    NG_CU_RESET_ACK_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

    [Teardown]    Run Keywords     Deregister Ue Without Confirmation    ue_id=3-4
    ...           AND              Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000638_B_14_Amf_Configuration_Update_Success_Counters
    [Documentation]    This test case describes AMF Configuration Update procedure
    ...                5G_RAN_USR_RRM_1233
    ...                Test case checks:
    ...                - if counters NG_CU_AMF_CONFIG_UPD_RCV and NG_CU_AMF_CONFIG_ACK_SENT are incremented properly
    ...                author:    Kamila Bialczyk
    ...                contact:   kamila.bialczyk@nokia.com

    Change Amf Name
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C00017     +1    NG_CU_AMF_CONFIG_UPD_RCV
    ...    M55119C00018     +1    NG_CU_AMF_CONFIG_ACK_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

    [Teardown]    Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

5GC000638_B_15_Ran_Configuration_Update_Success
    [Documentation]    This test case describes Ran Configuration Update procedure
    ...                5G_RAN_USR_RRM_1234; 5G_RAN_USR_RRM_1243
    ...                Test case checks:
    ...                - if counters NG_CU_RAN_CONFIG_UPD_SENT and NG_CU_RAN_CONFIG_ACK_RCV are incremented properly
    ...                author:    Kamila Bialczyk
    ...                contact:   kamila.bialczyk@nokia.com

    Lock Single Cell    cell_id=1   timeout=60
    Lock Single Cell    cell_id=2   timeout=60
    Lock Single Cell    cell_id=3   timeout=60
    Lock Single Cell    cell_id=4   timeout=60
    Unlock Single Cell    cell_id=1    timeout=60
    Verify Ngap Messages       packet_filter=${NGAP_RAN_CONFIGURATION_UPDATE}
    Verify Ngap Messages       packet_filter=${NGAP_RAN_CONFIGURATION_UPDATE_ACKNOWLEDGE}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C00015     +1    NG_CU_RAN_CONFIG_UPD_SENT
    ...    M55119C00016     +1    NG_CU_RAN_CONFIG_ACK_RCV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

    [Teardown]    Run Keywords     Unlock Single Cell    cell_id=2    timeout=60
    ...           AND              Unlock Single Cell    cell_id=3    timeout=60
    ...           AND              Unlock Single Cell    cell_id=4    timeout=60
    ...           AND              Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

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
        ...    waiting_timeout=600
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
