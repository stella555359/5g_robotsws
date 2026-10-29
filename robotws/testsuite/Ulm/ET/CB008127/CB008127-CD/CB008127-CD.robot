*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008127-CD
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot

Resource        CB008127-CD-commissioning.robot
Resource        CB008127-CD-wts.robot
Resource        CB008127-CD-parameter-settings.robot
Resource        CB008127-CD-keywords.robot
Resource        CB008127-CD-keywords-egate.robot
Resource        CB008127-CD-keywords-egate-verify.robot
Resource        CB008127-CD-counter.robot
Resource        CB008127-CD-verify-wireshark.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/btslog.robot

Library         ../../../resources/Common/syslog_parser/syslog_parser.py

Suite Setup       Suite Setup CB008127-CD
Suite Teardown    Suite Teardown CB008127-CD

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}
${dir_syslog_parser}                  ${CURDIR}/../../../resources/Common/syslog_parser

*** Test Cases ***


CB008127_CD_Configuration_of_intraFreq_meas_A2_A3_A5_during_SgNB_addition_using_selected_meas_profile_for_NSA
    [Documentation]    CD_Configuration_of_intraFreq_meas_A2_A3_A5_during_SgNB_addition_using_selected_meas_profile_for_NSA
    ...       :Autor: Sylvia Schneider
    [Tags]    t1
    [Setup]   Perform Preconditions of Test Scenario CB008127-CD

    Prepare Counters And Expected Values t1
    Update SCF t1
    Upload Wts Cfg File     ${resultBaseDir}/basic_wts_CB008127_CD.cfg

    Start Wireshark Trace
    Activate SCF And Bring TL onAir t1
    Setup X2 Link to gnb-3
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword and Warn On Failure     Prepare For Dcap Tracing
    Run Keyword and Warn On Failure     Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Attach UE And sgnbAddition And Disp Meas For 3 UEs

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Verify Counter CB008127-CD
    Verify Egate Logs t1

    [Teardown]   Perform Postconditions of Test Scenario CB008127-CD



CB008127_CD_Configuration_of_intraFreq_meas_A2_A3_A5_during_MeNB_initiated_SgNB_Modification_using_meas_profile
    [Documentation]    CD_Configuration_of_intraFreq_meas_A2_A3_A5_during_MeNB_initiated_SgNB_Modification_using_meas_profile
    ...       :Autor: Sylvia Schneider
    [Tags]    t2
    [Setup]   Perform Preconditions of Test Scenario CB008127-CD

    Prepare Counters And Expected Values t2
    Update SCF t2
    Update wts file for TC CB008127-CD add cell2
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_CD_add_cell2.cfg

    Start Wireshark Trace
    Activate SCF And Bring TL onAir t2
    Setup X2 Link to gnb-3
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword and Warn On Failure     Prepare For Dcap Tracing
    Run Keyword and Warn On Failure     Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace
    Attach UE And sgnbAddition And Disp Meas   ue_id=101
    Initiate SgNB Modification
    Display Measurements Of UE                 ue_id=101   log=_2
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_t2.pcap
    Detach UE from LTE                         ue_id=101

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Verify Counter CB008127-CD
    Verify Egate Logs t2
    verify wireshark t2

    [Teardown]   Perform Postconditions of Test Scenario CB008127-CD



CB008127_CD_Configuration_of_A2_measurement_using_measurement_profile_upon_A1_measurement_report
    [Documentation]    CD_Configuration_of_A2_measurement_using_measurement_profile_upon_A1_measurement_report
    ...       :Autor: Sylvia Schneider
    [Tags]    t3
    [Setup]   Perform Preconditions of Test Scenario CB008127-CD

    Prepare Counters And Expected Values t3
    Update SCF t3
    Update wts file for TC CB008127-CD add cell2
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_CD_add_cell2.cfg

    Start Wireshark Trace
    Activate SCF And Bring TL onAir t3
    Setup X2 Link to gnb-3
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword and Warn On Failure     Prepare For Dcap Tracing
    Run Keyword and Warn On Failure     Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace
    Attach UE And sgnbAddition And Disp Meas   ue_id=101
    Send Measurement Gap Info                  ue_id=101
    Send A2 Twice And Disp Meas t3
    Send A1 Twice And Disp Meas
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_t3.pcap
    Detach UE from LTE                         ue_id=101

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Verify Counter CB008127-CD
    Verify Egate Logs t3

    [Teardown]   Perform Postconditions of Test Scenario CB008127-CD



CB008127_CD_Configuration_of_intraFreq_measurements_during_interMeNB_handover_with_PSCell_change_using_meas_profile
    [Documentation]    CD_Configuration_of_intraFreq_measurements_during_interMeNB_handover_with_PSCell_change_using_meas_profile
    ...       :Autor: Sylvia Schneider
    [Tags]    t4
    [Setup]   Perform Preconditions of Test Scenario CB008127-CD

    Prepare Counters And Expected Values t4
    Update SCF t4
    Update wts file for TC CB008127-CD add cell2 and eNB9
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_CD_add_cell2_eNB9.cfg

    Start Wireshark Trace
    Activate SCF And Bring TL onAir t4
    Setup X2 Link to gnb-3
    Setup X2 Link to enb-9
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword and Warn On Failure     Prepare For Dcap Tracing
    Run Keyword and Warn On Failure     Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace
    Attach UE And sgnbAddition And Disp Meas   ue_id=101
    Send Measurement Gap Info                  ue_id=101
    Send A2                                    ue_id=101   meas_id=3    srsrp_nr=80    srsrq_nr=80
    Display Measurements Of UE    ue_id=101   log=_2

    Send Endc Param
    Send Intra Lte Handover
    Display Measurements Of UE    ue_id=101   log=_3

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_t3.pcap
    Detach UE from LTE                         ue_id=101

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Verify Counter CB008127-CD
    Verify Egate Logs t4

    [Teardown]   Perform Postconditions of Test Scenario CB008127-CD



CB008127_CD_Interaction_with_mobility_profiles_and_MFBI_during_PS_cell_change_using_measurement_profile
    [Documentation]    CD_Interaction_with_mobility_profiles_and_MFBI_during_PS_cell_change_using_measurement_profile
    ...       :Autor: Sylvia Schneider
    [Tags]    t5
    [Setup]   Perform Preconditions of Test Scenario CB008127-CD

    Prepare Counters And Expected Values t5
    Update SCF t5
    Update wts file for TC CB008127-CD add cell2 and MFBI
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_CD_add_cell2_MFBI.cfg

    Start Wireshark Trace
    Activate SCF And Bring TL onAir t5
    Setup X2 Link to gnb-3
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword and Warn On Failure     Prepare For Dcap Tracing
    Run Keyword and Warn On Failure     Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace
    Attach UE And sgnbAddition And Disp Meas   ue_id=104

    Send Two Times A3 With phycell_id 48 And 50 And Disp Meas
    Send Measurement Gap Info       ue_id=104

    Send A2 Twice And Disp Meas t5

    Send Two Times A3 With srsrq_nr And nrsrq_nr And Disp Meas

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_t5.pcap
    Detach UE from LTE                         ue_id=104

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Verify Counter CB008127-CD
    Verify Egate Logs t5

    [Teardown]   Perform Postconditions of Test Scenario CB008127-CD



CB008127_CD_Interaction_with_MFBI_and_A1_based_traffic_steering_to_preferred_NR_layer_after_SgNB_addition
    [Documentation]    CD_Interaction_with_MFBI_and_A1_based_traffic_steering_to_preferred_NR_layer_after_SgNB_addition
    ...       :Autor: Sylvia Schneider
    [Tags]    t6
    [Setup]   Perform Preconditions of Test Scenario CB008127-CD

    Prepare Counters And Expected Values t6
    Update SCF t6
    Update wts file for TC CB008127-CD add cell2 and MFBI
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_CD_add_cell2_MFBI.cfg

    Start Wireshark Trace
    Activate SCF And Bring TL onAir t6
    Setup X2 Link to gnb-3
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword and Warn On Failure     Prepare For Dcap Tracing
    Run Keyword and Warn On Failure     Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace
    Attach UE And sgnbAddition And Disp Meas   ue_id=104

    Send Measurement Gap Info                  ue_id=104

    Send A1 For A4 Measurement Configuration
    Send A4 And Disp Meas

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_t6.pcap
    Detach UE from LTE                         ue_id=104

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Verify Counter CB008127-CD
    Verify Egate Logs t6

    [Teardown]   Perform Postconditions of Test Scenario CB008127-CD



CB008127_PX_NSA_Distribution_of_mapping_selection_and_measurement_profile_usage
    [Documentation]    PX_NSA_Distribution_of_mapping_selection_and_measurement_profile_usage
    ...       :Autor: Sylvia Schneider
    [Tags]    t7
    [Setup]   Perform Preconditions of Test Scenario CB008127-CD

    Prepare Counters And Expected Values t7
    Update SCF t7
    Update wts file for TC CB008127-CD add cell2
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_CD_add_cell2.cfg

    Start Wireshark Trace
    Activate SCF And Bring TL onAir t7
    Setup X2 Link to gnb-3
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword and Warn On Failure     Prepare For Dcap Tracing
    Run Keyword and Warn On Failure     Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace
    Attach UE And sgnbAddition And Disp Meas   ue_id=101

    Send Measurement Gap Info                  ue_id=101
    Send A2                                    ue_id=101   meas_id=3    srsrp_nr=80    srsrq_nr=80
    Display Measurements Of UE                 ue_id=101   log=_2

    Start Intra LTE Handover Without PSCell Change And Update Allowed BC List MRDC     ue_id=101   allowed_bc_list_mrdc=2:1
    Display Measurements Of UE                 ue_id=101   log=_3

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_t7.pcap
    Detach UE from LTE                         ue_id=101

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Verify Counter CB008127 CD t7
    Verify Egate Logs t7

    [Teardown]   Perform Postconditions of Test Scenario CB008127-CD



CB008127_PX_Measurement_profile_selection_without_freqBandIndicatorNR_for_NSA
    [Documentation]    PX_Measurement_profile_selection_without_freqBandIndicatorNR_for_NSA
    ...       :Autor: Sylvia Schneider
    [Tags]    t8
    [Setup]   Perform Preconditions of Test Scenario CB008127-CD

    Prepare Counters And Expected Values t8
    Update SCF t8
    Update wts file for TC CB008127-CD add cell2 and MFBI
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_CD_add_cell2_MFBI.cfg

    Start Wireshark Trace
    Activate SCF And Bring TL onAir t8
    Setup X2 Link to gnb-3
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword and Warn On Failure     Prepare For Dcap Tracing
    Run Keyword and Warn On Failure     Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Attach UE And sgnbAddition And Disp Meas   ue_id=104
    Remove freqBandIndicatorNR 78 From pcCapabilityList
    Send Measurement Gap Info                  ue_id=104
    Send A2                                    ue_id=104   meas_id=3    srsrp_nr=80    srsrq_nr=80
    Display Measurements Of UE                 ue_id=104   log=_2

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_t8.pcap
    Detach UE from LTE                         ue_id=104

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Verify Counter CB008127 CD t8
    Verify Egate Logs t8

    [Teardown]   Perform Postconditions of Test Scenario CB008127-CD



CB008127_MN_Measurement_profile_reselection_due_to_frequenz_band_change_during_MeNB_mobility_scenario
    [Documentation]    MN_Measurement_profile_reselection_due_to_frequenz_band_change_during_MeNB_mobility_scenario
    ...       :Autor: Sylvia Schneider
    [Tags]    t9
    [Setup]   Perform Preconditions of Test Scenario CB008127-CD

    Prepare Counters And Expected Values t9
    Update SCF t9
    Update wts file for TC CB008127-CD add cell2 and MFBI
    Upload Wts Cfg File     ${resultDir}/basic_wts_CB008127_CD_add_cell2_MFBI.cfg

    Start Wireshark Trace
    Activate SCF And Bring TL onAir t9
    Setup X2 Link to gnb-3
    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    Check Wts In Active State

    Run Keyword and Warn On Failure     Prepare For Dcap Tracing
    Run Keyword and Warn On Failure     Dcap Tracing Start

    Start Btslog

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Attach UE And sgnbAddition And Disp Meas   ue_id=105
    Send Measurement Gap Info                  ue_id=105
    Send A2                                    ue_id=105   meas_id=3    srsrp_nr=80    srsrq_nr=80
    Display Measurements Of UE                 ue_id=105   log=_2

    Start Intra LTE Handover Without PSCell Change And Update Allowed BC List MRDC    ue_id=105   allowed_bc_list_mrdc=3:1
    Display Measurements Of UE                 ue_id=105   log=_3

    Stop Wireshark Trace   wireshark_store=${resultDir}/wireshark_t9.pcap
    Detach UE from LTE                         ue_id=105

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Stop Btslog   target_dir=${resultDir}

    Verify Counter CB008127 CD t9
    Verify Egate Logs t9
    verify syslog trace

    [Teardown]   Perform Postconditions of Test Scenario CB008127-CD


*** Keywords ***

Suite Setup CB008127-CD
    [Documentation]    [PRIVATE]    Prepare TL for CB008127-CD
    ...       :Autor: Sylvia Schneider
    ute_workarounds.Log TL Info as Metadata for UTE AP TL
    Create Ips For Simulated gnb And eNB
    Create Test Suite Folders
    Get Test Variables And Upload Start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    Get Version mcc mnc From gNB SCF    ${current_SCF_gnb}
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update gscn In Iphy File
    Update Wts File For TC CB008127-CD
    Update SCF File For TC CB008127-CD Common Part
