*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008146-E
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        CB008146-E-TMO-keywords.robot
Resource        CB008146-E-TMO-commissioning.robot
Resource        CB008146-E-verify-wireshark.robot
Resource        CB008146-E-verify-egate-keywords.robot
Resource        CB008146-E-TMO-verify-egate-t1.robot
Resource        CB008146-E-TMO-verify-egate-t2.robot
Resource        CB008146-E-TMO-verify-egate-t3.robot
Resource        CB008146-E-TMO-verify-egate-t4.robot
Resource        CB008146-E-TMO-verify-egate-t5.robot
Resource        CB008146-E-TMO-verify-egate-t6.robot
Resource        CB008146-E-verify-counter.robot
Resource        CB008146-E-TMO-wts.robot
Resource        CB008146-E-TMO-parameter-settings.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/reporting.robot
Resource        ../../../resources/Common/bsr_package_installation.robot

Resource        ../../resources/SQD60/keywords-tracing.robot


Suite Setup       Suite Setup CB008146E
Suite Teardown    Suite Teardown CB008146E

*** Variables ***
${logs_collected}                     False


*** Test Cases ***

CB008146_E_SA_A2_measurement_configuration_for_redirection_and_HO_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE1 select profile 3 and no A2 measurement configuration
    ...                UE2 select profile 3 and A2 measurement configuration for redirection and for handover
    ...                M55157C00035 NRMOP_SA_PROFILE_SELECTED_03
    ...       :Autor: Sylvia Schneider
    [Tags]   t1   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008146E

    prepare counters and expected values t1
    tc specific update and activate SCF and bring tl onAir with plmn1

    Run Keyword And Continue On Failure         prepare for dcap tracing
    Run Keyword And Continue On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    set AMF param indexToRFSP     indexToRFSP=88
    register startPdu for UE81
    register startPdu for UE82
    stop wireshark trace

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Continue On Failure         dcap tracing stop

    collect pm file and verify counter values t1
    verify wireshark successful InitialContextSetupResponse    2
    verify egate log t1

    [Teardown]   Perform Postconditions of Test Scenario CB008146E


CB008146_E_SA_Handling_of_A2_event_with_measurement_gap_and_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE3 select profile 3
    ...                M55157C00035 NRMOP_SA_PROFILE_SELECTED_03
    ...       :Autor: Sylvia Schneider
    [Tags]   t2   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008146E

    prepare counters and expected values t2
    tc specific update and activate SCF and bring tl onAir with plmn1

    Run Keyword And Continue On Failure         prepare for dcap tracing
    Run Keyword And Continue On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    set AMF param indexToRFSP     indexToRFSP=88
    register startPdu for UE83
    send A2 measurement with srsrp_nr and srsrq_nr              srsrp_nr=30    srsrq_nr=32    meas_id=1    UE_id=83
    send A2 measurement with srsrp_nr and srsrq_nr and check    srsrp_nr=30    srsrq_nr=30    meas_id=1    UE_id=83   check=mgta ms0
    stop wireshark trace

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Continue On Failure         dcap tracing stop

    collect pm file and verify counter values t2
    verify wireshark successful InitialContextSetupResponse   1
    verify egate log t2

    [Teardown]   Perform Postconditions of Test Scenario CB008146E


CB008146_E_SA_Handling_of_A1_event_without_measurement_gaps_and_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE2 select profile 3
    ...                M55157C00035 NRMOP_SA_PROFILE_SELECTED_03
    ...       :Autor: Sylvia Schneider
    [Tags]   t3   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008146E

    prepare counters and expected values t3
    tc specific update and activate SCF and bring tl onAir with plmn1

    Run Keyword And Continue On Failure         prepare for dcap tracing
    Run Keyword And Continue On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    set AMF param indexToRFSP     indexToRFSP=88
    register startPdu for UE84
    send A2 measurement with srsrp_nr and srsrq_nr and check    srsrp_nr=30    srsrq_nr=30    meas_id=1    UE_id=84
    send A1 measurement with srsrp_nr and srsrq_nr              srsrp_nr=50    srsrq_nr=35    meas_id=5    UE_id=84
    send A1 measurement with srsrp_nr and srsrq_nr and check    srsrp_nr=50    srsrq_nr=51    meas_id=5    UE_id=84
    stop wireshark trace

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Continue On Failure         dcap tracing stop

    collect pm file and verify counter values t3
    verify wireshark successful InitialContextSetupResponse   1
    verify egate log t3

    [Teardown]   Perform Postconditions of Test Scenario CB008146E


CB008146_E_SA_Handling_of_A1_event_for_voice_over_NR_call_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE3 select profile 3
    ...                M55157C00035 NRMOP_SA_PROFILE_SELECTED_03
    ...       :Autor: Sylvia Schneider
    [Tags]   t4    CDRT   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008146E

    prepare counters and expected values t4
    tc specific update and activate SCF and bring tl onAir with plmn1_voice

    Run Keyword And Continue On Failure         prepare for dcap tracing
    Run Keyword And Continue On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    set AMF param indexToRFSP     indexToRFSP=88
    register startPdu for UE83
    modify pdu session      UE_id=83
    send A2 measurement with srsrp_nr and srsrq_nr and check    srsrp_nr=40    srsrq_nr=48    meas_id=5    UE_id=83
    send A1 measurement with srsrp_nr and srsrq_nr              srsrp_nr=61    srsrq_nr=51    meas_id=6    UE_id=83
    send A1 measurement with srsrp_nr and srsrq_nr and check    srsrp_nr=61    srsrq_nr=53    meas_id=6    UE_id=83
    stop wireshark trace

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Continue On Failure         dcap tracing stop

    collect pm file and verify counter values t4
    verify wireshark successful InitialContextSetupResponse   1
    verify egate log t4

    [Teardown]   Perform Postconditions of Test Scenario CB008146E


CB008146_E_SA_interGnb_interFreq_handover_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE1 select profile 4
    ...                M55157C00036 NRMOP_SA_PROFILE_SELECTED_04
    ...       :Autor: Sylvia Schneider
    [Tags]   t5    CIT
    [Setup]   Perform Preconditions of Test Scenario CB008146E

    prepare counters and expected values t5
    tc specific update and activate SCF and bring tl onAir with plmn1

    Run Keyword And Continue On Failure         prepare for dcap tracing
    Run Keyword And Continue On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    set AMF param indexToRFSP     indexToRFSP=99
    register startPdu for UE81
    send A2 measurement with srsrp_nr and srsrq_nr and check    srsrp_nr=30     srsrq_nr=30   meas_id=1    UE_id=81
    ...   check=rrcReconfigurationComplete
    send A3 measurement with rsrp_nr and rsrq_nr                phycell_id=46   nrsrq_nr=35   meas_id=6    UE_id=81
    send A3 measurement with rsrp_nr and rsrq_nr and check      phycell_id=46   nrsrq_nr=45   meas_id=6    UE_id=81
    send A2 measurement with srsrp_nr and srsrq_nr              srsrp_nr=7      srsrq_nr=30   meas_id=1    UE_id=81
    display measurement    UE_id=81
    send history information    UE_id=81
    send A3 measurement with rsrp_nr and rsrq_nr and check      phycell_id=60   nrsrq_nr=50   meas_id=23   UE_id=81
    stop wireshark trace

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Continue On Failure         dcap tracing stop

    collect pm file and verify counter values t5
    verify wireshark successful handover
    verify egate log t5

    [Teardown]   Perform Postconditions of Test Scenario CB008146E


