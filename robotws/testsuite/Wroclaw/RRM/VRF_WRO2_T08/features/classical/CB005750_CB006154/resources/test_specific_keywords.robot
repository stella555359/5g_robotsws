*** Settings ***
Documentation
...   maintainer: Marta Hendler
...   contact: marta.hendler@nokia.com

Library     taf.ue
Library     ./test_specific_keywords.py  WITH NAME  test_keywords
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/bts_log.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

*** Keywords ***
Test Setup For NRARFCN Attach Scenario
    [Arguments]  ${cell_alias}  ${nrarfcn_level}
    test_keywords.Verify X2 Link
    test_keywords.Initialize Attenuator
    Set TESTNAME Without Spaces
    Start Bts Log  btslog
    Change Nrarfcn  ${nrarfcn_level}  ${cell_alias}
    test_keywords.Verify X2 Link
    Prepare Ue


Test Setup For UL And DL QAM Scenario
    [Arguments]  ${cell_alias}  ${mod_type}
    test_keywords.Verify X2 Link
    Initialize Attenuator
    Set Test Variable  ${QAM}  ${mod_type}
    Set TESTNAME Without Spaces
    Start Bts Log  btslog
    Change To Middle Nrarfcn  ${cell_alias}
    Wait Until Keyword Succeeds   3x   90sec  Change Modulation  ${mod_type}  ${cell_alias}
    test_keywords.Verify X2 Link
    Wait Until Keyword Succeeds   10x   10sec   Get QXDM License
    Prepare Ue


Test Teardown
    Run Keyword And Ignore Error  Detach UE  UE_1
    Release Attenuator
    Stop And Collect Btslog  btslog  ${OUTPUT_DIR}/${TEST_NAME}
    Add Scout Scf Id To Test Data
    Kill Tcpdump On CU
    Run Keyword If Test Failed  Log To Console  Collecting BTS Snapshot!
    Run Keyword If Test Failed  Collect BTS Snapshot
    Run Keyword And Ignore Error  interface.Common Step Trigger


Attach UE And Save L1L2 Log
    [Arguments]  ${cell_alias}
    Kill Tcpdump On CU
    Start Tcpdump On CU  filename=${test_name}_sctp.pcap
    Set Minimal Attenuation  ${cell_alias}
    Sleep  15s
    Wait Until Keyword Succeeds  3x  20 sec  Attach
    Stop And Collect Tcpdump On CU
    Check Attach Sctp Msgs  path_to_pcap=${path_to_pcap}


Attach
    taf.ue.Attach UE  UE_1
    Sleep  15s


Check Maximum Throughput And Average MCS
    [Arguments]  ${cell_alias}  ${mod_type}  ${deviation}=20%
    ${max_tput_mcs}  Get MCS Average For Max Tput  ${cell_alias}  ${mod_type}  ${deviation}
    Should Be True  26 <= ${max_tput_mcs[0]} and ${max_tput_mcs[0]} <= 28
    Should Be True  26 <= ${max_tput_mcs[1]} and ${max_tput_mcs[1]} <= 28


Check Average MCS For Given Attenuation
    [Arguments]  ${cell_alias}  ${mod_type}
    Get MCS Average For Attenuation Levels  ${cell_alias}  ${mod_type}


Prepare UE
    ADB Reboot UE
    taf.ue.Require UE  UE_1  capabilities=REAL_ANDROID_UE
    Run Keyword And Ignore Error  taf.ue.Detach UE  UE_1
    Sleep  30s


Stop And Collect Tcpdump On CU
    Stop Tcpdump On CU And Download Logs  filename=${test_name}_sctp.pcap
    Set Test Variable  ${path_to_pcap}  ${LOGPATH}/${test_name}_sctp.pcap


Get QXDM License
    Get 5g QXDM And Qcat License
    ...  username=tomasz.sobania@nokia.com
    ...  password=Tsob123,.
    ...  ue_id=${0}


Release QXDM License
     Run Keyword And Ignore Error  Release 5g QXDM And Qcat License  ue_id=${0}
