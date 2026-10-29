*** Settings ***
Documentation
...   Author: zhifu.xu@nokia-sbell.com
...   Contact: zhifu.xu@nokia-sbell.com
...   Description: This user scenario describes

Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Library     taf.config.wts        WITH NAME    wts_conf

Suite Setup    Run keywords    Common Suite Setup For AIC
...         AND    Config Eth Interface Internal    ${vm_config_path}
Suite Teardown    Common Suite Teardown For AIC

Test Timeout    120 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          CB009211_E_KeyWords.robot


*** Variables ***

${TL10872_wts}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB009211/APCFG/wts_cloud.cfg
${vm_config_path}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB009211/ap_tl10872.json

*** Test Cases ***
Update Local AP
    [Tags]    apupgrade
    Airphone Operation    operation=local_ap_upgrade    product_type=${None}
    ...               eth_config_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB009211/ap_tl10872.json
    ...               ap_build=${None}
    OperatingSystem.Run    cp ${TL10872_wts} /opt/wts/latest/basic_setup.cfg
    sleep    300

CB009211-A#B5_ET_10_Too_Early_handover_detection_after_successful_handover(intra-gNB)
    [Tags]    QC_115945    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    The user scenario describes the how “Too early handover” will be detected after successful intra-NR Handover when
    ...    the Handover happens between cells in the same gNB.The scenario describes the sequence of events where a UE does
    ...    a successful handover from Cell-1 to Cell-2, but “shortly” does a RRC Re-establishment back to Cell-1. (A#B5)
    ...    CB009211 new parameters
    ...        NRBTS.actIntraNRMRO  = true
    ...        NRBTS.tStoreUeContext = 10000
	...        NRBTS.tPingPong = 3000
	...        NRBTS.NRPMRNL.miNrNeighborNrNrCuSa=5min
	...    legacy parameters
	...       NRBTS.timerHOGuard = 2500,  NRBTS.tWaitingRlRecoverSA = 100000ms
    ...       NRBTS.rrcReestabTypeSA = sameGNB    NRBTS.actInterGnbRREPreparedCell = false

    [Setup]    Run Keywords    Case Precondition
#    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    Start Collect Counter    ${10872_cell4_distname}    ${MRO_EARLY_counter}    ${MRO_EARLY_counter_rule1}
    UE Deregister From gNB      ue_id=1
    Change UE1 Location To eNB2 Cell1
    Start Collect Wireshark For Cloud
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
#    Send A2 Measurement    ue_id=1    carrier_freq=628608
#    sleep    3s
#    Trigger RRC Reestablish After Successful HO    ue_id=1    cell_id=4    cause=otherFailure    time=350
    Send A3 Measurement And Attempt Handover    ue_id=1    phycell_id=52    carrier_freq=636576
    ...    pass_regexp=handover from EXT_ENB-2.1 to EXT_ENB-2.3
    Trigger RRC Reestablish    ue_id=1    cell_id=1    cause=otherFailure
#    Airphone Execute Egate Command   cmd=ue_rrc_reestablish id=1 gnb=2 cell=4 send_after=measurement_report time_to_wait=150
    Stop Collect Wireshark For Cloud
    Stop Collect Counter and verify PM counters
    [Teardown]    Run Keywords    Stop Collect Wireshark For Cloud
#    ...        AND                Case Postcondition

CB009211-D#B1_ET_01_Ping-pong_handover_detection_intra-Gnb
    [Tags]    QC_175517    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    The user scenario describes the how “Ping pong handovers” will be detected when UE moves between two cells inside same gNB(D#B1)
    ...    CB009211 new parameters
    ...        NRBTS.actIntraNRMRO  = true
    ...        NRBTS.tStoreUeContext = 10000
	...        NRBTS.tPingPong = 20000
	...        NRBTS.NRPMRNL.miNrNeighborNrNrCuSa=5min
	...    legacy parameters
	...       NRBTS.timerHOGuard = 2500,  NRBTS.tWaitingRlRecoverSA = 100000ms
    ...       NRBTS.rrcReestabTypeSA = sameGNB    NRBTS.actInterGnbRREPreparedCell = false

#    [Setup]    Run Keywords    Case Precondition
#    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    UE Deregister From gNB      ue_id=1
    Change UE1 Location To eNB2 Cell1
    Start Collect Counter    ${10872_cell4_distname}    ${MRO_PING_PONG_counter}    ${MRO_PING_PONG_counter_rule}
    Start Collect Wireshark For Cloud
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
#    Send A2 Measurement    ue_id=1    carrier_freq=628608
    Send A3 Measurement And Attempt Handover    ue_id=1    phycell_id=52    carrier_freq=636576
    ...    pass_regexp=handover from EXT_ENB-2.1 to EXT_ENB-2.3

    Send A3 Measurement And Attempt Handover    ue_id=1    phycell_id=50    carrier_freq=636576
    ...    pass_regexp=handover from EXT_ENB-2.3 to EXT_ENB-2.1
    Stop Collect Wireshark For Cloud
    Stop Collect Counter and verify PM counters
    [Teardown]    Run Keywords    Stop Collect Wireshark For Cloud
#    ...        AND                Case Postcondition

CB009211-B#B1_ET_01_HO_to_wrong_cell_During_intra-Gnb_HO
    [Tags]    QC_175489    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    The user scenario describes the how “Handover to wrong cell” will be detected through failures encountered during
    ...    execution of intra-NR Handover.The scenario describes the sequence of events, where a UE is executing handover from
    ...    Cell-1 to Cell-2 but encounters a failure and does RRC Re-establishment to a different cell, ie., Cell-3. (B#B1 ALT5)
    ...    CB009211 new parameters
    ...        NRBTS.actIntraNRMRO  = true
    ...        NRBTS.tStoreUeContext = 10000
	...        NRBTS.tPingPong = 3000
	...        NRBTS.NRPMRNL.miNrNeighborNrNrCuSa=5min
	...    legacy parameters
	...       NRBTS.timerHOGuard = 2500,  NRBTS.tWaitingRlRecoverSA = 100000ms
    ...       NRBTS.rrcReestabTypeSA = sameGNB    NRBTS.actInterGnbRREPreparedCell = false

#    [Setup]    Run Keywords    Case Precondition
#    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    UE Deregister From gNB      ue_id=1
    Change UE1 Location To eNB2 Cell1
    Start Collect Counter    ${10872_cell4_distname}    ${MRO_WRONG_counter}    ${MRO_WRONG_counter_rule}
    Start Collect Wireshark For Cloud
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1

    Trigger RRC Reestablish with cause    ue_id=1    cell_id=2    cause=handoverFailure
    Send A3 Measurement And Attempt Handover    ue_id=1    phycell_id=52    carrier_freq=636576
    ...    pass_regexp=rrcSetup
#    Airphone Execute Egate Command   cmd=ue_rrc_reestablish id=1 gnb=2 cell=4 send_after=measurement_report time_to_wait=150
    Stop Collect Wireshark For Cloud
    Stop Collect Counter and verify PM counters
    [Teardown]    Run Keywords    Stop Collect Wireshark For Cloud
#    ...        AND                Case Postcondition


CB009211-C#B2_ET_06_Too_Late_handover_detection_ when_HO_in_progress
    [Tags]    QC_175502    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    The user scenario describes the how “Too Late handover due to too late handover execution” will be detected when
    ...    UE does a RRC re-establishment in a neighboring cell. The scenario uses a case where neighbours are configured in
    ...    two different gNBs. The same behavior is expected when the neighboring cells are configured on same gNB.(C#B2_ALT1)
    ...    CB009211 new parameters
    ...        NRBTS.actIntraNRMRO  = true
    ...        NRBTS.tStoreUeContext = 10000
	...        NRBTS.tPingPong = 3000
	...        NRBTS.NRPMRNL.miNrNeighborNrNrCuSa=5min
	...    legacy parameters
	...       NRBTS.timerHOGuard = 2500,  NRBTS.tWaitingRlRecoverSA = 100000ms
    ...       NRBTS.rrcReestabTypeSA = sameGNB    NRBTS.actInterGnbRREPreparedCell = false

#    [Setup]    Run Keywords    Case Precondition
#    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    UE Deregister From gNB      ue_id=1
    Change UE1 Location To eNB2 Cell1
    Start Collect Counter    ${10872_cell4_distname}    ${MRO_LATE_EXEC_counter}    ${MRO_LATE_EXEC_counter_rule}
    Start Collect Wireshark For Cloud
    UE Register And PDU Session Setup    ue_id=1    ue_gw=1
    Start 10Mbps Traffic On PDU Session-1 QFI-1 dl for UE1
#    Send A2 Measurement    ue_id=1    carrier_freq=628608
#    sleep    3s
    Trigger RRC Reestablish with cause    ue_id=1    cell_id=3    cause=otherFailure
    Send A3 Measurement And Attempt Handover    ue_id=1    phycell_id=52    carrier_freq=636576
#    Airphone Execute Egate Command   cmd=ue_rrc_reestablish id=1 gnb=2 cell=4 send_after=measurement_report time_to_wait=150
    Stop Collect Wireshark For Cloud
    Stop Collect Counter and verify PM counters
    [Teardown]    Run Keywords    Stop Collect Wireshark For Cloud
    ...        AND                Case Postcondition
