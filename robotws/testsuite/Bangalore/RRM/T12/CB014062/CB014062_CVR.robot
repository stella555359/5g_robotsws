*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Bhakti
...                 :contact  :bhakti.ka_patel@nokia.com
...                 The aim of the feature is to verify UE Power Class 1 support for FR1 FDD band n66 and
...                 verify UE Power Class 2 support for FR1 FDD bands n85.

Resource            resources/Keywords/CB014062_Keyword.robot

Suite Setup         Updated Suite Setup
Suite Teardown      Common Suite Teardown


*** Variables ***
${UE_51}       51
${UE_81}       81
${gw_ID}        1
${TRAFFIC_DL_RATE}    50
${TRAFFIC_UL_RATE}    20


*** Test Cases ***
[1][1.0] CB014062_TMOUS_CVR_001_UE_Power_Class1_n66_AND_Power_Class2_n85
    [Documentation]     The aim of the feature is to verify UE Power Class 1 support for FR1 FDD band n66 and
    ...                verify UE Power Class 2 support for FR1 FDD bands n85.
    [Tags]    QC_280426   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]       Prepare For Test Case CB014062 CVR
    Log to Console       \nStarting the test for n66...
    slog.Start Syslog   ${Log_Path}     SysLogCapCVR.LOG
    Start pcap collection in gNB CU     CB014062_n66    -i any -s0
    UE Register Should Be Successful For SA      ${UE_51}     ${gw_ID}
    ${pcap_file}    Stop pcap collection in gNB CU         CB014062_n66
    ${PMAX31}      Get PMax value       ${pcap_file}      ${FILTER_PC1_TMO_CELL7}
    Compare Received And Expected PMAX Value     ${PMAX31}     ${EXP_PMAX_PC1}
    Log To Console     \nStarting case for n85...
    Start pcap collection in gNB CU      CB014062_n85        -i any -s0
    UE Register Should Be Successful For SA      ${UE_81}     ${gw_ID}
    Sleep    10s
    ${pcap_file1}    Stop pcap collection in gNB CU          CB014062_n85
    ${PMAX26}      Get PMax value       ${pcap_file1}      ${FILTER_PC2_TMO_CELL10}
    Compare Received And Expected PMAX Value     ${PMAX26}     ${EXP_PMAX_PC2}
    UE Deregister Should Be Successful For SA    ${UE_51}
    UE Deregister Should Be Successful For SA    ${UE_81}
    [Teardown]    Run Keyword And Ignore Error    Tear Down For Test Case CB014062
