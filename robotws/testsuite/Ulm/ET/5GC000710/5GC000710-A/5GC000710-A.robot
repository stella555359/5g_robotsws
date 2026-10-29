*** Settings ***

Documentation   This is a Robot Test Suite for subfeature 5GC000710-A
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        5GC000710-A-keywords.robot
Resource        5GC000710-A-commissioning.robot
Resource        5GC000710-A-verify-wireshark.robot
Resource        5GC000710-A-verify-wireshark-measurement-report.robot
Resource        5GC000710-A-verify-counter.robot
Resource        5GC000710-A-wts.robot
Resource        5GC000710-A-parameter-settings.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/reporting.robot

Suite Setup       Suite Setup 710A
Suite Teardown    Suite Teardown 710A

*** Variables ***
${logs_collected}                     False


*** Test Cases ***

5GC000710_A_NSA_default_mobility_profile_is_used
    [Documentation]    This Test Scenario verifies
    ...                M55157C00032 NRMOP_NSA_PROFILE_SELECTED_32
    ...       :Autor: Sylvia Schneider
    [Tags]   t1    CRT
    [Setup]   Perform Preconditions of Test Scenario 710A

    prepare counters and expected values t1
    tc specific update and activate SCF and bring tl onAir with plmn1

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    Attach UE to LTE         ue_id=151
    set spid for UE          ue_id=151     spid=10
    trigger gNB addition     ue_id=151
    send A2 measurement report and expect meas_id not found  ue_id=151
    stop wireshark trace

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values t1
    verify wireshark t1

    [Teardown]   Perform Postconditions of Test Scenario 710A


5GC000710_A_NSA_Configuration_of_A2_measurement_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                M55157C00002 NRMOP_NSA_PROFILE_SELECTED_02
    ...                M55157C00003 NRMOP_NSA_PROFILE_SELECTED_03
    ...       :Autor: Sylvia Schneider
    [Tags]   t2    CRT
    [Setup]   Perform Preconditions of Test Scenario 710A

    prepare counters and expected values t2
    tc specific update and activate SCF and bring tl onAir with plmn1

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    Attach UE to LTE         ue_id=151
    set spid for UE          ue_id=151     spid=88
    trigger gNB addition     ue_id=151
    stop wireshark trace
    move wireshark file for UE11

    start wireshark trace
    Attach UE to LTE             ue_id=152
    set spid for UE              ue_id=152     spid=99
    trigger gNB addition         ue_id=152
    send A2 measurement report and expect meas_id not found   ue_id=152
    stop wireshark trace
    move wireshark file for UE12

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values t2
    verify wireshark t2

    [Teardown]   Perform Postconditions of Test Scenario 710A


5GC000710_A_NSA_Handling_of_A1_event_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                M55157C00002 NRMOP_NSA_PROFILE_SELECTED_02
    ...       :Autor: Sylvia Schneider
    [Tags]   t3     CDRT    CRT
    [Setup]   Perform Preconditions of Test Scenario 710A

    prepare counters and expected values t3
    tc specific update and activate SCF and bring tl onAir with plmn1

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    Attach UE to LTE             ue_id=151
    set spid for UE              ue_id=151     spid=88
    trigger gNB addition         ue_id=151
    set measurement gap on       ue_id=151
    send A2 measurement report   ue_id=151
    send A1 measurement report   ue_id=151
    stop wireshark trace

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values t3
    verify wireshark t3

    [Teardown]   Perform Postconditions of Test Scenario 710A


5GC000710_A_NSA_interFreq_PSCell_change_with_mobility_profiles_and_no_SPID
    [Documentation]    This Test Scenario verifies
    ...                M55157C00004 NRMOP_NSA_PROFILE_SELECTED_04
    ...       :Autor: Sylvia Schneider
    [Tags]   t4     CDRT    CRT
    [Setup]   Perform Preconditions of Test Scenario 710A

    prepare counters and expected values t4
    tc specific update and activate SCF and bring tl onAir with plmn2

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    Attach UE to LTE             ue_id=151
    trigger gNB addition         ue_id=151
    set measurement gap on       ue_id=151
    send A2 measurement report                              ue_id=151    srsrq_nr=32
    send A2 measurement report                              ue_id=151
    send A5 measurement report                              ue_id=151    nrsrq_nr=29
    send A5 measurement report and expect successful RA     ue_id=151    nrsrq_nr=32
    stop wireshark trace

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values t4
    verify wireshark t4

    [Teardown]   Perform Postconditions of Test Scenario 710A


