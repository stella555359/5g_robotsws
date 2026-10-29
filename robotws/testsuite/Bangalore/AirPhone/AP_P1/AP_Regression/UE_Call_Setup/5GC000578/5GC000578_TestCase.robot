*** Settings ***
Documentation
...    author:  ramya.2.k@nokia.com
...    Description:Testcases for 5GC000578 Direct RRC signaling for NSA mode 3x operation
Resource        ./5GC000578_Keywords.robot

Suite Setup           Suite Setup for SRB3
Suite Teardown        Suite Teardown for SRB3

Test Setup            Test Setup for SRB3
Test Teardown         Test Teardown for SRB3

*** Test Cases ***
5GC000578_A_0010_verify RRC reconfiguration - mac-LogicalChannelConfig
    [Documentation]    This test case verifies RRC reconfiguration - mac-LogicalChannelConfig using SRB3
    [Tags]    CRT
    Initialise UE ID    ${ue_srb3_enabled}
    Perform UE Attach
    Perform SGNB Addition for Bearer
    Start Data Transfer
    Stop Data Transfer
    Perform UE Detach
    Wait for PCAP Collection
    Stop pcap collection in gNB and WTS
    Apply Wireshark Filter And Check Output    wireshark_filter=${filter_tcA10}

5GC000578_E_0003_NR SRB3 release - MN initiated SgNB release
    [Documentation]    This test case verifies NR SRB3 release - MN initiated SgNB release
    ...    ENDC Bearer is released by eNB to trigger MN initiated sGNB release
    [Tags]    CRT
    Initialise UE ID    ${ue_srb3_enabled}
    Perform UE Attach
    Perform SGNB Addition for Bearer
    Start Data Transfer
    Stop Data Transfer
    Perform MN initiated UE Detach
    Wait for PCAP Collection
    Stop pcap collection in gNB and WTS
    Apply Wireshark Filter And Check Output    wireshark_filter=${filter_tcE03}

5GC000578_G_0017_RRC message transfer over NR SRB3 and validate related PM counter
    [Documentation]    This test case verifies RRC message transfer over NR SRB3
    ...    DL RRC message transfer is achieved by enabling DRX feature
    ...    UL RRC message transfer is achieved by enabling A3 measurements and sending measurement report
    ...    PM counter validation is not done since AP has no impact
    [Tags]    CRT
    Initialise UE ID    ${ue_a3_srb3_enabled}
    Enable A3 measurements and DRX on gNB
    Perform UE Attach
    Perform SGNB Addition for Bearer
    Trigger RRCMessage Transfer
    Perform UE Detach
    Wait for PCAP Collection
    Stop pcap collection in gNB and WTS
    Apply Wireshark Filter And Check Output    wireshark_filter=${filter_tcG17}
    [Teardown]    Run Keywords    Disable A3 measurements and DRX on gNB    Test Teardown for SRB3

5GC000578_F_0004_NR SRB3 release - SN initiated SgNB release
    [Documentation]    This test case verifies NR SRB3 release - SN initiated SgNB release
    ...    UE Inactivity detection is enabled to trigger SN initiated SGNB release
    [Tags]    CRT
    Initialise UE ID    ${ue_srb3_enabled}
    Enable InactivityDetection on gNB
    Perform UE Attach
    Perform SGNB Addition for Bearer
    Start Data Transfer
    Stop Data Transfer
    Wait For NSA Inactivity Timer
    Perform UE Detach
    Wait for PCAP Collection
    Stop pcap collection in gNB and WTS
    Apply Wireshark Filter And Check Output    wireshark_filter=${filter_tcF04}
    [Teardown]    Run Keywords    Disable InactivityDetection on gNB    Test Teardown for SRB3

5GC000578_A_0001_NR SRB3 setup during SgNB addition
    [Documentation]    This testcase verifies behavior of SRB3 setup for different values of SRB3 flag on gNB and AP
    ...    Case 1 : SRB3 enabled on GNB and AP
    ...    Case 2 : SRB3 enabled on GNB and disabled on AP
    ...    Case 3 : SRB3 disabled on GNB and enabled on AP
    [Tags]    CRT
    [Setup]    Test Setup for Multiple UE
    comment    Case 1
    Initialise UE ID    ${ue_srb3_enabled}
    Perform Attach Detach and Collect PCAP
    Apply Wireshark Filter And Check Output    wireshark_filter=${filter_tcA01}
    WTS Teardown
    comment    Case 2
    WTS Setup
    Initialise UE ID    ${ue_srb3_disabled}
    Perform Attach Detach and Collect PCAP
    Apply Wireshark Filter And Check SRB3 is not used
    WTS Teardown
    comment    Case 3
    WTS Setup
    Initialise UE ID    ${ue_srb3_enabled}
    Disable SRB3 on gNB
    Perform Attach Detach and Collect PCAP
    Apply Wireshark Filter And Check SRB3 is not used
    [Teardown]    Test Teardown for Multiple UE
