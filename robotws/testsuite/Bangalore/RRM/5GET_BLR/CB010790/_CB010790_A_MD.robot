*** Settings ***
Documentation
...            CB010790      DU overload handling
...
...            author:        Marcin Duplaga, marcin.duplaga@nokia.com
...            maintainer:    Marcin Duplaga, marcin.duplaga@nokia.com

Resource    ./CB010790_common.robot

Suite Setup       Run Keywords
...               Enable gNB Overload Protection Feature
...    AND        Testline Setup    reach_on_air=yes    config=${SUITE_CONFIG}
...    AND        Change UEs Default Locations
Suite Teardown    Testline Teardown

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
Test Teardown     Test Case Teardown    check_radio_res=yes    oam_logs=yes

*** Variables ***
@{DCAP_GNB}                condor5gSyslog    cp_5g
@{DCAP_BTS}                ipCapture
&{DCAP_OPTIONS}            gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}          dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
${DELTA_CU_ovlSaRrcRej}    ${CURDIR}/configs/delta_cu_ovlSaRrcRej_enabled.json
${DELTA_emergency}         ${CURDIR}/configs/delta_emergency.json
@{DELTA_FILES}             ${DELTA_CU_ovlSaRrcRej}    ${DELTA_emergency}
&{SUITE_CONFIG}            delta=${DELTA_FILES}

*** Test Cases ***
[1]CB010790-A_4_gNB-DU_Overload_Emergency_call
    Start SA L3 Call    ue_id=1
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=2 establishment_cause=emergency
    SA UE Register    ue_id=2
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=3 establishment_cause=mps-PriorityAccess
    SA UE Register    ue_id=3
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=10 establishment_cause=mcs-PriorityAccess
    SA UE Register    ue_id=10
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=21 establishment_cause=highPriorityAccess
    SA UE Register    ue_id=21
    Enter Overload State on gNB-DU
    Verify Message Count in PCAP    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    filter=f1ap.GNBDUStatusIndication_element && f1ap.GNBDUOverloadInformation == overloaded    count=>1
    SA UE Register    ue_id=4    pass_regexp=RRC Reject was received
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=5 establishment_cause=emergency
    SA UE Register    ue_id=5
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=6 establishment_cause=mps-PriorityAccess
    Run Keyword And Ignore Error    SA UE Register    ue_id=6
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=22 establishment_cause=mcs-PriorityAccess
    Run Keyword And Ignore Error    SA UE Register    ue_id=22
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=23 establishment_cause=highPriorityAccess
    Run Keyword And Ignore Error    SA UE Register    ue_id=23
    Execute Egate Command Ext    cmd=ue_disp id=1
    Exit Overload State on gNB-DU
    Verify If Message Exists in GNB tcpdump
    ...    filter=f1ap.GNBDUStatusIndication_element && f1ap.GNBDUOverloadInformation == not-overloaded
    SA UE Register    ue_id=7
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=8 establishment_cause=emergency
    SA UE Register    ue_id=8
    Execute Egate Command    cmd=ue_nr_rrc_setup_param id=9 establishment_cause=highPriorityAccess
    SA UE Register    ue_id=9

    [Teardown]    Run Keywords
    ...           Exit Overload State on gNB-DU
    ...    AND    Test Case Teardown    oam_logs=yes    check_radio_res=yes

*** Keywords ***
Change UEs Default Locations
    Change UE Location  ue_id=21  node_id=2  cell_id=1
    Change UE Location  ue_id=22  node_id=2  cell_id=1
    Change UE Location  ue_id=23  node_id=2  cell_id=1
