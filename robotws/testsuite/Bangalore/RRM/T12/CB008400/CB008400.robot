*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Anandapriya Mani
...                 :contact  : anandapriya.mani@nokia.com
...                 The aim of the feature is to verify successful exchange of chipset and vendor information
...                 This test case verifies on TDD UE capability,so FDD configuration is being removed from the gNB configuration

Resource            resources/Keywords/CB008400_Keyword.robot

Suite Setup         Updated Suite Setup
Suite Teardown      Common Suite Teardown

*** Variables ***
${UE_ID}=   1
${measID}=   1
${gw_ID}=    1
${TRAFFIC_DL_RATE}=    2
${TRAFFIC_UL_RATE}=    2

*** Test Cases ***
[1][1.0] CB008400_D_1_Verify_successful_exchange_of_Chipset_and_RAN_identification_information_from_supporting_UEs_during_UE_Capability_retrieval
    [Documentation]      This testcase is used to verify successful exchange of chipset information
    [Tags]    QC_195346   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console       Starting the test......
    [Setup]              Prepare for test Case - CB008400_D_1
    Start pcap collection in gNB CU       gnbTcpdump0        -i any -s0
    UE Register Should Be Successful For SA      ${UE_ID}     ${gw_ID}
    ${pcap_file0}    Stop pcap collection in gNB CU          gnbTcpdump0
    get chipset and RAN id info from UEcapinfo         ${pcap_file0}
    get eutra information from UEcapinfo         ${pcap_file0}
    Start pcap collection in gNB CU       gnbTcpdump1        -i any -s0
    Sleep    30s
    ue ng ctx release    by=amf    id=1    cause=NAS_normal_release
    Sleep    10s
    ue im exit    id=1
    Sleep    10s
    ${pcap_file1}    Stop pcap collection in gNB CU          gnbTcpdump1
    UE Deregister Should Be Successful For SA    ${UE_ID}
    check for dummy4 ueradioaccesscap information      ${pcap_file1}
    check if uecapenquiry is not sent by gnb      ${pcap_file1}
    [Teardown]     Run Keyword And Ignore Error     Tear Down for test Case - CB008400_D_1
