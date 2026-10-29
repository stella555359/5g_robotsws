*** Settings ***
Documentation
...    Author: Andreea Zaharia
...    Maintainer: Andreea Zaharia
...    Test Description: Software management

Library    SSHLibrary
#Library    ute_fault
Library    String
Library    Process
Library    taf.sbts.oam.coam.admin

Library        Telnet
Library        OperatingSystem

Resource    ../../resources/admin.robot
Resource   ../../resources/admin_infomodel.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/fault_trigger.robot
Resource    ./keyword.robot
Resource    ./CB006977_keywords.robot


*** Variables ***
${bts_log}              /tmp/btslog2


*** Keywords ***

DnRSW_Download_and_Distribution
    log to console    start testcase 1 "DnRSW_Download_and_Distribution"
##    Comment DnR flag if exists
##    Uncomment DnR flag if commented
    log to console   add 0x4B0014=1 flag to swconfig
    SYSTEM Add Flag In Swconfig File   0x4B0014=1
    SYSTEM Add Flag In Swconfig File   0x1003f=1
    SYSTEM Add Flag In Swconfig File   0x10040=1
    SYSTEM Add Flag In Swconfig File   0x10041=5
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    wait until keyword succeeds  360s  10s    Check if RMOD is in availabilityStatus Online
    Get active and passive sw versions before sw update
    Start software update in background
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    wait until keyword succeeds  360s  10s    Check if RMOD is in availabilityStatus Online
    Get active and passive sw versions after sw update
    Check if sw after sw update is the same
    log to console   check that dnr files distribution was successfully done
    run keyword and continue on failure    check if the dnr files distribution was successful
    Prepare build for SWR
    Check not uncommissioned state for BTS

DnRSW_functionality_shall_not_be_impacted_by_BTS_SW_Rollback
    log to console    start testcase 2 "DnRSW_functionality_shall_not_be_impacted_by_BTS_SW_Rollback"
    log to console   add 0x4B0014=1 flag to swconfig
    SYSTEM Add Flag In Swconfig File   0x4B0014=1
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    wait until keyword succeeds  360s  10s    Check if RMOD is in availabilityStatus Online
    Check recovery partition before rollback
    Software_Rollback
    Check recovery partition after rollback
    Check if recovery partition content after rollback is the same
    Check not uncommissioned state for BTS
    Unmount dnr partition

SW_Update_Abort_during_DnRSW_Distribution
    log to console    start testcase 3 "SW_Update_Abort_during_DnRSW_Distribution"
    log to console   add 0x4B0014=1 flag to swconfig
    SYSTEM Add Flag In Swconfig File   0x4B0014=1
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    wait until keyword succeeds  360s  10s    Check if RMOD is in availabilityStatus Online
    Get active and passive sw versions before sw update
    Start software update in background

DnRSW_Download_fails_due_to_missing_files
    log to console    start testcase 4 "DnRSW_Download_fails_due_to_missing_files "
    log to console   add 0x4B0014=1 flag to swconfig
    SYSTEM Add Flag In Swconfig File   0x4B0014=1
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    wait until keyword succeeds  360s  10s    Check if RMOD is in availabilityStatus Online
    Get active and passive sw versions before sw update
    Unzip/zip sw build when DnRSW files are missing
    ADMIN Update Software With Activation
    ...            sw_package=${OUTPUT_DIR}/${T1_package}
    ...            timeout=2000
    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    wait until keyword succeeds  360s  10s    Check if RMOD is in availabilityStatus Online
    Get active and passive sw versions after sw update
    Check if sw after sw update is the same
    check messages when DnRSW files are missing

ROBUSTNESS_DnRSW_Download_fails_due_to_missing_files
    log to console    start testcase 4 "DnRSW_Download_fails_due_to_missing_files "
    log to console   add 0x4B0014=1 flag to swconfig
    SYSTEM Add Flag In Swconfig File   0x4B0014=1
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    wait until keyword succeeds  360s  10s    Check if RMOD is in availabilityStatus Online
    Get active and passive sw versions before sw update
    ${swr_update}   Run Keyword If     '${OUT_ACTIVE_SW}'=='${pre_update_active_sw}'
    ...         Run Keyword   Prepare SWR for T1 when T1 is already on active partition
    ...         ELSE  Run Keyword    ADMIN Update Software With Activation for T1
    sleep   10
    FOR    ${0}    IN RANGE    ${4}
       Prepare SWR for T1 when T1 is already on active partition
       run keyword and continue on failure   check if swr is successfully done
       Check if sw after sw update is the same as active version
       Sleep  10
    END
       check messages when DnRSW files are missing for robustness