CB008146_E_SA_A2_Meas_Config_after_interGnb_intraFreq_HO_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                UE1 select profile 5
    ...                M55157C00037 NRMOP_SA_PROFILE_SELECTED_05
    ...       :Autor: Sylvia Schneider
    [Tags]   t6   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008146E

    prepare counters and expected values t6
    tc specific update and activate SCF and bring tl onAir with plmn2

    Run Keyword And Continue On Failure         prepare for dcap tracing
    Run Keyword And Continue On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register startPdu for UE81
    display measurement    UE_id=81  run=_1
    send A3 measurement with rsrp_nr and check   phycell_id=48    UE_id=81
    send history information    UE_id=81
    display measurement    UE_id=81  run=_2
    send A3 measurement with rsrp_nr and check   phycell_id=60    UE_id=81
    stop wireshark trace

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Continue On Failure         dcap tracing stop

    collect pm file and verify counter values t6
    verify wireshark successful handover
    verify egate log t6

    [Teardown]   Perform Postconditions of Test Scenario CB008146E


*** Keywords ***
Suite Setup CB008146E
    [Documentation]    [PRIVATE]    Prepare TL for CB008146-E
    ...       :Autor: Sylvia Schneider
    Create ips for simulated gnb
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    gnb.Store Current SCF from gNB
    get nrarfcn plmn tac version from gNB SCF
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    bsr_package_installation.Install All BSR Packages Found In SCF
    Update wts file for TC CB008146E plmn1
    Update wts file for TC CB008146E plmn2
    Update wts file for TC CB008146E plmn1 voice
    Update SCF common part


Perform Preconditions Of Test Scenario CB008146E
    [Documentation]    [PRIVATE]    preconditions for CB008146E
    ...       :Autor: Sylvia Schneider
    Create A Test Scenario Folder
    Set Test Variable   ${log_number}    1


Get nrarfcn plmn tac Version From GNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update in wts and commissioning
    ...       :Autor: Sylvia Schneider
    ${parsed_SCF}    Parse XML    ${P_ORIG_SCF}
    ${nrarfcnDl_SCF}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-10/NRCELL_FDD-1"]/p[@name="nrarfcnDl"]
    Set Suite Variable   ${nrarfcnDl_SCF}
    Log To Console    set suite variable nrarfcnDl_SCF to value: ${nrarfcnDl_SCF}
    ${nrarfcnUl_SCF}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-10/NRCELL_FDD-1"]/p[@name="nrarfcnUl"]
    Set Suite Variable   ${nrarfcnUl_SCF}
    Log To Console    set suite variable nrarfcnUl_SCF to value: ${nrarfcnUl_SCF}
    ${mcc_SCF}    Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    Set Suite Variable   ${mcc_SCF}
    Log To Console    set suite variable mcc_SCF to value: ${mcc_SCF}
    ${mnc_SCF}    Get Element Text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    Set Suite Variable   ${mnc_SCF}
    Log To Console    set suite variable mnc_SCF to value: ${mnc_SCF}
    ${mnclenght_SCF}    Get Element Text    ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mncLength"]
    Set Suite Variable   ${mnclenght_SCF}
    Log To Console    set suite variable mnclenght_SCF to value: ${mnclenght_SCF}
    ${fiveGsTac_SCF}    Get Element Text    ${parsed_SCF}
    ...    xpath=.//managedObject[@class="com.nokia.srbts.nrbts:TRACKINGAREA"]/p[@name="fiveGsTac"]
    Set Suite Variable   ${fiveGsTac_SCF}
    Log To Console    set suite variable fiveGsTac_SCF to value: ${fiveGsTac_SCF}
    ${version_SCF}    Get Element Attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    Set Suite Variable   ${version_SCF}
    Log To Console    set suite variable version_SCF to value: ${version_SCF}


Perform Postconditions Of Test Scenario CB008146E
    [Documentation]    [PRIVATE]    postconditions for CB008146E
    ...       :Autor: Sylvia Schneider
    Set SCOUT TC ID For Reporting
    Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    End DCAP Tracing And Collect Traces
    Teardown Egate Connection For Airphone
    Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect Snapshot And SOS Report Data     ${resultDir}


Suite Teardown CB008146E
    [Documentation]    [PRIVATE]    suite teardown for CB008146E
    ...       :Autor: Sylvia Schneider
    Stop Wireshark Trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect Snapshot And SOS Report Data   ${resultBaseDir}
    Reload Stored WTS Config
