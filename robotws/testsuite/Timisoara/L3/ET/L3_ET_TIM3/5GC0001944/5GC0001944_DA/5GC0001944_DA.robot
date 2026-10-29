*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Anna Roskosz
...              :contact: anna.roskosz@nokia.com

Resource     5GC0001944_DA_Keywords.robot
Library      5GC0001944.py

Suite Setup    Run Keywords    Start Default Logging And Reach Onair    lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
...                        output_dirpath=${OUTPUT_DIR}/suite_setup_logs
...        AND             Set Counter Collecting Interval To Five Minutes
...        AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/suite_setup_logs

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown     Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${RAN_CONFIGURATION_UPDATE_FAILURE_WITH_TIME_TO_WAIT}=
    ...    (((ngap.RANConfigurationUpdateFailure_element)) && (ngap.misc == 5)) && (ngap.TimeToWait == 1)
${RAN_CONFIGURATION_UPDATE}=
    ...    ngap.RANConfigurationUpdate_element
${NG_RESET_ACK_EMPTY_UE_ASSOCIATED_LOGICAL_NG_LIST}=    ((ngap.NGResetAcknowledge_element)&&(ngap.protocolIEs == 0))
${AMF_CONFIGURATION_UPDATE_TNLAssociationToRemoveList}=
   ...    (ngap.AMFConfigurationUpdate_element) && (ngap.AMF_TNLAssociationToRemoveList == 1)
${EMPTY_AMF_CONFIGURATION_UPDATE_ACK}=
    ...    (ngap.AMFConfigurationUpdateAcknowledge_element) && (ngap.protocolIEs == 0)
${NUM_OF_MESSAGES}=    24

*** Test Cases ***
5GC0001944_DA_6_Ng_Partial_Reset_Initiated_By_AMF_With_Valid_And_Invalid_Ue_IDs
    [Documentation]   This is Optimized TC, and covers following legacy scenarios:
    ...               5GC0001944_DA_7_Ng_Partial_Reset_Initiated_By_AMF_Empty_Ue_Associated_Logical_Ng_Connection_Item
    ...               5GC0001944_DA_14_Ng_Partial_Reset_Initiated_By_AMF_With_Invalid_Ue_ID
    ...               Requirement ID : 5G_RAN_USR_8522
    ...               5GC000638_B_10_Ng_Partial_Reset_Amf_Initiated_Fault_Counter_Verification
    ...               Requirement ID : 5G_RAN_USR_4126

    Perform Action And Wait For Given Tshark Message Number And Convert To Pdml
    ...    output_filepath=${OUTPUT_DIR}/UeAssociatedLogicalNGList
    ...    packet_number=4
    ...    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} || ${NGAP_RESET} || ${NGAP_RESET_ACKNOWLEDGE}
    ...    eth_interface=${VM0_ENB_S1_ETH}
    ...    action=Attach UE And Trigger NG Reset With Valid And Invalid UE

    Verify If Invalid And Valid Ue In Ng Reset    pdml_file=${OUTPUT_DIR}/UeAssociatedLogicalNGList
    ${VALID_UE_ID}=    Verify Valid Ue    pdml_file=${OUTPUT_DIR}/UeAssociatedLogicalNGList
    Verify Tcpdump Log       packet_filter=(e1ap.Reset_element) && (e1ap.gNB_CU_CP_UE_E1AP_ID == ${VALID_UE_ID})
    Verify Tcpdump Log       packet_filter=(f1ap.Reset_element) && (f1ap.gNB_CU_UE_F1AP_ID == ${VALID_UE_ID})
    Verify Tcpdump Log       packet_filter=${F1AP_RESET_ACKNOWLEDGE}    number_of_messages=2
    Verify Tcpdump Log       packet_filter=${E1AP_RESET_ACKNOWLEDGE}    number_of_messages=2
    Verify If Ue Ids The Same In Ng Reset And Ng Reset Ack    pdml_file=${OUTPUT_DIR}/UeAssociatedLogicalNGList
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C00012     +1    NG_CU_RESET_REQ_RCV
    ...    M55119C00013     +1    NG_CU_RESET_ACK_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

5GC0001944_DA_11_AMF_Configuration_Update_Unsupported_IE_AMF_TNLAssociationToRemoveList
    [Documentation]   This is Optimized TC, and covers following legacy scenarios:
    ...               5GC0001944_DA_12_AMF_Configuration_Update_Unsupported_IE_AMF_TNLAssociationToAddList
    ...               5GC0001944_DA_13_AMF_Configuration_Update_Unsupported_IE_AMF_TNLAssociationToUpdateList
    ...               Requirement ID  : 5G_RAN_USR_8522

    Perform Action And Wait For Given Tshark Message Number
        ...    packet_filter=${AMF_CONFIGURATION_UPDATE_TNLAssociationToRemoveList}
        ...    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
        ...    action=Send AMF Configuration Update With AMF TNLAssociationToRemoveList
    Verify Ngap Messages    packet_filter=${EMPTY_AMF_CONFIGURATION_UPDATE_ACK}

5GC0001944_DA_2_RAN_Configuration_Update_Failure_Handling_With_Retries_With_Time_To_Wait
    [Documentation]   This is Optimized TC, and covers following legacy scenarios:
    ...               5GC0001944_DA_1_RAN_Configuration_Update_Failure_Handling_Without_Retries
    ...               5GC0001944_DA_3_RAN_Configuration_Update_Failure_Handling_With_Retries_Without_Time_To_Wait
    ...               5GC0001944_DA_4_Raising_Fault_NGRANConfigUpdateFailureAI
    ...               Requirement ID  : 5G_RAN_USR_8522

    Wait For Next Full Pm Interval
    Send RAN Configuration Update Failure With Retries And Time To Wait
    Lock All Cells
    Unlock Single Cell    cell_id=1    timeout=50
    Unlock Single Cell    cell_id=2    timeout=50
    Unlock Single Cell    cell_id=3    timeout=50
    Unlock Single Cell    cell_id=4    timeout=50
    Sleep    102s    Collect proper tshark messages

    Verify Ngap Messages    packet_filter=${RAN_CONFIGURATION_UPDATE}    number_of_messages=${NUM_OF_MESSAGES}
    Verify Ngap Messages    packet_filter=${RAN_CONFIGURATION_UPDATE_FAILURE_WITH_TIME_TO_WAIT}    number_of_messages=${NUM_OF_MESSAGES}

    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55119C00023     >0   NG_CU_RAN_CONFIG_UPD_FAILURE_RCV
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${PM_COUNTERS}

