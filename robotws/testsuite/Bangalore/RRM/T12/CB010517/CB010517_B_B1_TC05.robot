*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO

Documentation   :copyright: Nokia
...             :author   : Omkar Jagadish Kamat
...             :contact  : omkar.kamat@nokia.com
...             :Feature  : The purpose of this TC is to verify power sent by the gnb to ue
...                         supporting power class1 to use.

Resource    resources/Keywords/CB010517_KW.robot

Suite Setup        Updated Suite Setup
Suite Teardown     Common Suite Teardown


*** Variables ***
${UE1}          51
${UE2}          71


*** Test Cases ***
[1][1.0] CB010517-B#B1_TC05_UE_Power_Class_1_support_in_n71_and_n85_frequency_bands
        [Documentation]    This is testing UE power for n71 and n85 bands
#        [Tags]    QC_28318   QCD_MN_RAN    QCP_RAN_VRF
        [Setup]     Prepare For CB010517 N71 And N85 PC1 Alignment
        Log To Console      Starting the test case\n
        UE Register Should Be Successful For SA     ${UE1}
        Sleep    30s
        UE Register Should Be Successful For SA     ${UE2}
        Sleep    30s
        Log To Console      Starting DL and UL traffic for UEs\n
        Start And Validate Traffic For SA    UE_ID=${UE1}
        Sleep    30s
        Start And Validate Traffic For SA    UE_ID=${UE2}
        Sleep    30s
        Stop Data Traffic For SA    ${UE1}
        Sleep    10s
        Stop Data Traffic For SA    ${UE2}
        Sleep    10s
        ${pcap_file}    Stop Pcap Collection In GNB CU
        Log To Console      ${pcap_file}
        ${pmax_value}    Check Pmax Is Correct For N71              ${pcap_file}
        Log To Console      \npmax value for n71 is correct ${pmax_value}
        ${pmax_value}    Check Pmax Is Correct For N85              ${pcap_file}
        Log To Console      \npmax value for n85 is correct ${pmax_value}
        Prepare Config To Validate Band N105 PDL Alignment
        [Teardown]     Run Keyword And Ignore Error      Common Test Case Tear Down LO AP LO
