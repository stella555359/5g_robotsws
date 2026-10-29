*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Mateusz Kuropka
...              :contact: mateusz.kuropka@nokia.com

Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/tshark_verifying.robot
Resource     Keywords_CB006733.robot
Resource     ../../VRF_WRO2_T04/resources/ute_report.robot
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      ta5g_ue_mobility
Library	     OperatingSystem
Library      testsuite/Wroclaw/RRM/WRO_2/resources/CplaneOverloadSetter.py
Variables    logging_policy.py

Suite Setup    Run Keywords    With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}
...            AND             Extended SupervisionTimer    120
...            AND             Update And Put Iphy Xml    input_filepath=${iphy_xml}
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             With Simulator Configuration    config=${basic_setup}
...            AND             Setup Tshark With Nokia F1AP Plugin


*** Variables ***
${iphy_xml}=    ${CURDIR}/config/iphy_xml_6733.xml
${basic_setup}=       ${CURDIR}/config/wts_6733_AB9.cfg
${scfc}=    CB006733_B_B20_overload.xml
${ue_id}=    4
${cell2_a4_meas_id}=    1
${cell3_a4_meas_id}=    2
${nrsrq_nr}=    95
${nrsrp_nr}=    90
${cell2_pci}    52
${cell3_pci}    53
${number_of_messages}    1
@{SWCONFIG_FLAGS_LIST}=        ${0x89008e}    ${CB007208}
${0x89008e}=        0x89008E=0    #rdPreventOverloadActivationBeforeUeTresholdIsReached
${CB007208}=        0x890073=0    # Disabled CB007208

${Cplane_overload_state_enabled}=
...    nokiaf1ap.uACReductionIndication==100

${Cplane_overload_state_disabled}=
...    nokiaf1ap.uACReductionIndication==0

${BufferMonitoringVerification}=
...    nokiaf1ap.BufferMonitoringNotification_element &&
...    nokiaf1ap.BufferMonitoring==0

${BufferCriterionVerification}=
...    nokiaf1ap.BufferCriterionNotification_element &&
...    nokiaf1ap.BufferCriterion==0

${UeContextModReqAfterA4}=
...    nokiaf1ap.SCell_ToBeSetupMod_List==1 &&
...    nokiaf1ap.nRCellIdentity==00:00:04:00:30

${RRCReconfigurationWithA2}=
...    nr-rrc.rrcReconfiguration_element &&
...    nr-rrc.measObjectToAddModList==1 &&
...    nr-rrc.freqBandIndicatorNR==71 &&
...    nr-rrc.eventId==1 &&
...    nr-rrc.measIdToAddModList==1


*** Test Cases ***
CB006733-B_B20_Interaction_with_gNB_overload_5GC000281
    Register UE To gNB    ue_id=${ue_id}
    Enable Overload State
    Trigger A4 RSRQ Measurement    ue_id=${ue_id}    pci=${cell2_pci}    meas_id=${cell2_a4_meas_id}    nrsrq_nr=${nrsrq_nr}
    Start Data Traffic
    Disable Overload State
    Trigger A4 RSRP Measurement    ue_id=${ue_id}    pci=${cell3_pci}    meas_id=${cell3_a4_meas_id}    nrsrp_nr=${nrsrp_nr}
    Verify CPlane Overload State Enabled    ${Cplane_overload_state_enabled}
    Verify Buffer Monitoring Notification    ${BufferMonitoringVerification}    ${number_of_messages}
    Verify Buffer Criterion Notification    ${BufferCriterionVerification}
    Verify CPlane Overload State Disabled    ${Cplane_overload_state_disabled}
    Verify 1 SCells Addition After A4 Event Trigger    ${UeContextModReqAfterA4}
    Verify RRC SCell Addition    ${RRCReconfigurationWithA2}
    [Teardown]    Add Scout Data Info To Testcase

*** Keywords ***
Enable Overload State
    [Arguments]   ${ovl threshold}=0
    Log to console  Perform CPLANE OVL via R&D mechanism to value: ${ovl threshold}
    CplaneOverloadSetter.Set Overload High Threshold to ${ovl threshold} for ABIO 1
    CplaneOverloadSetter.Set Overload High Threshold to ${ovl threshold} for ABIO 2
    Sleep  10

Disable Overload State
    [Arguments]   ${ovl threshold}=200
    Log to console  Perform CPLANE OVL via R&D mechanism to value: ${ovl threshold}
    CplaneOverloadSetter.Set Overload High Threshold to ${ovl threshold} for ABIO 1
    CplaneOverloadSetter.Set Overload High Threshold to ${ovl threshold} for ABIO 2
    Sleep  10

