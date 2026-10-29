*** Settings ***
Documentation
...   Author: huiqiong.yan@nokia-sbell.com
...   Contact: huiqiong.yan@nokia-sbell.com
...   Description: This user scenario describes

Suite Setup       Run keywords    Kill node    AND    Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM


Test Timeout    120 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource       ../../T01/Resources/RRM2_RRM_Resource.robot
Resource          CB008118_KeyWords.robot
Library     ta5g_tshark
Library      ute_tshark
Library      taf.config.wts      WITH NAME    wts_conf

*** Test Cases ***
CB008118_XB_EAR_TC05_From_CSV_KPI_impact_of_Mission_Critical_Services__Feature_interactions
    [Tags]    QC_235704        QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    This user scenario describes the gNB behavior for the successful setup of 5QI-69/65/70 followed by Mission critical
    ...    push to talk (i.e., 5QI 65/66,67) along with multi-features' interaction.
    [Setup]    Case Precondition
    Run Keyword And Ignore Error   Scout_cli start
#        Airphone Operation    edaemon_egate_setup     gnb tag=CB008118
    UE Deregister From gNB      ue_id=1-10

    UE1 Register
    UE1 And PDU Session-1 Gateway-1 Setup      #default setup 5QI-69
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=8,10 by=amf   #modify 5QI-65，67
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE1
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE1
    sleep    10s

    UE2 Register
    UE2 And PDU Session-1 Gateway-1 Setup      #default setup 5QI-69
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=8,11 by=amf   #modify 5QI-65，67
    Start 10Mbps Traffic On PDU Session-1 QFI-2 dl for UE2
    Start 10Mbps Traffic On PDU Session-1 QFI-3 dl for UE2
    sleep    10s
    [Teardown]    Run Keyword And Ignore Error      excute_teardown