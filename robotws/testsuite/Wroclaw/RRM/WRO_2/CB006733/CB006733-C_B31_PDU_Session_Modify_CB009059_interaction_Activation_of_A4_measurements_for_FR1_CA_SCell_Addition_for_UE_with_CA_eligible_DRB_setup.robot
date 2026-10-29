*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO    QC_44304    QCD_MN_RAN    QCP_RAN_VRF

Documentation    :copyright: Nokia
...              :authors: Jakub Magier
...              :contact: jakub.magier@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/tshark_verifying.robot
Resource     Keywords_CB006733.robot
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      ta5g_ue_mobility
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${iphy_xml}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${basic_setup}
...            AND             Wait For Next Full Pm Interval

*** Variables ***
${iphy_xml}=     ${CURDIR}/config/iphy_xml_6733.xml
${basic_setup}=  ${CURDIR}/config/wts_6733_C_B31.cfg
${scfc}=         CB006733_C_B31.xml
${ue_id}=        4

${PDUSessionResourceSetupRequest}=
...    ngap.PDUSessionResourceSetupRequest_element &&
...    ngap.QosFlowSetupRequestList==1 &&
...    ngap.fiveQI==6

${PDUSessionResourceSetupResponse}=
...    ngap.PDUSessionResourceSetupResponse_element &&
...    ngap.pDUSessionID==3 &&
...    ngap.associatedQosFlowList==1 &&
...    ngap.qosFlowIdentifier==1

${PDUSessionResourceModifyRequest}=
...    ngap.PDUSessionResourceModifyRequest_element &&
...    ngap.pDUSessionID==3 &&
...    ngap.QosFlowAddOrModifyRequestList==1 &&
...    ngap.qosFlowIdentifier==2 &&
...    ngap.fiveQI==5

${UeContextModReqWithEligibleDRB}=
...    f1ap.UEContextModificationRequest_element &&
...    f1ap.dRBID==5 &&
...    f1ap.fiveQI==5

${UeContextModRespWithEligibleDRB}=
...    f1ap.UEContextModificationResponse_element &&
...    f1ap.DRBs_SetupMod_List==1 &&
...    f1ap.dRBID==5

${PDUSessionResourceModifyResponse}=
...    ngap.PDUSessionResourceModifyResponse_element &&
...    ngap.pDUSessionID==3 &&
...    ngap.qosFlowAddOrModifyResponseList==1 &&
...    ngap.qosFlowIdentifier==2

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

${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4

*** Test Cases ***
CB006733-C_B31_PDU_Session_Modify_CB009059_interaction_Activation_of_A4_measurements_for_FR1_CA_SCell_Addition_for_UE_with_CA_eligible_DRB_setup
    Register UE To gNB without PDU session setup    ue_id=${ue_id}
    Setup PDU session with non CA eligible DRB    ue_id=${ue_id}
    Verify PDU Session Resource Setup Request With non CA eligible DRB    ${PDUSessionResourceSetupRequest}
    Verify PDU Session Resource Setup Response    ${PDUSessionResourceSetupResponse}
    Modify PDU session with CA eligible DRB    ue_id=${ue_id}
    Verify PDU Session Resource Modify Request With CA eligible DRB    ${PDUSessionResourceModifyRequest}
    Verify CA eligible DRB Addition    ${UeContextModReqWithEligibleDRB}
    Verify CA eligible DRB Addition    ${UeContextModRespWithEligibleDRB}
    Verify PDU Session Resource Modify Response    ${PDUSessionResourceModifyResponse}
    Verify A4 Measurement Configuration    ${UeContextModReqWithA4}
    Verify Measurement Gap Configuration    ${UeContextModRespWithMeasGap}
    Verify RRC A4 Measurement Configuration    ${RRCReconfigurationWithA4}
    Verify Pm Counter For Number Of A4 Measurements Activations    local_moid=${LOCAL_MOID}
    [Teardown]    Run Keywords    Deregister Ue    ue_id=${ue_id}
    ...    AND    Add Scout Data Info To Testcase
