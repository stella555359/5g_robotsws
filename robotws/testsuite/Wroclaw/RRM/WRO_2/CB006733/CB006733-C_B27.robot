*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Aleksandra Sienkiel
...              :contact: aleksandra.sienkiel@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/keywords/messaging.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/keywords/traffic.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/keywords/L3_Call.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/keywords/tshark_verifying.robot
Resource     Keywords_CB006733.robot
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_ue_mobility
Variables    logging_policy.py
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Variables    CB006733_messaging_filters.py
Library      ./verify_ta_messaging/CB006733.py

*** Variables ***
${iphy_xml}=    ${CURDIR}/config/iphy_xml_6733.xml
${basic_setup}=       ${CURDIR}/config/wts_6733_CB27.cfg
${scfc}=    CB006733_C_B27.xml
${ue_id}=    4

${PDUSessionResourceSetupRequest}=
...    ngap.pDUSessionID==4 &&
...    ngap.QosFlowSetupRequestList==3 &&
...    ngap.fiveQI==5 &&
...    ngap.fiveQI==6 &&
...    ngap.fiveQI==8

${PDUSessionResourceSetupResponse}=
...    ngap.pDUSessionID==4 &&
...    ngap.associatedQosFlowList==3 &&
...    ngap.qosFlowIdentifier==1 &&
...    ngap.qosFlowIdentifier==2 &&
...    ngap.qosFlowIdentifier==3

*** Test Cases ***
CB006733-C_B27_CB009059_interaction_Activation_of_A4_measurements_for_FR1_CA_SCell_Addition_during_ICS
    [Setup]    Run Keywords        Log to console    Full scfc commissioning with iphy.xml upload
    ...            AND             Update And Put Iphy Xml    input_filepath=${iphy_xml}
    ...            AND             With Gnb Configuration    commissioning=${scfc}
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging
    ...            AND             With Simulator Configuration    config=${BASIC_SETUP}
    ...            AND             Create SA Aliases    ue_id=${ue_id}

    Register UE To gNB Without PDU Session Setup    ue_id=${ue_id}
    Wait For UE Register    3s
    Set 2 expected RRC Reconfiguration Request and Complete messages for UE${ue_id} and 3 s timeout
    Setup 2 Additional DRBs    qos1=1    qos2=4
    Setup PDU Session Only    ue_id=${ue_id}    pdu_id=${ue_id}    gw_id=${ue_id}

    Verify that all 2 RRC Reconfiguration Request and Complete messages occured for UE${ue_id} and 3 s timeout
    Verify PDU Session Resource Setup Request With 3 Eligible DRBs on Ngap   ${PDUSessionResourceSetupRequest}
    Verify PDU Session Resource Setup Response on Ngap    ${PDUSessionResourceSetupResponse}
    Verify if UE4 RRCReconfiguration 2 of 2 contains A4 configuration for CB27

    [Teardown]    Deregister Ue    ue_id=${ue_id}
