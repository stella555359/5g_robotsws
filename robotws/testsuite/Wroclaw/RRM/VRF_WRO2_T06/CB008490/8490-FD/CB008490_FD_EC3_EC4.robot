*** Settings ***
Force Tags    CONFIGURED   CRT    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    ../resources/feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/traffic.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Library     ta5g_file_system
Library     ../resources/KeywordsCB008490.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Setup    Run Keywords
...            Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND     Enable C-Plane Debug Logs       with_reboot=${false}
...    AND     Start Vm Ethernet Interfaces For Simulated gNB

Suite Teardown    Compress Test Logs

Test Setup     Run Keywords    Run Keyword If    "${TEST_NAME}" == "${tc1_name}"
...            Update And Put Iphy Xml    input_filepath=${IPHY_TC1}
...    ELSE    Update And Put Iphy Xml    input_filepath=${IPHY_TC2}
...    AND     Run Keyword If    "${TEST_NAME}" == "${tc1_name}"
...            Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC_TC1}
...    ELSE    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC_TC2}
...    AND     Reset Wts
...    AND     Check Radios Availability
...    AND     Run Keyword If    "${TEST_NAME}" == "${tc1_name}"
...            Reach Onair    lua_cfg=${CFG_TC1}
...    ELSE    Reach Onair    lua_cfg=${CFG_TC2}
...    AND     Run Keyword If    "${TEST_NAME}" == "${tc1_name}"
...            Setup devices aliases    ELSE    Setup devices aliases for realMN simSN
...    AND     Prepare Sim gNB
...    AND     Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND     Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


Test Teardown      Run Keywords
...                Deregister UE    ue_id=all
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Find Errors
...    AND         Add Scout Scf Id To Test Data
...    AND         Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...    AND         Collect Selected Debug Files
...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...                omit_collectors=sos_report

*** Variables ***
${SCFC_TC1}=          scfc_AWEUB_n257A_realSN.xml
${IPHY_TC1}=          ${CURDIR}/config/iphy_AWEUB_realSN.xml
${CFG_TC1}=           ${CURDIR}/config/cfg_8490-FD_realSN.cfg
${SCFC_TC2}=          scfc_AEQE_n78A_realmMN.xml
${IPHY_TC2}=          ${CURDIR}/config/iphy_MN_AEQE.xml
${CFG_TC2}=           ${CURDIR}/config/cfg_realMN_n78A_simSN_n257A.cfg
@{FAULT_IDS_LIST}=    6450    4383
${amf_id}=            1
${tc1_name}=          CB008490_FD_EC8_ALT1_Unexpected_error_related_to_UE_AP_IDs_in_the_XNAP_XnUAddressIndication_message_Inter-gNB_NR-DC

*** Test Cases ***
CB008490_FD_EC8_ALT1_Unexpected_error_related_to_UE_AP_IDs_in_the_XNAP_XnUAddressIndication_message_Inter-gNB_NR-DC
    Attach Ue    ue_id=1    enb=3    cell=9
    Establish Pdu Session    check_timestamps=${False}
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE1 GNB2
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB    ue_id=1
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE1 GNB2
    Attach Ue    ue_id=2    enb=3    cell=9
    Establish Pdu Session    ue_id=2    gw_id=2    check_timestamps=${False}
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE2 GNB2
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB    ue_id=2
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE2 GNB2
    Attach Ue    ue_id=3    enb=3    cell=9
    Establish Pdu Session    ue_id=3    gw_id=3    check_timestamps=${False}
    Set Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition On SN Side For UE3 GNB2
    Change XNAP:XnUAddressIndication
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB    ue_id=3
    Verify Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition On SN Side For UE3 GNB2
    Verify Message Contents Of Unsuccessfull PSCell Addition

CB008490-FD_EC9_ALT4_Unexpected_error_related_to_another_UE_S-NG-RANnodeUEXnAPID_in_the_XNAP_ActivityNotification_message_Inter-gNB_NR-DC
    Attach Ue    ue_id=1    enb=2    cell=1
    Set Internal Traffic Type To UE    ue_id=1   pdu_id=1
    Set Scg UL Dist Percent
    Establish Pdu Session
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE1 GNB2
    Send Ue Measurement Nr    ue_id=1    meas_id=2    phycell_id=52    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE1 GNB2
    Get Values From APIDs In SNnodeAddPrep
    Set Suite Variable    ${ue1-M-NG-RANnodeUEXnAPID}    ${id-M-NG-RANnodeUEXnAPID}
    Set Suite Variable    ${ue1-S-NG-RANnodeUEXnAPID}    ${id-S-NG-RANnodeUEXnAPID}
    Set ICS Flow
    Attach Ue    ue_id=2    enb=2    cell=1
    Establish Pdu Session    ue_id=2    gw_id=2
    Verify ICS Flow
    Attach Ue    ue_id=3    enb=2    cell=1
    Establish Pdu Session    ue_id=3    gw_id=3
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE3 GNB2
    Send Ue Measurement Nr    ue_id=3    meas_id=2    phycell_id=52    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE3 GNB2
    Get Values From APIDs In SNnodeAddPrep
    Send Data Traffic
    Verify That Throughput Is Reached On Cell Group    ue_id=1    expected_throughput=0.01
                                       ...    direction=dl    cell_group=MCG    selection_type=average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=1   expected_throughput=10      cell_index_min=0    cell_index_max=0
                                       ...    direction=ul    cell_group=MCG    selection_type=average    margin=10%
    Stop Data Traffic
    Wait 30s For Inactivity
    Set Expected Message Flow For SNode Release After Error In ActivityNotification Message
    Send Incorrect Xn ActivityNotification
    Verify Expected Message Flow For SNode Release After Error In ActivityNotification Message
    Verify Message Contents For SNode Release After Incorrect APID In ActivityNotification Message

