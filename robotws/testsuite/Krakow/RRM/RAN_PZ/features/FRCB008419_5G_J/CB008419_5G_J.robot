*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Case CB008419-5G-J_3_CB007225 Feature activation and deactivation

Library    testsuite.Krakow.resources.alarm.Alarm    WITH NAME  alarm
Resource   taf/rfrl/bts/robot/gnb.robot
Library    keywords.py

Suite Setup      Setup
Suite Teardown   Teardown


*** Test Cases ***
[1]CB008419-5G-J_3_CB007225_Feature_activation_and_deactivation
    start_collecting_pcap_on_enbs
    Change AdministrativeState Of LNADJGNB  unlocked
    stop_collecting_pcap_on_enbs_and_download
    check_ConfigurationTransfer
    start_collecting_pcap_on_enbs
    sleep  300
    stop_collecting_pcap_on_enbs_and_download
    check_ConfigurationTransfer
    wait_until_alarm_is_active_on_enb  fault_name=X2(gNB) link ANR establishment failure  timeout=900  bts_id=0
    Change ActX2ConfigTransfer Parameter  true
    start_collecting_pcap_on_enbs
    sleep  300
    stop_collecting_pcap_on_enbs_and_download
    Check ConfigurationTransfer With Reply
    Check ENDCX2Setup
    check ENBConfiguration Update And Acknowledge


*** Keywords ***
Check ConfigurationTransfer
    check_ENBConfigurationTransfer  enb_id=0
    check_MMEConfigurationTransfer  enb_id=1
    check_ENDCConfigurationTransfer  enb_id=1
    check_ENDCConfigurationTransfer_reply_not_sent  enb_id=1

Check ENDCX2Setup
    check_ENDCX2SetupRequest  enb_id=0
    check_ENDCX2SetupResponse  enb_id=0

check ENBConfiguration Update And Acknowledge
    check_ENBConfigurationUpdate  enb_id=0
    check_ENBConfigurationUpdateAcknowledge  enb_id=0

Check ConfigurationTransfer With Reply
    check_ENBConfigurationTransfer  enb_id=0
    check_MMEConfigurationTransfer  enb_id=1
    check_ENDCConfigurationTransfer  enb_id=1
    check_ENBConfigurationTransfer_reply  enb_id=1
    check_MMEConfigurationTransfer_reply  enb_id=0
    check_ENDCConfigurationTransfer_reply  enb_id=1

Setup
    Wait For Site To Be Onair
    change_administrativeState_of_LNADJGNB  locked  enb_id=1
    sleep  60
    change_administrativeState_of_LNADJGNB  unlocked  enb_id=1
    Wait For Site To Be Onair
    Change ActEndcAutoX2Setup Parameter On Both Enbs  true
    Change ActX2ConfigTransfer Parameter  false
    Configure LNDAJGNB On Enb  enb_id=0

Teardown
    Wait For Site To Be Onair
