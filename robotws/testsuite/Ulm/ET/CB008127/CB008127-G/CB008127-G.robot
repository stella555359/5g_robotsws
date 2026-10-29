*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008127-G
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot

Resource        CB008127-G-commissioning.robot
Resource        CB008127-G-wts.robot
Resource        CB008127-G-parameter-settings.robot
Resource        CB008127-G-keywords.robot
Resource        CB008127-G-keywords-egate.robot
Resource        CB008127-G-keywords-egate-verify.robot
Resource        CB008127-G-counter.robot
Resource        CB008127-G-verify-wireshark.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot

Suite Setup       Suite Setup CB008127-G
Suite Teardown    Suite Teardown CB008127-G

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}
@{A1_measIdToRemoveList}     5      6      7

*** Test Cases ***


CB008127_G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profile_based_upon_PLMN
    [Documentation]    G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profile_based_upon_PLMN
    ...       :Autor: Shruthi Shivaprasad
    [Tags]    t1
    [Setup]   Perform Preconditions of Test Scenario CB008127-G

    prepare counters and expected values t1
    Update SCF t1
    upload wts cfg file     ${resultBaseDir}/basic_wts_CB008127_G.cfg

    start wireshark trace
    activate SCF and bring tl onAir t1
    Setup X2 Link to gnb-3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    check wts in active state

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    attach UE and sgnbAddition and disp meas   ue_id=101

    send measurement gap info                  ue_id=101
    send A2                                    ue_id=101   meas_id=3
    display measurements of UE                 ue_id=101   log=_2

    Detach UE from LTE                         ue_id=101

    attach UE and sgnbAddition and disp meas for UE103

    delta commissioning to modify PLMN-2 in NRMEASPR_MA_NSA-1 t1

    attach UE and sgnbAddition and disp meas for UE102

    stop wireshark trace   wireshark_store=${resultDir}/wireshark_t1.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008127-G
    verify egate logs t1

    [Teardown]   Perform Postconditions of Test Scenario CB008127-G



CB008127_G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profilebased_upon_PLMN_and_SPID
    [Documentation]    G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profile_based_upon_PLMN_SPID
    ...       :Autor: Shruthi Shivaprasad
    [Tags]    t2
    [Setup]   Perform Preconditions of Test Scenario CB008127-G

    prepare counters and expected values t2
    Update SCF t2
    upload wts cfg file     ${resultBaseDir}/basic_wts_CB008127_G.cfg

    start wireshark trace
    activate SCF and bring tl onAir t2
    Setup X2 Link to gnb-3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    check wts in active state

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    set spid for UE          ue_id=101     spid=85

    attach UE and sgnbAddition and disp meas   ue_id=101

    send measurement gap info                  ue_id=101
    send A2                                    ue_id=101   meas_id=3
    display measurements of UE                 ue_id=101   log=_2

    Detach UE from LTE                         ue_id=101

    set spid for UE          ue_id=103     spid=85
    attach UE and sgnbAddition and disp meas for UE103

    attach UE and sgnbAddition and disp meas for UE102

    stop wireshark trace   wireshark_store=${resultDir}/wireshark_t2.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008127-G
    verify egate logs t2

    [Teardown]   Perform Postconditions of Test Scenario CB008127-G


CB008127_G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profilebased_upon_SPID
    [Documentation]    G_Configuration_of_intraFreq_measurements_A1_A2_A3_during_SgNB_addition_using_measurement_profile_based_upon_SPID
    ...       :Autor: Shruthi Shivaprasad
    [Tags]    t3
    [Setup]   Perform Preconditions of Test Scenario CB008127-G

    prepare counters and expected values t3
    Update SCF t3
    upload wts cfg file     ${resultBaseDir}/basic_wts_CB008127_G.cfg

    start wireshark trace
    activate SCF and bring tl onAir t3
    Setup X2 Link to gnb-3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    check wts in active state

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    set spid for UE          ue_id=101     spid=85

    attach UE and sgnbAddition and disp meas   ue_id=101

    send measurement gap info                  ue_id=101
    send A2                                    ue_id=101   meas_id=3
    display measurements of UE                 ue_id=101   log=_2

    Detach UE from LTE                         ue_id=101

    set spid for UE          ue_id=103     spid=85
    attach UE and sgnbAddition and disp meas for UE103

    attach UE and sgnbAddition and disp meas for UE102

    stop wireshark trace   wireshark_store=${resultDir}/wireshark_t3.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008127-G
    verify egate logs t3
    [Teardown]   Perform Postconditions of Test Scenario CB008127-G


CB008127_G_Reselection_of_measurement_profile_based_upon_mutiple_creiterions_during_measurement_reconfiguration
    [Documentation]    CB008127_G_Reselection_of measurement_profile_based_upon_mutiple_creiterions_during_measurement_reconfiguration
    ...       :Autor: Shruthi Shivaprasad
    [Tags]    t4
    [Setup]   Perform Preconditions of Test Scenario CB008127-G

    prepare counters and expected values t4
    Update SCF t4
    upload wts cfg file     ${resultBaseDir}/basic_wts_CB008127_G.cfg

    start wireshark trace
    activate SCF and bring tl onAir t4
    Setup X2 Link to gnb-3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    check wts in active state

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace gNB

    set spid for UE          ue_id=103     spid=85
    attach UE and sgnbAddition and disp meas   ue_id=103

    send measurement gap info                  ue_id=103
    send A2                                    ue_id=103   meas_id=3
    display measurements of UE                 ue_id=103   log=_2
    send A1 UE103                              ue_id=103
    display measurements of UE                 ue_id=103   log=_3
    Detach UE from LTE                         ue_id=103

    delta commissioning to set to rsrpCombined t4

    set spid for UE          ue_id=104     spid=85
    attach UE and sgnbAddition and disp meas   ue_id=104

    send measurement gap info                  ue_id=104
    send A2 srsrp_srsrq                        ue_id=104   meas_id=3   srsrp=90   srsrq=90
    display measurements of UE                 ue_id=104   log=_2
    send A1 UE104                              srsrp=100   srsrq=100
    display measurements of UE                 ue_id=104   log=_3
    Detach UE from LTE                         ue_id=104

    delta commissioning to set to srb3 t4

    set spid for UE          ue_id=105     spid=85
    attach UE and sgnbAddition and disp meas   ue_id=105

    send measurement gap info                  ue_id=105
    send A2                                    ue_id=105   meas_id=3
    display measurements of UE                 ue_id=105   log=_2
    send A1 UE103                              ue_id=105
    display measurements of UE                 ue_id=105   log=_3
    Detach UE from LTE                         ue_id=105

    stop wireshark trace gNB  wireshark_store=${resultDir}/wireshark_t4.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008127-G
    verify egate logs t4    ${A1_measIdToRemoveList}
    verify wireshark t4

    [Teardown]   Perform Postconditions of Test Scenario CB008127-G

CB008127_G_Reselection_of_measurement_profile_based_upon_mutiple_creiterions_during_measurement_reconfiguration_mobility_profile
    [Documentation]    G_Reselection_of_measurement_profile_based_upon_mutiple_creiterions_during_measurement_reconfiguration_mobility_profile
    ...       :Autor: Shruthi Shivaprasad
    [Tags]    t5
    [Setup]   Perform Preconditions of Test Scenario CB008127-G

    prepare counters and expected values t5
    Update SCF t5
    upload wts cfg file     ${resultBaseDir}/basic_wts_CB008127_G.cfg

    start wireshark trace
    activate SCF and bring tl onAir t5
    Setup X2 Link to gnb-3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    check wts in active state

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    set spid for UE          ue_id=103     spid=85
    attach UE and sgnbAddition and disp meas   ue_id=103

    send measurement gap info                  ue_id=103
    send A2                                    ue_id=103   meas_id=3
    display measurements of UE                 ue_id=103   log=_2
    send A1 UE103                              ue_id=103
    display measurements of UE                 ue_id=103   log=_3
    Detach UE from LTE                         ue_id=103

    stop wireshark trace   wireshark_store=${resultDir}/wireshark_t5.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008127-G
    verify egate logs t5    ${A1_measIdToRemoveList}

    [Teardown]   Perform Postconditions of Test Scenario CB008127-G

*** Keywords ***


Suite Setup CB008127-G
    [Documentation]    [PRIVATE]    Prepare TL for CB008127-G
    ...       :Autor: Shruthi Shivaprasad
    ute_workarounds.Log TL Info as Metadata for UTE AP TL
    Create ips for simulated gnb and eNB
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    get version mcc mnc from gNB SCF    ${current_SCF_gnb}
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    update gscn in iphy file
    Update wts file for TC CB008127-G
    Update SCF file for TC CB008127-G common part
