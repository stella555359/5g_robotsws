*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    QC_44422    QCD_MN_RAN    QCP_RAN_VRF
    ...    CLOUD_5G_I_LO_AP_LO

Documentation    :copyright: Nokia
...              :authors: Jakub Magier
...              :contact: jakub.magier@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/logging.robot
Resource     feature_keywords.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Variables    ta5g_global_var


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_1AEQE_1c.xml
...            AND             Enable C-Plane Debug Logs    with_reboot=${FALSE}
...            AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=full_config_9205_B_B1.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair   lua_cfg=${CURDIR}/config/egate_1c_1Ue.lua

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${NGAP: INITIAL CONTEXT SETUP REQUEST}=
...    (ngap.InitialContextSetupRequest_element)&&
...    (ngap.PDUSessionResourceSetupListCxtReq==1)
${F1AP: UE CONTEXT SETUP REQUEST}=    f1ap.UEContextSetupRequest_element
${F1AP: UE CONTEXT SETUP RESPONSE}=    f1ap.UEContextSetupResponse_element
${E1AP: BEARER CONTEXT SETUP REQUEST}=    e1ap.BearerContextSetupRequest_element
${E1AP: BEARER CONTEXT SETUP RESPONSE}=    e1ap.BearerContextSetupResponse_element
${RRC Reconfiguration}=
...    (nr-rrc.rrcReconfiguration_element)&&
...    (nr-rrc.ssbFrequency==633312)&&
...    (nr-rrc.eventId==1)&&
...    (nr-rrc.eventId==2)&&
...    (nr-rrc.eventId==4)&&
...    (nr-rrc.eventId==0)&&
...    (nr-rrc.a1_Threshold==1)&&
...    (nr-rrc.measIdToAddModList==4)
${RRC Reconfiguration Complete}=    nr-rrc.rrcReconfigurationComplete_element
${NGAP: INITIAL CONTEXT SETUP RESPONSE}=    ngap.InitialContextSetupResponse_element

*** Test Cases ***
CB009205-B_B1_A1_measurement_for_steering_UE_to_preferred_NR_layer_configuration_during_ICS_(RSRQ_case)
    Set Internal Traffic Type To UE
    Register UE To gNB With PDU Session Setup
    Wait For Registration Procedure Ending    2s
    Verify NGAP Initial Context Setup Request Occurred    ${NGAP: INITIAL CONTEXT SETUP REQUEST}
    Verify F1AP UE Context Setup Request Message Occurred    ${F1AP: UE CONTEXT SETUP REQUEST}
    Verify F1AP UE Context Setup Response Message Occurred    ${F1AP: UE CONTEXT SETUP RESPONSE}
    Verify E1AP Bearer Context Setup Request Message Occurred    ${E1AP: BEARER CONTEXT SETUP REQUEST}
    Verify E1AP Bearer Context Setup Response Message Occurred    ${E1AP: BEARER CONTEXT SETUP RESPONSE}
    Verify RRC Reconfiguration Message Occurred    ${RRC Reconfiguration}
    Verify RRC Reconfiguration Complete Message Occurred    ${RRC Reconfiguration Complete}
    Verify NGAP Initial Context Setup Response Occurred    ${NGAP: INITIAL CONTEXT SETUP RESPONSE}
    [Teardown]    Run Keywords    Deregister Ue    ue_id=1
    ...    AND    Add Scout Data Info To Testcase
