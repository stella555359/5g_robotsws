** Settings ***

Documentation   This is a Robot Test Suite for subfeature 5GC000480-D and 5GC000480-J testing'
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Email: 'Sylvia.Schneider@nokia.com'
#-------------------------------------------------------------------------------------------------------------
Resource        ../keywordbook-480.robot
Resource        ../keywordbook-480-resourceUsage.robot
Resource        ../../../resources/Common/reporting.robot
Resource         5GC000480DJ-wts.robot
Resource         5GC000480DJ-commissioning.robot
Resource         5GC000480DJ-counter_parameter_settings.robot
Resource         5GC000480DJ-keywords.robot
Resource         5GC000480DJ-verify_counter.robot
Resource         5GC000480DJ-verify_wireshark.robot


Suite Setup       Suite Setup for 5GC000480-D-J Testing
Suite Teardown    Suite Teardown for 5GC000480-D-J Testing


*** Variables ***

${wts_GNB_X2_ADDR}                    10.0.1.2
${wts_GNB3_X2_ADDR}                   10.0.1.3
${wts_GNB3_S1U_ADDR}                  10.0.1.4

${class_NRCELL}                     class="com.nokia.srbts.nrbts:NRCELL"
${cell_distName}          NRCELL-3
${nrcellgrp_distName}     NRCELLGRP-2

${measurement_period_in_min}      5

${logs_collected}                     False


*** Test Cases ***

5GC000480_D_Successful_PSCell_change_with_RAC
    [Documentation]    This Test Scenario verifies the counters
    ...                M55114C00001, M55114C00002, M55114C00003, M55114C00004, M55114C00006, M55114C00007,
    ...                M55114C00016, M55114C00017, M55114C00018, M55114C00019, M55114C00020,
    ...                M55115C00002, M55115C00003
    [Tags]    succPs    CIT
    [Setup]    Perform Preconditions of Test Scenario

    prepare counters and expected values successful PSCell
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace

    Attach on gNB  gnb_id=2                ue_id=151     target_cells=3
    handover with A3 measurement to gNB3   ue_id=151
    handover with A3 measurement to gNB2   ue_id=151

    stop wireshark trace     part=1
    Detach UE from LTE                     ue_id=151


    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    get resources taken after_test

    collect pm file and verify counter values

    Verify wireshark successful PSCell
    no check of resource nbOfFreeCRNTI
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]    Perform Postconditions of Test Scenario


5GC000480_D_Unsuccessful_PSCell_change_due_to_target_cell_with_RAC_failure
    [Documentation]    This Test Scenario verifies for source and target handover cell the counters
    ...                M55114C00001, M55114C00002, M55114C00003, M55114C00004, M55114C00006, M55114C00007,
    ...                M55114C00016, M55114C00017, M55114C00018, M55114C00019, M55114C00020,
    ...                M55115C00002, M55115C00003
    [Tags]    RACfail   CRT
    [Setup]    Perform Preconditions of Test Scenario

    prepare counters and expected values RacFailure
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    Attach on gNB  gnb_id=3                ue_id=151     target_cells=1
    handover with A3 measurement to gNB2   ue_id=151
    stop wireshark trace     part=1

    start wireshark trace
    Attach on gNB  gnb_id=3                             ue_id=152     target_cells=1
    unsuccessful handover with A3 measurement to gNB2   ue_id=152
    stop wireshark trace     part=2

    Detach UE from LTE                     ue_id=151
    Detach UE from LTE                     ue_id=152

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    get resources taken after_test

    collect pm file and verify counter values

    Verify wireshark RacFailure
    no check of resource nbOfFreeCRNTI
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]    Perform Postconditions of Test Scenario


5GC000480_D_successful_PSCellChange_with_RAC_and_addNumOfHoUsers
    [Documentation]    This Test Scenario verifies for source and target handover cell the counters
    ...                M55114C00001, M55114C00002, M55114C00003, M55114C00004, M55114C00006, M55114C00007,
    ...                M55114C00016, M55114C00017, M55114C00018, M55114C00019, M55114C00020,
    ...                M55115C00002, M55115C00003
    [Tags]    RACaddHO   CRT
    [Setup]    Perform Preconditions of Test Scenario

    prepare counters and expected values RACaddHO
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    Attach on gNB  gnb_id=2                ue_id=151     target_cells=3
    stop wireshark trace     part=1

    start wireshark trace
    unsuccessful Attach on gNB  gnb_id=2   ue_id=152     target_cells=3
    stop wireshark trace     part=2

    start wireshark trace
    Attach on gNB  gnb_id=3                ue_id=152     target_cells=1
    handover with A3 measurement to gNB2   ue_id=152
    stop wireshark trace     part=3

    Detach UE from LTE                     ue_id=151
    Detach UE from LTE                     ue_id=152

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    get resources taken after_test

    collect pm file and verify counter values

    Verify wireshark RACaddHO
    no check of resource nbOfFreeCRNTI
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]    Perform Postconditions of Test Scenario


5GC000480_D_Unsuccessful_PSCell_change_with_RAC_failure_due_to_not_enough_bearer_capacity
    [Documentation]    This Test Scenario verifies for source and target handover cell the counters
    ...                M55114C00001, M55114C00002, M55114C00003, M55114C00004, M55114C00006, M55114C00007,
    ...                M55114C00016, M55114C00017, M55114C00018, M55114C00019, M55114C00020,
    ...                M55115C00002, M55115C00003
    [Tags]    RACbearerFail   CRT
    [Setup]    Perform Preconditions of Test Scenario

    prepare counters and expected values RacBearerFailure
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    Attach on gNB with additional bearers     gnb_id=3    ue_id=151     target_cells=1
    handover with A3 measurement to gNB2                  ue_id=151
    stop wireshark trace     part=1

    start wireshark trace
    Attach on gNB                             gnb_id=3    ue_id=152     target_cells=1
    unsuccessful handover with A3 measurement to gNB2     ue_id=152
    stop wireshark trace     part=2

    Detach UE from LTE                     ue_id=151
    Detach UE from LTE                     ue_id=152

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    get resources taken after_test

    collect pm file and verify counter values

    Verify wireshark RacBearerFailure
    no check of resource nbOfFreeCRNTI
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]    Perform Postconditions of Test Scenario


5GC000480_J_Release_UE_Context_after_successful_PSCell_change
    [Documentation]    This Test Scenario verifies the counters
    ...                M55114C00001, M55114C00002, M55114C00003, M55114C00004, M55114C00006, M55114C00007,
    ...                M55114C00016, M55114C00017, M55114C00018, M55114C00019, M55114C00020,
    ...                M55115C00002, M55115C00003
    [Tags]    succRel   CDRT   CRT
    [Setup]    Perform Preconditions of Test Scenario

    prepare counters and expected values successful release
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    Attach on gNB  gnb_id=2                ue_id=151     target_cells=3
    handover with A3 measurement to gNB3   ue_id=151
    stop wireshark trace     part=1

    start wireshark trace
    Attach on gNB  gnb_id=2                ue_id=152     target_cells=3
    stop wireshark trace     part=2

    Detach UE from LTE                     ue_id=151
    Detach UE from LTE                     ue_id=152

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    get resources taken after_test

    collect pm file and verify counter values

    Verify wireshark successful release
    no check of resource nbOfFreeCRNTI
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]    Perform Postconditions of Test Scenario


5GC000480_J_multiple_PSCell_changes
    [Documentation]    This Test Scenario verifies the counters
    ...                M55114C00001, M55114C00002, M55114C00003, M55114C00004, M55114C00006, M55114C00007,
    ...                M55114C00016, M55114C00017, M55114C00018, M55114C00019, M55114C00020,
    ...                M55115C00002, M55115C00003
    [Tags]    multiHO   CRT
    [Setup]    Perform Preconditions of Test Scenario

    prepare counters and expected values multiple handovers
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    Attach on gNB  gnb_id=2                ue_id=151     target_cells=3
    execute several handover between gNB3 and gNB2    ue_id=151
    stop wireshark trace     part=1
    Detach UE from LTE                     ue_id=151

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    get resources taken after_test

    collect pm file and verify counter values

    Verify wireshark multiple handovers
    no check of resource nbOfFreeCRNTI
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]    Perform Postconditions of Test Scenario


*** Keywords ***

Suite Setup for 5GC000480-D-J Testing
    [Documentation]    [PRIVATE]    Prepare TL for 5GC000480-D-J
    ...       :Autor: Sylvia Schneider
    Create ips for simulated gnb
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    gnb.Store Current SCF from gNB
    get version from gNB SCF
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update wts file for TC 480DJ
    Upload Customized WTS Config    config_path=${resultBaseDir}/basic_wts_480DJ.cfg
    get physCellIdfrom SCF
    Update SCF common part


Create ips for simulated gnb
    [Documentation]    [PRIVATE]    create IPs used for WTS
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncreate IPs on VM eth3
    Log To Console    ${wts_GNB3_X2_ADDR},${wts_GNB3_S1U_ADDR}
    Configure IP on VM    ip=${wts_GNB3_X2_ADDR}    interface=eth3
    Configure IP on VM    ip=${wts_GNB3_S1U_ADDR}   interface=eth3


get physCellId from SCF
    ${parsed_SCF}    parse XML     ${resultBaseDir}/SCFC_start.xml
    ${xpath_param}    get from dictionary    ${xpath_vars_SCF}    physCellId
    ${xpath_param_replaced}    Replace Variables    ${xpath_param}
    ${physCellId}    get element text    ${parsed_SCF}    xpath=${xpath_param_replaced}
    set suite variable    ${physCellId}


Perform Postconditions of Test Scenario
    [Documentation]    [PRIVATE]    postconditions for 480-D-J
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   stop wireshark trace     part=_Wireshark_ErrorInTest
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}
