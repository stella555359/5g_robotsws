*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Tomasz Niedzwiedzki, Marcin Plawny, Marcin Szulc, Sebastian Maslak
...              :contact: tomasz.niedzwiedzki@nokia.com, marcin.plawny@nokia.com, marcin.szulc@nokia.com
...              :maintainer: marcin.plawny@nokia.com

Resource    CB008225_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_8225_cell2_no_ranac.json    skip_relation_errors=False
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_ran_sharing.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                               delta_scf_filename=delta_8225_cell2_no_ranac.json

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Deregister UE Without Confirmation    ue_id=all
...              AND             Add Scout Scf Id To Test Data
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...              AND             Run Keyword If Test Passed    Find Suspicious Logs

*** Test Cases ***
CB008225_A_B1_CB008225_Feature_Activation_NR_Cell_Configuration_Of_RAN_Area_Code_And_Broadcast_Of_SIB1_For_RRC_Inactive_State
    [Documentation]    This user scenario describes feature activation and the gNB configuration for RAN Sharing
    ...                and for support UEs in RRC_INACTIVE state. Configuration of RAN Area Code and broadcast of SIB1
    ...                with ranac IE and useFullResumeID IE. TC included CB008225_A_B3_CB008225_Feature_Deactivation
    ...                5G_RAN_USR_RRM_18000, 5G_RAN_USR_RRM_18446

    Find Scfc And Send Delta Commissioning    scfc_filename=rrcinact_off.json    skip_relation_errors=False
    Verify Tcpdump Log    packet_filter=${OFF_RANAC_USEFULLRESUMEID_CELL1}    relation_symbol=>=
    Verify Tcpdump Log    packet_filter=${GNB_DU_CONFIGURATION_UPDATE_FOR_CELL2}    number_of_messages=0

    Find Scfc And Send Delta Commissioning    scfc_filename=rrcinact_on.json    skip_relation_errors=False
    Verify Tcpdump Log    packet_filter=${RANAC_USEFULLRESUMEID_CELL1}    relation_symbol=>=
    Verify Tcpdump Log    packet_filter=${GNB_DU_CONFIGURATION_UPDATE_FOR_CELL2}    number_of_messages=0

    [Teardown]    Run Keywords    Find Scfc And Send Delta Commissioning    scfc_filename=rrcinact_on.json    skip_relation_errors=False
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

CB008225_B_EC1_Unsuccess_Trans_RRC_CONNECTED_UE_To_RRC_INACTIVE_Release_UE_RRC_IDLE_No_CoreNetworkAssistanceInformationForInactive
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is unsuccessfully
    ...                transitioned to RRC_INACTIVE state due to missing CoreNetworkAssistanceInformationForInactive.
    ...                Unsuccessful suspend procedure. UE released to RRC_IDLE state
    ...                5G_RAN_USR_RRM_18723

    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1    gw_id=1
    Wait For Release RRC Inactive Conditions Not Met
    Verify Traces For RRCRelease After Unsuccessful Transition To RRC INACTIVE

CB008225_B_EC1_Unsuccess_Trans_RRC_CONNECTED_UE_To_RRC_INACTIVE_Release_UE_RRC_IDLE_No_RrcInactiveSupport
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is unsuccessfully
    ...                transitioned to RRC_INACTIVE state due to UE has no rrcInactiveSupport capability. Unsuccessful
    ...                suspend procedure. UE released to RRC_IDLE state
    ...                5G_RAN_USR_RRM_18723

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=22
    Attach UE    ue_id=22
    Establish PDU Session    ue_id=22    pdu_id=2    gw_id=22
    Wait For Release RRC Inactive Conditions Not Met
    Verify Traces For RRCRelease After Unsuccessful Transition To RRC INACTIVE

CB008225_B_EC1_Unsuccess_Trans_RRC_CONNECTED_UE_To_RRC_INACTIVE_Release_UE_RRC_IDLE_PLMN_Without_Ranac
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is unsuccessfully
    ...                transitioned to RRC_INACTIVE due to no ranAC for given PLMN. Unsuccessful suspend procedure.
    ...                UE released to RRC_IDLE state
    ...                5G_RAN_USR_RRM_18723

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=9
    ...                                                                               amf_id=3    plmn_id=311:495    tac_id=258
    Attach UE    ue_id=9
    Establish PDU Session    ue_id=9    pdu_id=1    gw_id=9
    Wait For Release RRC Inactive Conditions Not Met
    Verify Traces For RRCRelease After Unsuccessful Transition To RRC INACTIVE

