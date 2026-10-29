*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny
...              :contact: marcin.plawny@nokia.com

Resource    CB010751_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_10751_no_ransharing.json    skip_relation_errors=False
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa_redcap.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                               delta_scf_filename=delta_10751_no_ransharing.json

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Run Keywords    Deregister UE Without Confirmation    ue_id=all
...              AND             Add Scout Scf Id To Test Data
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...              AND             Run Keyword If Test Passed    Find Suspicious Logs

*** Test Cases ***
CB010751_C_EC1_1_Unsuccessful_transition_of_RedCap_UE_In_RRC_CONNECTED_State_To_RRC_INACTIVE_State_When_CNAI_Is_Absent_In_ICS
    [Documentation]    This user scenario describes the gNB behavior for UE in RRC_CONNECTED state when Core Network Assistance Information
    ...                is missing in Initial Context Setup in RRC_CONNECTED state. Unsuccessful suspend procedure. UE released
    ...                to RRC_IDLE state.
    ...                5G_RAN_USR_RRM_24516

    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1    gw_id=1    pass_regexp=UE1: IS IDLE    timeout=19
    Verify Traces For RRCRelease After Unsuccessful Transition To RRC INACTIVE

CB010751_C_EC2_Unsuccessful_Transition_Of_RedCap_UE_Being_In_RRC_INACTIVE_State_To_RRC_CONNECTED_Due_To_Radio_Admission_Control_Failure_CB008225_D_E2
    [Documentation]    This testcase describes the gNB behavior for RedCap UE in RRC_CONNECTED state that is unsuccessfully transitioned
    ...                to RRC_INACTIVE state due to Admission Control in gNB-CU-CP (CB008225-D#E2 Alt 1) when actRedCapUe Support is false.
    ...                5G_RAN_USR_RRM_24515

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=2
    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2    gw_id=2    pass_regexp=UE2: Is INACTIVE    timeout=19
    Perform Parameter Commissioning    parameter=actRedCapUeSupport    value=false    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mt_Access
    Modify PDU Session    ue_id=2    pdu_id=1    qos_to_add=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_REQUEST_1}
    Verify Tcpdump Log    packet_filter=${RRC_REJECT}
    Perform Parameter Commissioning    parameter=actRedCapUeSupport    value=true    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    Deregister UE    ue_id=2

CB010751_C_B1_Unsuccessful_Transition_Of_RedCap_UE_Being_In_RRC_CONN_State_To_RRC_INACTIVE_State_UE_Has_No_RRC_Inactive_Capability
    [Documentation]    This test case tests the gNB behavior for RedCap UE in RRC_CONNECTED state that is unsuccessfully
    ...                transitioned to RRC_INACTIVE state due to UE has no rrcInactiveSupport capability. Unsuccessful
    ...                suspend procedure. UE released to RRC_IDLE state
    ...                5G_RAN_USR_RRM_24509

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=21
    Attach UE    ue_id=21
    Establish PDU Session    ue_id=21    gw_id=3    pass_regexp=UE21: IS IDLE    timeout=27
    Verify Traces For RRCRelease After Unsuccessful Transition To RRC INACTIVE
    Deregister UE    ue_id=21

CB010751_C_IWK2_Unsuccessful_Transition_Of_RedCapa_UE_From_RRC_CONNECTED_To_RRC_INACTIVE_With_Additional_Slice_Support_UE_No_RRC_Inactive_Capabilities
    [Documentation]    This test case tests the gNB behavior for RedCap UE in RRC_CONNECTED state that is unsuccessfully
    ...                transitioned to RRC_INACTIVE state due to UE has no rrcInactiveSupport capability. Unsuccessful
    ...                suspend procedure. UE released to RRC_IDLE state
    ...                5G_RAN_USR_RRM_24509

    [Setup]    Run Keywords    Find Scfc And Send Delta Commissioning    scfc_filename=SNSSAI_inactivity_timers.json    skip_relation_errors=False
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=22
    Attach UE    ue_id=22
    Establish PDU Session    ue_id=22    gw_id=4    pass_regexp=UE22: IS IDLE    timeout=19
    Verify Traces For RRCRelease After Unsuccessful Transition To RRC INACTIVE
    Deregister UE    ue_id=22

    [Teardown]    Run Keywords    Find Scfc And Send Delta Commissioning
    ...                           scfc_filename=SNSSAI_inactivity_timers_off.json    skip_relation_errors=False
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs
