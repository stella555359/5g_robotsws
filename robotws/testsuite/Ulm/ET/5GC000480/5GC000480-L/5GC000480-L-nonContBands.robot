*** Settings ***

Documentation   This is a Robot Test Suite for subfeature 5GC000480-L non-contiguous
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        commissioning.robot
Resource        keywords.robot
Resource        keywords-wts-iphy.robot
Resource        parameter-settings.robot
Resource        wireshark.robot


Resource        ../../../resources/Common/commissioning.robot


Suite Setup       Suite Setup 480L
Suite Teardown    keywords.Suite Teardown 480L

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***


5GC000480_L_evaluation_of_RAC_for_a_UE_with_carrier_aggregation_4CC_non_contiguous_carriers
    [Documentation]    This test case verifies the carrier_aggregation_4CC_non_contiguous_carriers
    ...       :Autor: Sylvia Schneider
    [Tags]    t6   CRT
    [Setup]   keywords.Perform Preconditions Of Test Scenario 480L

    parameter-settings.Prepare Counters And Expected Values 4CC
    commissioning.Update TC Specific Parameters

    wireshark.Start Wireshark Trace
    commissioning.Activate SCF And Bring TL onAir
    wireshark.Stop Wireshark Trace For Setup
    keywords-wts-iphy.Check Wts In Active State

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval

    wireshark.Start Wireshark Trace
    keywordbook-480.Attach UE   101
    wireshark.Stop Wireshark Trace   wireshark_store=${resultDir}/UE101.pcap

    keywordbook-480.Detach UE   101

    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    keywords.Collect Pm File And Verify Counter Values
    wireshark.Verify Wireshark 4CC


    [Teardown]   keywords.Perform Postconditions Of Test Scenario 480L




5GC000480_L_evaluation_of_RAC_for_a_UE_with_carrier_aggregation_3CC_non_contiguous_carriers
    [Documentation]    This test case verifies the carrier_aggregation_3CC_non_contiguous_carriers
    ...       :Autor: Sylvia Schneider
    [Tags]    t7   CRT
    [Setup]   keywords.Perform Preconditions Of Test Scenario 480L

    parameter-settings.Prepare Counters And Expected Values t7
    commissioning.Update TC Specific Parameters

    wireshark.Start Wireshark Trace
    commissioning.Activate SCF And Bring TL onAir
    wireshark.Stop Wireshark Trace For Setup
    keywords-wts-iphy.Check Wts In Active State

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval

    wireshark.Start Wireshark Trace
    keywordbook-480.Attach UE   101
    wireshark.Stop Wireshark Trace   wireshark_store=${resultDir}/UE101.pcap

    keywordbook-480.Detach UE   101

    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    keywords.Collect Pm File And Verify Counter Values
    wireshark.Verify Wireshark t7


    [Teardown]   keywords.Perform Postconditions Of Test Scenario 480L



5GC000480_L_evaluation_of_RAC_for_a_UE_with_carrier_aggregation_2CC_non_contiguous_carriers
    [Documentation]    This test case verifies the carrier_aggregation_2CC_non_contiguous_carriers
    ...       :Autor: Sylvia Schneider
    [Tags]    t8   CRT
    [Setup]   keywords.Perform Preconditions Of Test Scenario 480L

    parameter-settings.Prepare Counters And Expected Values 2CC
    commissioning.Update TC Specific Parameters

    wireshark.Start Wireshark Trace
    commissioning.Activate SCF And Bring TL onAir
    wireshark.Stop Wireshark Trace For Setup
    keywords-wts-iphy.Check Wts In Active State

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval

    wireshark.Start Wireshark Trace
    keywordbook-480.Attach UE   101
    wireshark.Stop Wireshark Trace   wireshark_store=${resultDir}/UE101.pcap

    keywordbook-480.Detach UE   101

    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    keywords.Collect Pm File And Verify Counter Values
    wireshark.Verify Wireshark 2CC


    [Teardown]   keywords.Perform Postconditions Of Test Scenario 480L



5GC000480_L_Unsuccessful_SCell_Addition_due_to_contiguous_carriers_not_available
    [Documentation]    This test case verifies the Unsuccessful_SCell_Addition_due_to_contiguous_carriers_not_available
    ...       :Autor: Sylvia Schneider
    [Tags]    t9   CRT
    [Setup]   keywords.Perform Preconditions Of Test Scenario 480L

    parameter-settings.Prepare Counters And Expected Values t9
    commissioning.Update TC Specific Parameters

    wireshark.Start Wireshark Trace
    commissioning.Activate SCF And Bring TL onAir
    wireshark.Stop Wireshark Trace For Setup
    keywords-wts-iphy.Check Wts In Active State

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval

    wireshark.Start Wireshark Trace
    keywordbook-480.Attach UE   101
    wireshark.Stop Wireshark Trace   wireshark_store=${resultDir}/UE101.pcap

    wireshark.Start Wireshark Trace
    keywordbook-480.Attach UE   102
    wireshark.Stop Wireshark Trace   wireshark_store=${resultDir}/UE102.pcap

    keywordbook-480.Detach UE   101
    keywordbook-480.Detach UE   102

    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    keywords.Collect Pm File And Verify Counter Values
    wireshark.Verify Wireshark t9


    [Teardown]   keywords.Perform Postconditions Of Test Scenario 480L



*** Keywords ***

Suite Setup 480L
    [Documentation]    [PRIVATE]    Prepare TL for 480L
    ...       :Autor: Sylvia Schneider
    keywordbook-480.Create Test Suite Folders
    keywordbook-480.Get Test Variables And Upload Start SCF
    ute_workarounds.UTE Cloud Workaround
    testline.Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    keywords.Get Version mcc mnc From gNB SCF    ${current_SCF_gnb}
    gnb.Store Current Swconfig From GNB
    wts_ue.Store Current Swconfig From Airphone
    wts_ue.Store Current WTS Config
    keywords-wts-iphy.Update Wts File For TC 480L noncontiguous
    keywords-wts-iphy.Update Iphy File noncontiguous
    commissioning.Update SCF Common Part noncontiguous
