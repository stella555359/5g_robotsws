*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Palina Krasnova
...              :contact: palina.krasnova@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/tshark_verifying.robot
Resource     Keywords_CB006733.robot
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_ue_mobility
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${iphy_xml}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${basic_setup}

*** Variables ***
${iphy_xml}=     ${CURDIR}/config/iphy_xml_6733.xml
${basic_setup}=  ${CURDIR}/config/wts_6733_C_B30.cfg
${scfc}=         CB006733_C_B30.xml

${ue_id}=               4
${additional_qos}=      2

${gw_id_for_CA_eligible}=               3
${gw_id_for_CA_incompatible}=           1
${pdu_id_with_CA_eligible_DRB}=         3
${pdu_id_with_CA_incompatible_DRB}=     1

${a4_retry_timer}=    1

${PDUSessionResourceSetupRequest}=
...    ngap.PDUSessionResourceSetupRequest_element &&
...    ngap.pDUSessionID==1 &&
...    ngap.QosFlowSetupRequestList==2 &&
...    ngap.fiveQI==6 &&
...    ngap.fiveQI==5

${PDUSessionResourceSetupResponse}=
...    ngap.PDUSessionResourceSetupResponse_element &&
...    ngap.pDUSessionID==1 &&
...    ngap.associatedQosFlowList==2 &&
...    ngap.qosFlowIdentifier==1 &&
...    ngap.qosFlowIdentifier==2

${PDUSessionResourceReleaseCommand}=
...    ngap.PDUSessionResourceReleaseCommand_element &&
...    ngap.PDUSessionResourceToReleaseListRelCmd == 1 &&
...    ngap.pDUSessionID==1

${UEContextModificationRequest}=
...    f1ap.UEContextModificationRequest_element &&
...    f1ap.DRBs_ToBeReleased_List == 2 &&
...    f1ap.dRBID == 5 &&
...    f1ap.dRBID == 6

${UEContextModificationResponse}=
...    f1ap.UEContextModificationResponse_element &&
...    nr-rrc.rlc_BearerToReleaseList == 2 &&
...    nr-rrc.LogicalChannelIdentity == 5 &&
...    nr-rrc.LogicalChannelIdentity == 6

${PDUSessionResourceReleaseResponse}=
...    ngap.PDUSessionResourceReleaseResponse_element &&
...    ngap.pDUSessionID==1

${UeContextModReqWithA4}=
...    f1ap.UEContextModificationRequest_element &&
...    nr-rrc.measObjectToAddModList==3 &&
...    nr-rrc.reportConfigToAddModList==2 &&
...    nr-rrc.measIdToAddModList==3

${UeContextModRespWithMeasGap}=
...    f1ap.UEContextModificationResponse_element &&
...    nr-rrc.gapUE==1

${RRCReconfigurationWithA4}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==2 &&
...    nr-rrc.reportConfigToAddModList==2 &&
...    nr-rrc.measIdToAddModList==3 &&
...    nr-rrc.gapUE==1

*** Test Cases ***
CB006733-C_B30_PDU_Session_Release_CB009059_interaction_A4_measurement_activation_for_FR1_CA_SCell_Addition_upon_last_CA_incompatible_DRB_release
    Register UE To gNB without PDU session setup    ue_id=${ue_id}
    Setup PDU Session With CA Eligible DRB    ue_id=${ue_id}    pdu_id=${pdu_id_with_CA_eligible_DRB}    gw_id=${gw_id_for_CA_eligible}
    Setup Additional DRB    additional_qos=${additional_qos}
    Setup PDU session with non CA eligible DRB    ue_id=${ue_id}    pdu_id=${pdu_id_with_CA_incompatible_DRB}    gw_id=${gw_id_for_CA_incompatible}

    Verify PDU Session Resource Setup Request With non CA eligible DRB    ${PDUSessionResourceSetupRequest}
    Verify PDU Session Resource Setup Response    ${PDUSessionResourceSetupResponse}

    Release PDU Session With Non CA Eligible DRB    ue_id=${ue_id}    pdu_id=${pdu_id_with_CA_incompatible_DRB}

    Verify PDU Session Resource Release Command    ${PDUSessionResourceReleaseCommand}
    Verify UE Context Modification Request During PDU Session Release    ${UEContextModificationRequest}
    Verify UE Context Modification Response During PDU Session Release    ${UEContextModificationResponse}
    Verify PDU Session Resource Release Response    ${PDUSessionResourceReleaseResponse}

    Wait For A4 Retry Timer Expiration    a4_retry_timer=${a4_retry_timer}

    ## Verification of the second A4 Measurement and Measurement GAP configurations after the configurations during PDU Session Setup
    Verify A4 Measurement Configuration    ${UeContextModReqWithA4}     number_of_messages=1
    Verify Measurement Gap Configuration    ${UeContextModRespWithMeasGap}      number_of_messages=1
    Verify RRC A4 Measurement Configuration    ${RRCReconfigurationWithA4}

    [Teardown]    Run Keywords    Deregister Ue    ue_id=${ue_id}
    ...    AND    Add Scout Data Info To Testcase