CB008225_B_EC1_Unsuccess_Trans_RRC_CONNECTED_UE_To_RRC_INACTIVE__Release_UE_RRC_IDLE_VoNR
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is unsuccessfully
    ...                transitioned to RRC_INACTIVE state due to having 5QI1 DRB. Unsuccessful suspend procedure.
    ...                UE released to RRC_IDLE state
    ...                5G_RAN_USR_RRM_18723

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=2
    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=2    gw_id=2
    Modify PDU Session    ue_id=2    pdu_id=2    qos_to_add=3
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For RRCRelease After Unsuccessful Transition To RRC INACTIVE

CB008225_C_E2_Failure_RAN_Paging_For_RRC_INACTIVE_UE_TRanPagingGuard_Expired_AMF_Signaling_With_NAS_PDU
    [Documentation]    This TC scenario describes RAN Paging for the UEs in RRC_INACTIVE state for DL AMF signalling arrival.
    ...                NAS PDU(s) (not related to PDU Session) are in the gNB buffers. Failure scenario.
    ...                5G_RAN_USR_RRM_18113, 5G_PM_961

    Set SIM TTI
    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=3
    Attach UE    ue_id=3
    Establish PDU Session    ue_id=3    gw_id=3
    Set AMF Delay For PDU Setup With NAS PDU
    Set UE To Ignore Paging
    Wait For Release RRC Inactive Conditions Met
    Establish PDU Session    ue_id=3    pdu_id=2    gw_id=4    pass_regexp=Establishment Request with PDU Session ID 2 handled successfully at SMF:1.
    Wait For AMF PDU Setup Timer Delay Expired
    Verify Traces For UE Release After TRanPagingGuard Expired

CB008225_M_B2_Verify_Interaction_With_CB008281_Success_8225_CB2
    [Documentation]    This user scenario describes RAN Paging for the UEs in RRC_INACTIVE state
     ...               for DL AMF signalling (carrying NGAP: DownlinkUEAssociatedNRPPaTransport
     ...               carrying NRPPa PDU) arrival. Successful scenario.
     ...               5G_RAN_USR_RRM_20957, CB_FIM_43890

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=4
    Attach UE    ue_id=4
    Establish PDU Session    ue_id=4    gw_id=4
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE
    Set AMF1 To Receive Downlink UE1 NRPPA Transport PDU Signal Message
    Verify Traces For E-CID Measurement Request From NRPPA PDU
    Verify Traces For Successful Transition to RRC CONNECTED By MT Access

*** Variables ***
${SET_LMF_NRPPA}=    lmf_send_ecid_meas_req id=1 ue=4 nrppa_transaction_id=1
...                  lmf_ue_measurement_id=1 report_characteristics=OnDemand meas_qty=SS-RSRP,SS-RSRQ

*** Keywords ***
Set SIM TTI
    Execute Egate Command    cmd=sim_param_set TTI=2

Set AMF Delay For PDU Setup With NAS PDU
    Execute Egate Command    cmd=amf_ue_pdu_setup_param id=1 ue=3 pdu=2 action=delay time_to_wait=2m outer_NAS_PDU_type=configuration_update_command

Set UE To Ignore Paging
    Execute Egate Command    cmd=ue_param id=3 ignore_paging=on

Wait For AMF PDU Setup Timer Delay Expired
    Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}    timeout=150

Set AMF1 To Receive Downlink UE1 NRPPA Transport PDU Signal Message
    Execute Egate Command    cmd=${SET_LMF_NRPPA}
    Sleep    10s    reason=Wait For Procedure Is Finished

Verify Traces For E-CID Measurement Request from NRPPA PDU
   Verify Tcpdump Log    packet_filter=${NGAP_DOWNLINK_UE_ASSOCIATED_NRPPA_TRNASPORT}

Verify Traces For UE Release After TRanPagingGuard Expired
    Verify Tcpdump Log    packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE_UNSUCCESSFUL_TRANSFER_CAUSE_UE_INACTIVE}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
