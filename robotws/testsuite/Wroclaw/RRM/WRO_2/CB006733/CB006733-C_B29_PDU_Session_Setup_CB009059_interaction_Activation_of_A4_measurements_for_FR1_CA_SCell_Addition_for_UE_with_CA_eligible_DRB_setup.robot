*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Jakub Magier
...              :contact: jakub.magier@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
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
${iphy_xml}=    ${CURDIR}/config/iphy_xml_6733.xml
${basic_setup}=       ${CURDIR}/config/wts_6733_C_B29.cfg
${scfc}=    CB006733_C_B29.xml
${ue_id}=    4

${PDUSessionResourceSetupRequest}=
...    ngap.PDUSessionResourceSetupRequest_element &&
...    ngap.QosFlowSetupRequestList==3 &&
...    ngap.fiveQI==5 &&
...    ngap.fiveQI==6 &&
...    ngap.fiveQI==7

${PDUSessionResourceSetupResponse}=
...    ngap.PDUSessionResourceSetupResponse_element &&
...    ngap.pDUSessionID==3 &&
...    ngap.associatedQosFlowList==3 &&
...    ngap.qosFlowIdentifier==1 &&
...    ngap.qosFlowIdentifier==2 &&
...    ngap.qosFlowIdentifier==3

${UeContextModReqWithA4}=
...    f1ap.UEContextModificationRequest_element &&
...    nr-rrc.measObjectToAddModList==6 &&
...    nr-rrc.reportConfigToAddModList==2 &&
...    nr-rrc.measIdToAddModList==6

${UeContextModRespWithMeasGap}=
...    f1ap.UEContextModificationResponse_element &&
...    nr-rrc.gapUE==1

${RRCReconfigurationWithA4}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==5 &&
...    nr-rrc.reportConfigToAddModList==2 &&
...    nr-rrc.measIdToAddModList==6 &&
...    nr-rrc.gapUE==1

*** Test Cases ***
CB006733-C_B29_PDU_Session_Setup_CB009059_interaction_Activation_of_A4_measurements_for_FR1_CA_SCell_Addition_for_UE_with_CA_eligible_DRB_setup
    Register UE To gNB without PDU session setup    ue_id=${ue_id}
    Setup PDU session with 3 DRBs    ue_id=${ue_id}
    Verify PDU Session Resource Setup Request With 3 Eligible DRBs    ${PDUSessionResourceSetupRequest}
    Verify PDU Session Resource Setup Response    ${PDUSessionResourceSetupResponse}
    Verify A4 Measurement Configuration    ${UeContextModReqWithA4}
    Verify Measurement Gap Configuration    ${UeContextModRespWithMeasGap}
    Verify RRC A4 Measurement Configuration    ${RRCReconfigurationWithA4}
    [Teardown]    Deregister Ue    ue_id=${ue_id}