*** Keywords ***
Set Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition On SN Side For UE3 GNB2
    Set expected message flow    sNnodeAddPrep=1    xnUAddressInd=1    XNAPerrorInd=1    sNnodeReleaseRequired=1    XNAPuECtxRelease=1
        ...    uECtxMod=1    bearerCtxMod=1    F1APuECtxRelease=1    bearerCtxRelease=1

Verify Expected Message Flow For A4 Meas Based Unsuccesfull Inter-gNB PSCell Addition On SN Side For UE3 GNB2
    Verify expected message flow    sNnodeAddPrep=1    xnUAddressInd=1    XNAPerrorInd=1    sNnodeReleaseRequired=1    XNAPuECtxRelease=1
        ...    uECtxMod=1    bearerCtxMod=1    F1APuECtxRelease=1    bearerCtxRelease=1

Verify Message Contents Of Unsuccessfull PSCell Addition
    Check Values From APIDs In XnUAddressIndication    id-newNG-RANnodeUEXnAPID=3    id-oldNG-RANnodeUEXnAPID=1111
    Verify In XNAP ErrorIndication_1 Out Of 1 That Cause Has radioNetwork Set To 'unknown-local-NG-RAN-node-UE-XnAP-ID' For GNB2
    Verify In XNAP SNodeReleaseRequired_1 Out Of 1 That Cause Has radioNetwork Set To 'unspecified' For GNB2
    Verify In F1AP UEContextReleaseCommand_1 Out Of 1 That Cause Contains radioNetwork Set To 'unspecified' For GNB2

Send Incorrect Xn ActivityNotification
    Execute Egate Command
    ...    cmd=gnb_ue_send_xn_activity_notification id=3 ue=1 override_sn_xnap_ue_id=${id-S-NG-RANnodeUEXnAPID} ran_paging_failure=off

Set Expected Message Flow For SNode Release After Error In ActivityNotification Message
    Set expected message flow    activityNotification=1    XNAPerrorInd=1    SNodeReleaseRequest=2    XNAPuECtxRelease=2    NGAPueCtxReleaseReq=2
        ...    NGAPueCtxRelease=2    F1APuECtxRelease=2    bearerCtxRelease=2

Verify Expected Message Flow For SNode Release After Error In ActivityNotification Message
    Verify expected message flow    activityNotification=1    XNAPerrorInd=1    SNodeReleaseRequest=2    XNAPuECtxRelease=2    NGAPueCtxReleaseReq=2
        ...    NGAPueCtxRelease=2    F1APuECtxRelease=2    bearerCtxRelease=2

Verify Message Contents For SNode Release After Incorrect APID In ActivityNotification Message
    Check Values From APIDs In XnAP ActivityNotification    id-M-NG-RANnodeUEXnAPID=${ue1-M-NG-RANnodeUEXnAPID}
    ...    id-S-NG-RANnodeUEXnAPID=${id-S-NG-RANnodeUEXnAPID}
    Verify In XNAP ErrorIndication_1 Out Of 1 That Cause Has radioNetwork Set To 'inconsistent-remote-NG-RAN-node-UE-XnAP-ID' For GNB2
    Check Values From APIDs In SNodeReleaseRequest    id-M-NG-RANnodeUEXnAPID=${ue1-M-NG-RANnodeUEXnAPID}
    ...    id-S-NG-RANnodeUEXnAPID=${ue1-S-NG-RANnodeUEXnAPID}    all=2    num_of_message=1
    Check Values From APIDs In XNUeContextRelease    id-M-NG-RANnodeUEXnAPID=${ue1-M-NG-RANnodeUEXnAPID}
    ...    id-S-NG-RANnodeUEXnAPID=${ue1-S-NG-RANnodeUEXnAPID}    all=2    num_of_message=1
    Check Values From APIDs In XNUeContextRelease    all=2    num_of_message=2
    Verify In XNAP SNodeReleaseRequest_1 Out Of 2 That Cause Has radioNetwork Set To 'unspecified' For GNB2
    Verify In XNAP SNodeReleaseRequest_2 Out Of 2 That Cause Has radioNetwork Set To 'unspecified' For GNB2
    Verify In NGAP UEContextReleaseRequest_1 Out Of 2 That Cause Has radioNetwork Set To 'unspecified' For AMF1
    Verify In NGAP UEContextReleaseRequest_2 Out Of 2 That Cause Has radioNetwork Set To 'unspecified' For AMF1
    Verify In NGAP UEContextReleaseCommand_1 Out Of 2 That Cause Has radioNetwork Set To 'unspecified' For AMF1
    Verify In NGAP UEContextReleaseCommand_2 Out Of 2 That Cause Has radioNetwork Set To 'unspecified' For AMF1
    Verify In F1AP UEContextReleaseCommand_1 Out Of 2 That Cause Contains radioNetwork Set To 'normal-release' For GNB2
    Verify In F1AP UEContextReleaseCommand_2 Out Of 2 That Cause Contains radioNetwork Set To 'normal-release' For GNB2
    Verify In E1AP BearerContextReleaseCommand_1 Out Of 2 That Cause Has radioNetwork Set To 'normal-release' For GNB2
    Verify In E1AP BearerContextReleaseCommand_2 Out Of 2 That Cause Has radioNetwork Set To 'normal-release' For GNB2

Stop Data Traffic
    [Arguments]    ${ue_id}=1   ${pdu_id}=1    ${qfi}=1    ${wait}=1s
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul
    Sleep    ${wait}
