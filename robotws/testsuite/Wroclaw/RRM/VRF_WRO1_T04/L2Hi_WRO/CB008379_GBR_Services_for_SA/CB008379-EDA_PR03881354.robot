*** Settings ***
Resource    ../resources/common_keywords.robot
Resource     ../resources/common_configuration.robot
Resource    keywords_CB008379.robot
Library     ../resources/common_keywords.py
Documentation
...    author: Marcin Kotula
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 25R2

Suite Setup     Run Keywords    Enable Syslog Info Level Prints
    ...       AND    Configure VM interfaces For Second Gnb
    ...       AND    Enable Vonr And Rohc
    ...       AND    Enable ActNonVoNRGbrService
    ...       AND    Add Profiles For GBR 5QI
    ...       AND    Set NRDRB Parameters
    ...       AND    Modify Config To Emergency Call
    ...       AND    Configure SA VM interfaces
    ...       AND    Reach Onair    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...       AND    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    ...       AND    Set Internal Traffic Type To UEs
Suite Teardown    Run Keywords    Check For An Unexpected Alarm
...            AND    Stop Default Processes And Gather Logs And Compress Logs
Test Teardown     Send Configuration ID To Scout

*** Test Cases ***
CB008379-EDA_PR03881354
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    This case will verify successful 5QI-2 PDU session modify with enabled ActNonVONRGbrService and
    ...    unsuccessful 5QI-2 PDU session modify with disabled ActNonVONRGbrService.
    ...    2.Test Case Steps:
    ...         a. SA UE1 attach to CELL1, setup and modify PDU session.
    ...         b. UE1 send 30 Mbps DL and UL traffic.
    ...         c. UE1 is deregistered.
    ...    3. Expected Results:
    ...       With enabled ActNonVONRGbrService
    ...         Step a: UE1 PDU session is successfully established and modified with 5QI-2.
    ...         Step b: 30 Mbps traffic is ongoing in DL and UL on qfi_id=3.
    ...         Step c: UE1 is successfully deregistered.
    ...       With disabled ActNonVONRGbrService
    ...         Step a: UE1 PDU session is successfully established and modified with 5QI-1 and unsuccessfully modified with 5QI-2.

    Execute Test Steps Pdu Session Modify Successful
    Set dlFlowControlAlgo To None
    Execute Test Steps Pdu Session Modify Successful
    Disable ActNonVoNRGbrService
    Execute Test Steps Pdu Session Modify Unsuccessful
    Set dlFlowControlAlgo To 3gppFlowControl
    Execute Test Steps Pdu Session Modify Unsuccessful


*** Keywords ***
Set NRDRB Parameters
    Set feature flag NRDRB_5QI-5/fiveqiValueList to [128]
    Set feature flag NRDRB_5QI-7/fiveqiValueList to [2]
    Set feature flag NRDRB-14/rlcMode to RLC_UM
    Set feature flag NRDRB-14/nrDrbPdcpDN to MRBTS-1/NRBTS-1/NRDRB_PDCP-3
    Set feature flag NRDRB-14/nrDrbRlcUmDN to MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1

Disable ActNonVoNRGbrService
    Set feature flag NRCELL-1/actNonVoNRGbrService to False
    Set feature flag NRCELL-2/actNonVoNRGbrService to False

Set dlFlowControlAlgo To None
    Set feature flag NRDRB-14/dlFlowControlAlgo to none
    Set feature flag NRDRB-16/dlFlowControlAlgo to none

Set dlFlowControlAlgo To 3gppFlowControl
    Set feature flag NRDRB-14/dlFlowControlAlgo to 3gppFlowControl
    Set feature flag NRDRB-16/dlFlowControlAlgo to 3gppFlowControl

Execute Test Steps Pdu Session Modify Successful
    Attach Ue With 5QI 1
    Modify Pdu Session And Wait For Regexp    ue_id=1    pdu_id=1    qos_id=4    qfi_id=3    5qi_id=2
    Start 30Mbps In Dl and Ul
    Verify Dl And Ul Traffic
    Deregister Ue   ue_id=1

Execute Test Steps Pdu Session Modify Unsuccessful
    Attach Ue With 5QI 1
    Modify Pdu Session 5QI-2 And Wait For Unsuccessful
    Deregister Ue   ue_id=1

Attach Ue With 5QI 1
    Register Ue With Default Pdu Session
    Modify Pdu Session And Wait For Regexp    ue_id=1    pdu_id=1    qos_id=3    qfi_id=2    5qi_id=1

Modify Pdu Session 5QI-2 And Wait For Unsuccessful
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=4
    ...                      pass_regexp=AMF-1: Adding QosFlow with QFI:3 5QI:2
    ...                      pass_regexp=AMF-1: 'PDU Session Resource Modify Unsuccessful Transfer' with PDU Session ID 1
    ...                      pass_regexp=AMF-1: Deleted Unsuccessful QosFlow QFI:3
    ...                      timeout=10

Start 30Mbps In Dl and Ul
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl mbps=30
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul mbps=30

Verify Dl And Ul Traffic
    [Arguments]    ${expected_throughput_mbps}=30    ${qfi_id}=3    ${traffic_duration}=30s
    Sleep    ${traffic_duration}
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1
    ...    qfi_id=${qfi_id}
    ...    expected_throughput=${expected_throughput_mbps}    unit=mbps    margin=0.2    direction=dl
    Run Keyword And Continue On Failure    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1
    ...    qfi_id=${qfi_id}
    ...    expected_throughput=${expected_throughput_mbps}    unit=mbps    margin=0.2    direction=ul
