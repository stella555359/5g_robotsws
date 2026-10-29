*** Settings ***
Documentation
...    author:  gopalakrishnan.n@nokia.com
...    Description:Testcases for 5GC000544 Ciphering and Integrity Protection of C-Plane for NSA mode 3x testing
...    Airphone capabilities.
...    Ciphering and Integration Alorithms are mentioned in these terms :
...          Null - NIA0, NEA0
...          AES - 128-NIA2, 128-NEA2
...          SNOW3G - 128-NIA1,128-NEA1
...          ZUC - 128-NIA3, 128-NEA3
...    Ciphering is denoted in AP cfg file in ue_param as nea and Integration Protocol is denoted as nia
Resource        ../../../Resources/robot/gnb.robot
Resource        ../../../Resources/robot/ute_setup.robot
Resource        ../../../Resources/robot/wts.robot
Resource        ../../../Resources/robot/log.robot
Resource        544_Keywords.robot
Resource        ../../../Resources/robot/suite_common_keywords.robot

Suite Setup       gNB and UTE Configuration
Suite Teardown    CleanUp

Test Setup        Test Setup for SRB3
Test Teardown     Test Teardown

*** Variables ***
${WTS_CFG_PATH}                 ${CURDIR}/cfg
${BEARER_ID_UL}                 3
${PCAP_WAIT_TIME}   5s

*** Test Cases ***
5GC000544_B_015 SRB3 creation with NULL ciphering and AES integrity
     [Documentation]     This test case Verifies that SRB3 is enabled with Null ciphering and AES integerity
     [Tags]    CRT
     Attach to UE Based on Ciphering Algorithm    nea=null    nia=aes    verify=srb3
     UE Detach    ue_id=${UE_ID}
     Wait For PCAP
     Stop pcap collection in gNB and WTS
     SRB3 Enabled And Ciphering Algorithm Should Match in PCAP    wireshark_filter=${wireshark_filter_tcB15}

5GC000544_B_005 DL RRC message transfer over SRB3 - Success with AES
     [Documentation]     This is to verify if DL RRC message is successfully transferred with AES security
     [Tags]    CIT
     Attach to UE Based on Ciphering Algorithm    nea=aes    nia=aes    verify=dl
     Trigger RRCMessage Transfer    ${UE_ID}
     UE Detach    ue_id=${UE_ID}
     Wait For PCAP
     Stop pcap collection in gNB and WTS
     SRB3 Enabled And Ciphering Algorithm Should Match in PCAP    wireshark_filter=${wireshark_filter_tcB05}

5GC000544_D_005 SRB3 messages with Null ciphering and SNOW3G integrity
     [Documentation]     This is to verify if UL/DL RRC messages are successfully transferred with SNOW3G int and NULL cip.
     [Tags]    CRT
     Attach to UE For UL and DL RRCMessageTransfer
     Perform UE Dettach for both UE
     Stop pcap collection in gNB and WTS
     Wait For PCAP
     SRB3 Enabled And Ciphering Algorithm Should Match in PCAP    wireshark_filter=${wireshark_filter_tcD05}
     [Teardown]    Test Teardown For Two UE

5GC000544_D_014 SRB3 creation with SNOW3G ciphering and AES integrity
     [Documentation]     This test case Verifies that SRB3 is enabled with snow3g ciphering and aes  integerity
     [Tags]    CIT
     Attach to UE Based on Ciphering Algorithm    nea=snow3g   nia=aes    verify=srb3
     UE Detach    ue_id=${UE_ID}
     Wait For PCAP
     Stop pcap collection in gNB and WTS
     SRB3 Enabled And Ciphering Algorithm Should Match in PCAP    wireshark_filter=${wireshark_filter_tcD14}

5GC000544_D_015 SRB3 creation with AES ciphering and SNOW3G integrity
     [Documentation]     This test case Verifies that SRB3 is enabled with aes ciphering and snow3g integerity
     [Tags]    CRT
     Attach to UE Based on Ciphering Algorithm    nea=aes   nia=snow3g    verify=srb3
     UE Detach    ue_id=${UE_ID}
     Wait For PCAP
     Stop pcap collection in gNB and WTS
     SRB3 Enabled And Ciphering Algorithm Should Match in PCAP    wireshark_filter=${wireshark_filter_tcD15}

5GC000544_C_001 SRB3 setup and security activation with ZUC
     [Documentation]     This test case Verifies that SRB3 is enabled with zuc ciphering and integerity
     [Tags]    CIT
     Attach to UE Based on Ciphering Algorithm    nea=zuc    nia=zuc    verify=srb3
     UE Detach    ue_id=${UE_ID}
     Wait For PCAP
     Stop pcap collection in gNB and WTS
     SRB3 Enabled And Ciphering Algorithm Should Match in PCAP    wireshark_filter=${wireshark_filter_tcC01}

*** Keywords ***
gNB and UTE Configuration
    Suite Common Keywords    feature_folder=5GC000544
    Prepare Environment Based On Run Type     cfg_type=custom
    Wait for gNB To Be Ready
    Enable Parameters Related to SRB3
    ute_setup.Modify UTE SCTP Timeout    ${AP_IP}    ${AP_Username}    ${NOKIA_PASS}

CleanUp
    Common Suite Teardown Keywords
    Revert Parameters Related to SRB3

Test Setup for SRB3
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Start and configure WTS
    Establish X2 link And Wait For Cell Setup

Test Teardown
    Run Keyword And Ignore Error    UE Detach    ue_id=${UE_ID}
    Common Test Teardown

Test Teardown For Two UE
    Run Keyword And Ignore Error    Perform UE Dettach for both UE
    Common Test Teardown

Wait For PCAP
   Sleep   ${PCAP_WAIT_TIME}
