*** Settings ***
Documentation
...   maintainer: Marta Hendler
...   contact: marta.hendler@nokia.com

Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/LTE5190_A/resources/test_specific_keywords.py
Library        ute_ue
Library        taf.sw.syslog    WITH NAME    taf_syslog
Library        taf.ul.alarms_watchdog
Resource       testsuite/Wroclaw/RRM/resources/logs.robot
Resource       testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource       taf/rfrl/common_resources/common_step/interface.robot
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/allowed_alarms.py


*** Variables ***
${ABSTRACT_LIB_CONFIG}     /home/ute/testline_configuration/7_16_UTE5GCLOUDT196/ue_conf.yaml
${UE_ALIAS}                UE_1
${GNB_CELL_1}              GNB_1_CELL_50
${GNB_CELL_2}              GNB_1_CELL_51
${GNB_CELL_3}              GNB_1_CELL_52


*** Keywords ***
Test Setup
    Initialize Attenuator
    ute_ue.Require UE  ${UE_ALIAS}  capabilities=REAL_ANDROID_UE
    Run Keyword And Ignore Error  ute_ue.Detach UE  ${UE_ALIAS}
    taf_syslog.Start Syslog  log_dir=${LOG_PATH}  log_name=${test_name}_syslog.log
    ...           ip=${tl.test_pc.default_ssh_connection_details.addr}
    Log To Console  Syslog collection started
    Watch Alarms  allowed_alarms=${allowed_alarms}


Test Teardown
    Stop Watching Alarms
    ute_ue.Detach UE  ${UE_ALIAS}
    Release Attenuator
    Unblock Cell And Check State  ${CELL}
    taf_syslog.Collect Syslog Results
    Log To Console  Syslog collection stopped
    Make Snapshot In Case Of Error
    Run Keyword And Ignore Error    interface.Common Step Trigger
    Remove Files From VMs


[1]LTE5190_A_001_ENB_Receives_Partial_Reset_Required_From_EN_GNB
    ${cell_to_block}  ${cell_pci}  Pick Random Cell
    Set Global Variable  ${CELL}  ${cell_to_block}
    Start Tcpdump On LTE  filename=${test_name}_attach.pcap
    Attach  ${UE_ALIAS}  GNB_1_CELL_${cell_pci}  0dB
    Block Cell And Check State  ${cell_to_block}  alarm_to_check=7102
    Stop Tcpdump On LTE And Get Logs  filename=${test_name}_attach.pcap
    Sleep  5s
    Start Tcpdump On LTE  filename=${test_name}_reattach.pcap
    Unblock Cell And Check State  ${cell_to_block}
    Stop Tcpdump On LTE And Get Logs  filename=${test_name}_reattach.pcap
    Sleep  5s
    Check Detected Alarms
    Verify Scenario In Pcaps  ${cell_pci}  ${LOG_PATH}/${test_name}_attach.pcap  ${LOG_PATH}/${test_name}_reattach.pcap