5GC000710_A_NSA_interGnb_interFreq_PSCell_change_with_SPID_and_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                M55157C00002 NRMOP_NSA_PROFILE_SELECTED_02
    ...       :Autor: Sylvia Schneider
    [Tags]   t5     CIT
    [Setup]   Perform Preconditions of Test Scenario 710A

    prepare counters and expected values t5
    tc specific update and activate SCF and bring tl onAir with plmn1

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    Attach UE to LTE             ue_id=151
    set spid for UE              ue_id=151     spid=88
    trigger gNB addition         ue_id=151
    set measurement gap on       ue_id=151
    send A2 measurement report   ue_id=151
    send A3 measurement report and expect successful RA   ue_id=151
    stop wireshark trace

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values t5
    verify wireshark t5

    [Teardown]   Perform Postconditions of Test Scenario 710A


5GC000710_A_NSA_SPID_provided_in_SgNB_modification_procedure
    [Documentation]    This Test Scenario verifies the counters M55114C00001, M55114C00002, M55114C00003,
    ...                M55114C00004, M55114C00006, M55114C00007, M55114C00020, M55115C00002, M55115C00003,
    ...                M55112C04001, M55112C04002
    ...       :Autor: Sylvia Schneider
    [Tags]   t6    CRT
    [Setup]   Perform Preconditions of Test Scenario 710A

    prepare counters and expected values t6
    tc specific update and activate SCF and bring tl onAir with plmn1

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    set spid and attach
    attach and modify spid     test_run=1
    unassign spid and attach
    attach and modify spid     test_run=2

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values t6
    verify wireshark t6

    [Teardown]   Perform Postconditions of Test Scenario 710A



*** Keywords ***
Suite Setup 710A
    [Documentation]    [PRIVATE]    Prepare TL for 5GC000710-A
    ...       :Autor: Sylvia Schneider
    Create ips for simulated gnb
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    gnb.Store Current SCF from gNB
    get mcc mnc tac version from gNB SCF
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update wts file for TC 710A plmn1
    Update wts file for TC 710A plmn2
    Update SCF common part


Perform Preconditions of Test Scenario 710A
    [Documentation]    [PRIVATE]    preconditions for 710A
    ...       :Autor: Sylvia Schneider
    Create a Test Scenario Folder


get mcc mnc tac version from gNB SCF
    [Documentation]    [PRIVATE]    get values from SCF for update in wts and commissioning
    ...       :Autor: Sylvia Schneider
    ${parsed_SCF}    parse XML    ${P_ORIG_SCF}
    ${mcc_SCF}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mcc"]
    set suite variable   ${mcc_SCF}
    Log To Console    set suite variable mcc_SCF to value: ${mcc_SCF}
    ${mnc_SCF}    get element text          ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mnc"]
    set suite variable   ${mnc_SCF}
    Log To Console    set suite variable mnc_SCF to value: ${mnc_SCF}
    ${mnclenght_SCF}    get element text    ${parsed_SCF}    xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="mncLength"]
    set suite variable   ${mnclenght_SCF}
    Log To Console    set suite variable mnclenght_SCF to value: ${mnclenght_SCF}
    ${fiveGsTac_SCF}    get element text    ${parsed_SCF}
    ...    xpath=.//managedObject[@class="com.nokia.srbts.nrbts:TRACKINGAREA"]/p[@name="fiveGsTac"]
    set suite variable   ${fiveGsTac_SCF}
    Log To Console    set suite variable fiveGsTac_SCF to value: ${fiveGsTac_SCF}
    ${version_SCF}    get element attribute    ${parsed_SCF}    version     xpath=.//managedObject[@distName="${bts_distName}"]
    set suite variable   ${version_SCF}
    Log To Console    set suite variable version_SCF to value: ${version_SCF}


Perform Postconditions of Test Scenario 710A
    [Documentation]    [PRIVATE]    postconditions for 710A
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   stop wireshark trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}


Suite Teardown 710A
    [Documentation]    [PRIVATE]    suite teardown for 710A
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   stop wireshark trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect snapshot and sos report data   ${resultBaseDir}
    Reload Stored WTS Config

