*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Anandapriya Mani
...                 :contact  : anandapriya.mani@nokia.com
...                 The aim of the feature is to verify UE Power Class 1 support for FR1 TDD band n78
...                 This test case is used to check robustness with 20 times ping pong HO

Resource            resources/Keywords/CB012981_Keyword.robot

Suite Setup         Updated Suite Setup
Suite Teardown      Common Suite Teardown

*** Variables ***
${UE_ID}=    1
${measID}=   4
${gw_ID}=    1
${TRAFFIC_DL_RATE}=    2
${TRAFFIC_UL_RATE}=    2
${iterations}=    21

*** Test Cases ***
[1][1.0] CB012981_D_20_Verify_UE_Power_Class_1_support_for_FR1_TDD_band_n78_during_multiple_intragNB_ping_pong_Handovers
    [Documentation]      This testcase is used to verify UE Power Class 1 support for FR1 TDD band n78
    [Tags]    QC_131680   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console       Starting the test......
    [Setup]              Prepare for test Case - CB012981_D_20
    UE Register Should Be Successful For SA      ${UE_ID}     ${gw_ID}
    FOR    ${i}    IN RANGE    1    ${iterations}
        Start pcap collection in gNB CU       gnbTcpdump0        -i any -s0
        Trigger A5 Measurement      ${UE_ID}    ${measID}     51
        ${pcap_file0}    Stop pcap collection in gNB CU          gnbTcpdump0
        get powerclass value from UEcontextmodreq         ${pcap_file0}
        get pMax value from UEcontextmodresp          ${pcap_file0}
        get pMax value from RRCreconfiguration          ${pcap_file0}
        Start pcap collection in gNB CU       gnbTcpdump0        -i any -s0
        Trigger A5 Measurement      ${UE_ID}    ${measID}     50
        ${pcap_file1}    Stop pcap collection in gNB CU          gnbTcpdump0
        get powerclass value from UEcontextmodreq         ${pcap_file1}
        get pMax value from UEcontextmodresp          ${pcap_file1}
        get pMax value from RRCreconfiguration HO         ${pcap_file1}
        Log to Console    HO is completed for iteration ${i}
    END
    [Teardown]     Run Keyword And Ignore Error     Tear Down for test Case - CB012981_D_20

[1][1.0] CB012981_B_1_Verify_successful_exchange_of_Chipset_and_RAN_identification_information_from_supporting_UEs_during_UE_Capability_retrieval
    [Documentation]      This testcase is used to verify successful exchange of chipset information
    [Tags]    QC_117719   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console       Starting the test......
    [Setup]              Prepare for test Case - CB012981_B_1
    Start pcap collection in gNB CU       gnbTcpdump0        -i any -s0
    UE Register Should Be Successful For SA      ${UE_ID}     ${gw_ID}
    ${pcap_file0}    Stop pcap collection in gNB CU          gnbTcpdump0
    get chipset and RAN id info from UEcapinfo         ${pcap_file0}
    get eutra information from UEcapinfo         ${pcap_file0}
    Start pcap collection in gNB CU       gnbTcpdump0        -i any -s0
    Sleep    30s
    wtsrunner.ue_ng_ctx_release    by=amf    id=1    cause=NAS_normal_release
    Sleep    10s
    wtsrunner.ue_im_exit    id=1
    Sleep    10s
    ${pcap_file0}    Stop pcap collection in gNB CU          gnbTcpdump0
    UE Deregister Should Be Successful For SA    ${UE_ID}
    check for dummy4 ueradioaccesscap information      ${pcap_file0}
    check if uecapenquiry is not sent by gnb      ${pcap_file0}
    [Teardown]     Run Keyword And Ignore Error     Tear Down for test Case - CB012981_B_1

[1][1.0] CB012981_C_6_Verify_gNB_display_a_PDL_validation_error_when_setting_inappropriate_scs_configuration_for_n31_band
    [Documentation]      This testcase is used to verify PDL validation error for FR1_n31_band_with_5_MHz_bandwidth
    [Tags]    QC_120602   QCD_MN_RAN    QCP_RAN_VRF
    Log to Console       Starting the test......
    [Setup]              Prepare for test Case - CB012981_C_5
    ${output}        Run Keyword And Ignore Error        GNB validate scf online
    ${pdl_error_value}    set variable
    ...    it is required that \${NRCELL-1.ssbScs} (value: 30 KHz) equal to 15KHz
    should be true  """${pdl_error_value}""" in """${output}"""
    [Teardown]     Run Keyword And Ignore Error     Tear Down for test Case - CB012981_C_5
