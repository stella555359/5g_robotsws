*** Settings ***

Documentation   This is a Robot Test Suite for subfeature 5GC000710-A with 2 cell configuartion
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        5GC000710-A-wts.robot
Resource        5GC000710-A-keywords.robot
Resource        5GC000710-A-keywords-2cell.robot
Resource        5GC000710-A-commissioning-2cell.robot
Resource        5GC000710-A-verify-wireshark-measurement-report.robot
Resource        5GC000710-A-verify-counter.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/reporting.robot

Suite Setup       Suite Setup 710A 2 cell config
Suite Teardown    Suite Teardown 710A 2 cell config

*** Variables ***
${logs_collected}                     False


*** Test Cases ***

5GC000710_A_NSA_intraGnb_intraDU_interFreq_PSCell_change_with_mobility_profiles
    [Documentation]    This Test Scenario verifies
    ...                M55157C00002   NRMOP_NSA_PROFILE_SELECTED_02
    ...                M55157C00003   NRMOP_NSA_PROFILE_SELECTED_03
    ...       :Autor: Sylvia Schneider
    [Tags]       CRT
    [Setup]   Perform Preconditions of Test Scenario 710A 2 cell config
    load wts and bring tl onAir and set expected values

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    Attach UE to LTE         ue_id=101
    set spid for UE          ue_id=101     spid=88
    trigger gNB addition     ue_id=101     target_cells=1
    set measurement gap on   ue_id=101
    send A2 measurement report with srsrp         ue_id=101   meas_id=3
    send enb_endc_param to disable allowed_bc_list_mrdc
    modify spid                                   ue_id=101   spid_modify=99
    send A3 measurement report for HO to cell2    ue_id=101
    send A2 measurement report with srsrp and srsrq              ue_id=101   srsrq_nr=35
    send A2 measurement report with srsrp and srsrq and check    ue_id=101   srsrq_nr=33
    send A5 measurement report no HO triggered    ue_id=101
    send A5 measurement report for HO to cell1    ue_id=101
    stop wireshark trace

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    collect pm file and verify counter values 2 cell config
    verify wireshark 2 cell config

    [Teardown]   Perform Postconditions of Test Scenario 710A 2 cell config


*** Keywords ***
Suite Setup 710A 2 cell config
    [Documentation]    [PRIVATE]    Prepare TL for 5GC000710-A 2 cell configuration
    ...       :Autor: Sylvia Schneider
    Create ips for simulated gnb 2 cell config
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    gnb.Store Current SCF from gNB
    get mcc mnc tac version from gNB SCF
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    update gscn in iphy file
    Update wts file for TC 710A 2 cell config
    Update and activate SCF 2 cell config


load wts and bring tl onAir and set expected values
    [Documentation]    [PRIVATE]    load wts file, bring tl onAir without reboot, set expected counters and values
    ...       :Autor: Sylvia Schneider
    Load wts 2 cell config file
    Wait until all DUs up
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    check wts in active state
    prepare counters and expected values 2 cell config


Perform Preconditions of Test Scenario 710A 2 cell config
    [Documentation]    [PRIVATE]    preconditions for 710A
    ...       :Autor: Sylvia Schneider
    Create a Test Scenario Folder


Perform Postconditions of Test Scenario 710A 2 cell config
    [Documentation]    [PRIVATE]    postconditions for 710A 2 cell config
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   Set SCOUT TC ID for Reporting
    Run Keyword And Continue On Failure   stop wireshark trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Run Keyword And Continue On Failure   Teardown Egate Connection for Airphone
    Run Keyword And Continue On Failure   Teardown Edaemon Connection for Airphone    edaemon_alias=edaemon
    IF    '${TEST STATUS}'=='FAIL'    Collect snapshot and sos report data     ${resultDir}


Suite Teardown 710A 2 cell config
    [Documentation]    [PRIVATE]    suite teardown for 710A 2 cell config
    ...       :Autor: Sylvia Schneider
    Run Keyword And Continue On Failure   stop wireshark trace      wireshark_store=${resultBaseDir}/wireshark_suite_teardown.pcap
    IF    '${SUITE STATUS}'=='FAIL' and '${logs_collected}'=='False'    Collect snapshot and sos report data   ${resultBaseDir}
    Reload Stored WTS Config

